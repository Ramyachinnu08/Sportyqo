import 'dart:async';
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

  /// Resolves media URLs returned by the API. Relative paths (like
  /// "/uploads/avatars/x.png") are served by the backend itself, so they
  /// are prefixed with the API base URL; absolute URLs pass through.
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('/')) return '$baseUrl$url';
    return url;
  }

  /// Call once at app start (e.g. in main) to restore a saved session.
  ///
  /// Self-healing: sessions saved by older app versions may have a token but
  /// no userId/role. Screens build API paths from [userId], so a missing id
  /// silently produced broken requests (surfacing as confusing 404s, e.g. on
  /// the Dugout page). If the token is present but the identity is not, we
  /// fetch /me once to repair the session; if the token turns out to be dead
  /// we clear it so the app cleanly shows the login screen instead.
  Future<void> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    _accessToken = p.getString(_kAccess);
    _refreshToken = p.getString(_kRefresh);
    userId = p.getString(_kUserId);
    role = p.getString(_kRole);

    if (_accessToken != null && (userId == null || role == null)) {
      try {
        final me = await get('/me').timeout(const Duration(seconds: 8))
            as Map<String, dynamic>;
        userId = me['userId'] as String?;
        role = me['role'] as String?;
        if (userId != null) await p.setString(_kUserId, userId!);
        if (role != null) await p.setString(_kRole, role!);
        if (userId == null || role == null) await clearSession();
      } on ApiException catch (e) {
        // Offline start keeps the session; a rejected token clears it.
        if (e.code != 'NETWORK') await clearSession();
      } catch (_) {
        // Timeout or anything unexpected: keep the session, stay usable offline.
      }
    }
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

  /// Guards against paths built from null/empty ids (e.g. "/dugout//messages"
  /// or "/players/null/home"). Those used to reach the server and come back as
  /// a baffling "Route not found" — now they fail fast with a message that
  /// names the broken path so the bug is findable.
  static void _assertValidPath(String path) {
    if (path.contains('//') ||
        path.contains('/null/') ||
        path.endsWith('/null') ||
        path.endsWith('/')) {
      throw ApiException(0, 'CLIENT',
          'Internal app error: malformed API path "$path". Please try again, and report this if it keeps happening.');
    }
  }

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

  Future<dynamic> delete(String path,
      {Object? body, bool auth = true}) {
    return _send('DELETE', path, body: body, auth: auth);
  }

  /// Multipart POST (league creation with logos, avatar upload, documents,
  /// playbook media). [fields] are plain form fields; [files] maps field
  /// name -> file path. Pass [onProgress] to receive upload progress in the
  /// 0.0–1.0 range (used by the Playbook upload sheet).
  Future<dynamic> postMultipart(String path,
      {Map<String, String> fields = const {},
      Map<String, String> files = const {},
      void Function(double progress)? onProgress}) async {
    _assertValidPath(path);
    final uri = Uri.parse('$baseUrl$path');
    final req = _ProgressMultipartRequest('POST', uri, onProgress: onProgress);
    if (_accessToken != null) {
      req.headers['Authorization'] = 'Bearer $_accessToken';
    }
    req.fields.addAll(fields);
    for (final e in files.entries) {
      req.files.add(await http.MultipartFile.fromPath(e.key, e.value));
    }
    http.Response res;
    try {
      // Videos can take a while on mobile networks — allow up to 5 minutes.
      res = await http.Response.fromStream(
          await req.send().timeout(const Duration(minutes: 5)));
    } catch (_) {
      throw ApiException(0, 'NETWORK',
          'Could not reach the server at $baseUrl — check that the phone can open $baseUrl/health in a browser.');
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
    _assertValidPath(path);
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
          'Could not reach the server at $baseUrl — check that the phone can open $baseUrl/health in a browser.');
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

/// A [http.MultipartRequest] that reports how many bytes have been handed to
/// the network layer, giving determinate upload progress for large media.
class _ProgressMultipartRequest extends http.MultipartRequest {
  _ProgressMultipartRequest(super.method, super.url, {this.onProgress});

  final void Function(double progress)? onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final report = onProgress;
    if (report == null) return byteStream;

    final total = contentLength;
    var sent = 0;
    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (chunk, sink) {
        sent += chunk.length;
        if (total > 0) report((sent / total).clamp(0.0, 1.0));
        sink.add(chunk);
      },
    );
    return http.ByteStream(byteStream.transform(transformer));
  }
}
