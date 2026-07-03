import 'api_client.dart';

/// Holds the in-progress sign-up data while the user moves through
/// Create Account -> Create Profile -> Select Sport -> Generating ID.
/// Screens write into this; the final register call reads from it.
class RegistrationDraft {
  static final RegistrationDraft instance = RegistrationDraft._();
  RegistrationDraft._();

  String fullName = '';
  String phone = '';
  String email = '';
  String password = '';
  bool isPlayer = true;
  String? sportName; // UI name, mapped to sportId at register time
  String? dob; // YYYY-MM-DD
  String? gender; // MALE / FEMALE / OTHER
  String? location;

  void reset() {
    fullName = '';
    phone = '';
    email = '';
    password = '';
    isPlayer = true;
    sportName = null;
    dob = null;
    gender = null;
    location = null;
  }
}

class AuthService {
  static final _api = ApiClient.instance;

  /// Logs in with email OR phone. Returns the role ('PLAYER' | 'COACH').
  static Future<String> login(String identifier, String password) async {
    final data = await _api.post('/auth/login',
        auth: false,
        body: {'identifier': identifier.trim(), 'password': password});
    await _api.saveSession(data as Map<String, dynamic>);
    return data['role'] as String;
  }

  /// Registers a player from the current RegistrationDraft.
  /// Returns the server-generated player ID (e.g. SQP2026123456).
  static Future<String> registerPlayerFromDraft() async {
    final d = RegistrationDraft.instance;
    final sportId = await _sportIdFor(d.sportName);
    final data = await _api.post('/auth/register/player', auth: false, body: {
      if (d.email.isNotEmpty) 'email': d.email.trim(),
      if (d.phone.isNotEmpty) 'phone': d.phone.trim(),
      'password': d.password,
      'fullName': d.fullName.trim(),
      if (sportId != null) 'sportId': sportId,
    });
    await _api.saveSession(data as Map<String, dynamic>);
    await _pushDraftProfileFields(d);
    return data['playerId'] as String;
  }

  /// Registers a coach from the current RegistrationDraft.
  /// Returns the server-generated coach code (e.g. SQC2026123456).
  static Future<String> registerCoachFromDraft({String? academy}) async {
    final d = RegistrationDraft.instance;
    final sportId = await _sportIdFor(d.sportName);
    final data = await _api.post('/auth/register/coach', auth: false, body: {
      if (d.email.isNotEmpty) 'email': d.email.trim(),
      if (d.phone.isNotEmpty) 'phone': d.phone.trim(),
      'password': d.password,
      'fullName': d.fullName.trim(),
      if (sportId != null) 'sportId': sportId,
      if (academy != null && academy.isNotEmpty) 'academy': academy,
    });
    await _api.saveSession(data as Map<String, dynamic>);
    await _pushDraftProfileFields(d);
    return data['coachCode'] as String;
  }

  /// Best-effort: sends the profile details collected during sign-up
  /// (location, gender, dob) to PATCH /me/profile after registration.
  static Future<void> _pushDraftProfileFields(RegistrationDraft d) async {
    final fields = <String, dynamic>{
      if (d.location != null && d.location!.isNotEmpty)
        'location': d.location,
      if (d.gender != null) 'gender': d.gender,
      if (d.dob != null) 'dob': d.dob,
    };
    if (fields.isEmpty) return;
    try {
      await _api.patch('/me/profile', body: fields);
    } catch (_) {
      // Registration already succeeded; profile details can be edited later.
    }
  }

  static Future<void> logout() async {
    try {
      await _api.post('/auth/logout', body: {});
    } catch (_) {}
    await _api.clearSession();
  }

  static Future<String?> _sportIdFor(String? name) async {
    if (name == null) return null;
    try {
      final sports = await _api.get('/sports', auth: false) as List<dynamic>;
      final match = sports.cast<Map<String, dynamic>>().where(
          (s) => (s['name'] as String).toLowerCase() == name.toLowerCase());
      return match.isEmpty ? null : match.first['id'] as String;
    } catch (_) {
      return null;
    }
  }
}
