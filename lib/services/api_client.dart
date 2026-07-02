import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thrown for any non-success API response. `code` matches the backend's
/// error codes (BAD_REQUEST, UNAUTHORIZED, FORBIDDEN, NOT_FOUND, CONFLICT...).
class ApiException implements Exception {
  final String code;
  final String message;
  final int status;
  final List<dynamic>? details;
  ApiException(this.status, this.code, this.message, [this.details]);

  @override
  String toString() => message;
}

/// Singleton HTTP client for the SportyQo backend.
///
/// Base URL resolution (in order):
///  1. --dart-define=API_BASE_URL=https://api.example.com
///  2. default http://10.0.2.2:8080  (Android emulator -> host machine)
///
/// For a real device on the same Wi-Fi, run with:
///   flutter run --dart-define=API_BASE_URL=http://<your-computer-ip>:8080
/// For iOS simulator use http://localhost:8080.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  String? _accessToken;
  String? _refreshToken;
  String? userId;
  String? role;

  static const _kAccess = 'sq_access';
  static const _kRefresh = 'sq_refresh';
  static const _kUserId = 'sq_user_id';
  static const _kRole = 'sq_role';

  bool get isLoggedIn => _accessToken != null;

  /// Call once at app start (e.g. in main) to restore a saved session.
  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    _accessToken = p.getString(_kAccess);
    _refreshToken = p.getString(_kRefresh);
    userId = p.getString(_kUserId);
    role = p.getString(_kRole);
  }

  Future<void> saveSession(Map<String, dynamic> auth) async {
    _accessToken = auth['accessToken'] as String?;
    _refreshToken = auth['refreshToken'] as String?;
    userId = auth['userId'] as String?;
    role = auth['role'] as String?;
    final p = await SharedPreferences.getInstance();
    if (_accessToken != null) await p.setString(_kAccess, _accessToken!);
    if (_refreshToken != null) await p.setString(_kRefresh, _refreshToken!);
    if (userId != null) await p.setString(_kUserId, userId!);
    if (role != null) await p.setString(_kRole, role!);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    userId = null;
    role = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kAccess);
    await p.remove(_kRefresh);
    await p.remove(_kUserId);
    await p.remove(_kRole);
  }

  Map<String, String> _headers({bool auth = true}) => {
        'Content-Type': 'application/json',
        if (auth && _accessToken != null)
          'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> get(String path,
      {Map<String, String>? query, bool auth = true}) {
    return _send('GET', path, query: query, auth: auth);
  }

  Future<dynamic> post(String path,
      {Object? body, bool auth = true}) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<dynamic> patch(String path,
      {Object? body, bool auth = true}) {
    return _send('PATCH', path, body: body, auth: auth);
  }

  /// Multipart POST (league creation with logos, avatar upload, documents).
  /// [fields] are plain form fields; [files] maps field name -> file path.
  Future<dynamic> postMultipart(String path,
      {Map<String, String> fields = const {},
      Map<String, String> files = const {}}) async {
    final uri = Uri.parse('$baseUrl$path');
    final req = http.MultipartRequest('POST', uri);
    if (_accessToken != null) {
      req.headers['Authorization'] = 'Bearer $_accessToken';
    }
    req.fields.addAll(fields);
    for (final e in files.entries) {
      req.files.add(await http.MultipartFile.fromPath(e.key, e.value));
    }
    http.Response res;
    try {
      res = await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 60)));
    } catch (_) {
      throw ApiException(0, 'NETWORK',
          'Could not reach the server. Check your connection and API_BASE_URL.');
    }
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(res.statusCode, 'INTERNAL', 'Unexpected server response.');
    }
    if (json['success'] == true) return json['data'];
    final err = (json['error'] as Map<String, dynamic>?) ?? {};
    throw ApiException(
      res.statusCode,
      (err['code'] as String?) ?? 'INTERNAL',
      (err['message'] as String?) ?? 'Something went wrong.',
      err['details'] as List<dynamic>?,
    );
  }

  Future<dynamic> _send(String method, String path,
      {Object? body,
      Map<String, String>? query,
      bool auth = true,
      bool retried = false}) async {
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: query?.isEmpty ?? true ? null : query);

    http.Response res;
    try {
      final req = http.Request(method, uri)..headers.addAll(_headers(auth: auth));
      if (body != null) req.body = jsonEncode(body);
      res = await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 20)));
    } catch (_) {
      throw ApiException(0, 'NETWORK',
          'Could not reach the server. Check your connection and API_BASE_URL.');
    }

    // Transparent one-shot refresh on expired access token.
    if (res.statusCode == 401 && auth && !retried && _refreshToken != null) {
      final ok = await _tryRefresh();
      if (ok) {
        return _send(method, path,
            body: body, query: query, auth: auth, retried: true);
      }
      await clearSession();
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(res.statusCode, 'INTERNAL', 'Unexpected server response.');
    }

    if (json['success'] == true) return json['data'];
    final err = (json['error'] as Map<String, dynamic>?) ?? {};
    throw ApiException(
      res.statusCode,
      (err['code'] as String?) ?? 'INTERNAL',
      (err['message'] as String?) ?? 'Something went wrong.',
      err['details'] as List<dynamic>?,
    );
  }

  Future<bool> _tryRefresh() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        await saveSession(json['data'] as Map<String, dynamic>);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
