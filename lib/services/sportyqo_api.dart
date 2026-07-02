import 'api_client.dart';

/// Thin, typed wrappers over the backend endpoints the screens use.
/// All methods return the decoded `data` payload (see backend docs/API.md).
class SportyQoApi {
  static final _api = ApiClient.instance;

  // ── Player ────────────────────────────────────────────────────────────

  /// Everything the player home screen needs in one call:
  /// greeting, player {playerId, fullName, qoScore, sport}, activeLeague
  /// (with nested team) or null, upcomingMatch or null, notifications.
  static Future<Map<String, dynamic>> playerHome() async {
    final id = _api.userId;
    if (id == null) throw ApiException(401, 'UNAUTHORIZED', 'Not logged in');
    return await _api.get('/players/$id/home') as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> playerProfile() async {
    final id = _api.userId;
    if (id == null) throw ApiException(401, 'UNAUTHORIZED', 'Not logged in');
    return await _api.get('/players/$id/profile') as Map<String, dynamic>;
  }

  /// qoScore, qoJourney (monthly chart points), recentMatches (perf cards).
  static Future<Map<String, dynamic>> playerPerformance() async {
    final id = _api.userId;
    if (id == null) throw ApiException(401, 'UNAUTHORIZED', 'Not logged in');
    return await _api.get('/players/$id/performance') as Map<String, dynamic>;
  }

  /// Joins a league with the 6-digit code. Returns {joined, league:{id,name}}.
  /// Throws ApiException(code: 'CONFLICT') if already a member.
  static Future<Map<String, dynamic>> joinLeague(String code) async {
    return await _api.post('/leagues/join', body: {'code': code})
        as Map<String, dynamic>;
  }

  // ── Coach ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> coachDashboard() async {
    return await _api.get('/coach/dashboard') as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> coachPerformance() async {
    return await _api.get('/coach/performance') as Map<String, dynamic>;
  }

  // ── Shared ────────────────────────────────────────────────────────────

  static Future<List<dynamic>> sports() async {
    return await _api.get('/sports', auth: false) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> me() async {
    return await _api.get('/me') as Map<String, dynamic>;
  }

  static Future<List<dynamic>> myLeagues() async {
    return await _api.get('/leagues') as List<dynamic>;
  }

  static Future<List<dynamic>> leagueTeams(String leagueId) async {
    return await _api.get('/leagues/$leagueId/teams') as List<dynamic>;
  }

  static Future<Map<String, dynamic>> teamRoster(String teamId) async {
    return await _api.get('/teams/$teamId/roster') as Map<String, dynamic>;
  }

  static Future<List<dynamic>> notifications({bool unreadOnly = false}) async {
    return await _api.get('/notifications',
        query: unreadOnly ? {'unread': 'true'} : null) as List<dynamic>;
  }

  static Future<void> markNotificationsRead({List<String>? ids}) async {
    await _api.post('/notifications/read',
        body: ids == null ? <String, dynamic>{} : {'ids': ids});
  }

  static Future<List<dynamic>> playbook(
      {String? sportId, String? kind, String? q}) async {
    return await _api.get('/playbook', query: {
      if (sportId != null) 'sportId': sportId,
      if (kind != null) 'kind': kind,
      if (q != null && q.isNotEmpty) 'q': q,
    }) as List<dynamic>;
  }

  static Future<List<dynamic>> dugoutThreads() async {
    return await _api.get('/dugout') as List<dynamic>;
  }

  static Future<List<dynamic>> dugoutMessages(String threadId) async {
    return await _api.get('/dugout/$threadId/messages') as List<dynamic>;
  }

  static Future<Map<String, dynamic>> sendDugoutMessage(
      String threadId, String body) async {
    return await _api.post('/dugout/$threadId/messages', body: {'body': body})
        as Map<String, dynamic>;
  }

  static Future<List<dynamic>> matches(
      {String? leagueId, String? teamId, String? status}) async {
    return await _api.get('/matches', query: {
      if (leagueId != null) 'leagueId': leagueId,
      if (teamId != null) 'teamId': teamId,
      if (status != null) 'status': status,
    }) as List<dynamic>;
  }
}
