import 'dart:convert';
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

  /// Partial profile update (edit-profile sheet). Any field may be omitted.
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> fields) async {
    return await _api.patch('/me/profile', body: fields)
        as Map<String, dynamic>;
  }

  /// Uploads a new profile photo (player or coach); returns the avatar URL.
  static Future<String?> uploadAvatar(String filePath) async {
    final data = await _api.postMultipart('/me/avatar',
        files: {'avatar': filePath}) as Map<String, dynamic>;
    return data['avatarUrl'] as String?;
  }

  // ── Academy history (editable "Academy Experience" list) ────────────────

  static Future<List<dynamic>> academyHistory() async {
    return await _api.get('/me/academy') as List<dynamic>;
  }

  static Future<Map<String, dynamic>> addAcademy({
    required String academy,
    String? role,
    int? startYear,
    int? endYear,
  }) async {
    return await _api.post('/me/academy', body: {
      'academy': academy,
      if (role != null && role.isNotEmpty) 'role': role,
      if (startYear != null) 'startYear': startYear,
      if (endYear != null) 'endYear': endYear,
    }) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateAcademy(
    String id, {
    required String academy,
    String? role,
    int? startYear,
    int? endYear,
  }) async {
    return await _api.patch('/me/academy/$id', body: {
      'academy': academy,
      if (role != null && role.isNotEmpty) 'role': role,
      if (startYear != null) 'startYear': startYear,
      if (endYear != null) 'endYear': endYear,
    }) as Map<String, dynamic>;
  }

  static Future<void> deleteAcademy(String id) async {
    await _api.delete('/me/academy/$id');
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

  /// Player picks their team after joining a league.
  static Future<Map<String, dynamic>> joinTeam(String teamId) async {
    return await _api.post('/teams/$teamId/join') as Map<String, dynamic>;
  }

  static Future<List<dynamic>> leagueStandings(String leagueId) async {
    return await _api.get('/leagues/$leagueId/standings') as List<dynamic>;
  }

  static Future<Map<String, dynamic>> leagueDetails(String leagueId) async {
    return await _api.get('/leagues/$leagueId') as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> leagueCode(String leagueId) async {
    return await _api.get('/leagues/$leagueId/code') as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> shareLeague(String leagueId) async {
    return await _api.post('/leagues/$leagueId/share') as Map<String, dynamic>;
  }

  /// Coach creates a league with teams. Returns the created league,
  /// including the 6-digit `leagueCode`.
  static Future<Map<String, dynamic>> createLeague({
    required String name,
    required String location,
    required String gender, // "Men's" | "Women's" | "Mixed"
    required String sportId,
    String? iconEmoji,
    String? season,
    required List<Map<String, String>> teams, // [{name, iconEmoji?}]
    String? logoPath,
    Map<int, String> teamLogoPaths = const {},
  }) async {
    final payload = {
      'name': name,
      'location': location,
      'gender': gender,
      'sportId': sportId,
      if (iconEmoji != null) 'iconEmoji': iconEmoji,
      if (season != null) 'season': season,
      'teams': teams,
    };
    final files = <String, String>{
      if (logoPath != null) 'logo': logoPath,
      for (final e in teamLogoPaths.entries) 'teamLogo_${e.key}': e.value,
    };
    return await _api.postMultipart('/leagues',
        fields: {'payload': jsonEncode(payload)},
        files: files) as Map<String, dynamic>;
  }

  /// Player discovery leaderboard (Dugout screen). Sorted by Qo score.
  static Future<List<dynamic>> discoverPlayers(
      {String? sport, String q = ''}) async {
    return await _api.get('/players/discover', query: {
      if (sport != null && sport != 'All') 'sport': sport,
      if (q.isNotEmpty) 'q': q,
      'limit': '50',
    }) as List<dynamic>;
  }

  /// Coach searches players across their leagues (select-players screen).
  static Future<List<dynamic>> searchPlayers({String q = ''}) async {
    return await _api.get('/players',
        query: q.isEmpty ? null : {'q': q}) as List<dynamic>;
  }

  static Future<void> followPlayer(String playerId) async {
    await _api.post('/players/$playerId/follow');
  }

  static Future<void> unfollowPlayer(String playerId) async {
    await _api.delete('/players/$playerId/follow');
  }

  /// Find-or-create a 1:1 chat thread with another user. Returns threadId.
  static Future<String> directThread(String userId) async {
    final data = await _api.post('/dugout/direct', body: {'userId': userId})
        as Map<String, dynamic>;
    return data['threadId'] as String;
  }

  static Future<List<dynamic>> coachCertifications() async {
    return await _api.get('/coach/certifications') as List<dynamic>;
  }

  /// Existing stat lines of a match (prefills the coach's edit table).
  static Future<List<dynamic>> matchStats(String matchId,
      {String? teamId}) async {
    return await _api.get('/matches/$matchId/stats',
        query: teamId == null ? null : {'teamId': teamId}) as List<dynamic>;
  }

  /// Coach saves a player's stat line for a match. Applies the Qo delta
  /// to the player's profile server-side and notifies the player.
  static Future<Map<String, dynamic>> savePlayerStats({
    required String teamId,
    required String playerId,
    required String matchId,
    required Map<String, dynamic> stats,
    required int qoPoints,
    double? rating,
  }) async {
    return await _api.patch('/teams/$teamId/players/$playerId/stats', body: {
      'matchId': matchId,
      'stats': stats,
      'qoPoints': qoPoints,
      if (rating != null) 'rating': rating,
    }) as Map<String, dynamic>;
  }

  /// Coach records a match outcome (feeds standings).
  static Future<Map<String, dynamic>> setMatchResult(
    String matchId, {
    required String homeScore,
    required String awayScore,
    String? winnerTeamId,
    String? resultSummary,
  }) async {
    return await _api.patch('/matches/$matchId/result', body: {
      'homeScore': homeScore,
      'awayScore': awayScore,
      'winnerTeamId': winnerTeamId,
      if (resultSummary != null) 'resultSummary': resultSummary,
    }) as Map<String, dynamic>;
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

  /// Coach creates a playbook item (drill/strategy/video/note).
  static Future<Map<String, dynamic>> createPlaybookItem({
    required String title,
    String? description,
    String kind = 'NOTE',
  }) async {
    return await _api.post('/playbook', body: {
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      'kind': kind,
    }) as Map<String, dynamic>;
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
