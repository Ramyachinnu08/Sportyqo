import 'package:flutter/material.dart';
import 'select_players_screen.dart';
import 'select_match_screen.dart';
import '../../services/sportyqo_api.dart';

class CoachLeaguesScreen extends StatefulWidget {
  const CoachLeaguesScreen({super.key});

  @override
  State<CoachLeaguesScreen> createState() => _CoachLeaguesScreenState();
}

class _CoachLeaguesScreenState extends State<CoachLeaguesScreen> {
  List<Map<String, dynamic>> _leagues = [];
  int _selected = 0;
  bool _loading = true;

  Map<String, dynamic>? get _league =>
      _leagues.isEmpty ? null : _leagues[_selected];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.myLeagues();
      if (!mounted) return;
      setState(() {
        _leagues = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00C853))),
      );
    }
    if (_league == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text('View League',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const Expanded(
              child: Center(
                child: Text('You have not created any leagues yet',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
              ),
            ),
          ]),
        ),
      );
    }
    final counts =
        (_league!['counts'] as Map<String, dynamic>?) ?? const {};
    final teamCount = (counts['teams'] as num?)?.toInt() ?? 0;
    final playerCount = (counts['players'] as num?)?.toInt() ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () =>
                      Navigator.pop(context),
                  child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20),
                ),
                const SizedBox(width: 16),
                const Text('View League',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w800)),
              ]),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
                child: Column(
                  children: [
                    if (_leagues.length > 1) ...[
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _leagues.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, i) => GestureDetector(
                            onTap: () => setState(() => _selected = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == _selected
                                    ? const Color(0xFF00C853)
                                        .withOpacity(0.15)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: i == _selected
                                        ? const Color(0xFF00C853)
                                        : Colors.white12),
                              ),
                              child: Text(
                                  _leagues[i]['name'] as String? ?? '',
                                  style: TextStyle(
                                      color: i == _selected
                                          ? const Color(0xFF00C853)
                                          : Colors.white60,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── League Card ──
                    Container(
                      padding:
                      const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF111111),
                        borderRadius:
                        BorderRadius.circular(
                            16),
                        border: Border.all(
                            color: Colors.white10),
                      ),
                      child: Row(children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF0A1A3A),
                            borderRadius:
                            BorderRadius
                                .circular(12),
                            border: Border.all(
                                color: const Color(
                                    0xFF1A6BFF)
                                    .withOpacity(
                                    0.3)),
                          ),
                          child: Center(
                              child: Text(
                                  _league!['icon'] as String? ?? '🏆',
                                  style: const TextStyle(
                                      fontSize:
                                      32))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(
                                      _league!['name'] as String? ?? '',
                                      style: const TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight:
                                          FontWeight
                                              .w800,
                                          fontSize:
                                          15)),
                                ),
                                Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal:
                                      10,
                                      vertical: 4),
                                  decoration:
                                  BoxDecoration(
                                    color: const Color(
                                        0xFF00C853)
                                        .withOpacity(
                                        0.15),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        20),
                                    border: Border.all(
                                        color: const Color(
                                            0xFF00C853)
                                            .withOpacity(
                                            0.3)),
                                  ),
                                  child: Text(
                                      (_league!['status'] as String? ??
                                              'ACTIVE') ==
                                          'ACTIVE'
                                          ? 'Active'
                                          : 'Ended',
                                      style: TextStyle(
                                          color: Color(
                                              0xFF00C853),
                                          fontSize:
                                          11,
                                          fontWeight:
                                          FontWeight
                                              .w700)),
                                ),
                              ]),
                              const SizedBox(
                                  height: 4),
                              Text(
                                  [
                                    (_league!['sport'] as Map<String,
                                            dynamic>?)?['name'] ??
                                        'Sport',
                                    _league!['gender'] == 'MENS'
                                        ? "Men's"
                                        : _league!['gender'] == 'WOMENS'
                                            ? "Women's"
                                            : 'Mixed',
                                  ].join('  •  '),
                                  style: const TextStyle(
                                      color: Colors
                                          .white54,
                                      fontSize:
                                      13)),
                              const SizedBox(
                                  height: 2),
                              Text(
                                  '$teamCount Teams  •  ${_league!['location'] ?? ''}',
                                  style: const TextStyle(
                                      color: Colors
                                          .white38,
                                      fontSize:
                                      12)),
                            ],
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 12),

                    // ── Menu Items ──
                    _LeagueMenuItem(
                      icon: Icons.people_outline,
                      title: 'Teams',
                      subtitle: '$teamCount Teams',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _TeamsScreen(
                                  leagueId:
                                      _league!['id'] as String))),
                    ),
                    const SizedBox(height: 10),
                    _LeagueMenuItem(
                      icon: Icons
                          .calendar_today_outlined,
                      title: 'Matches',
                      subtitle: 'Schedule & results',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _MatchesScreen(
                                  leagueId:
                                      _league!['id'] as String))),
                    ),
                    const SizedBox(height: 10),
                    _LeagueMenuItem(
                      icon:
                      Icons.bar_chart_outlined,
                      title: 'Standings',
                      subtitle: 'View points table',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _StandingsScreen(
                                  leagueId:
                                      _league!['id'] as String))),
                    ),
                    const SizedBox(height: 10),
                    _LeagueMenuItem(
                      icon: Icons.edit_note,
                      title: 'Update Stats',
                      subtitle: 'Enter match performance',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SelectMatchScreen(
                                  leagueId:
                                      _league!['id'] as String,
                                  leagueName: _league!['name']
                                          as String? ??
                                      ''))),
                    ),
                    const SizedBox(height: 10),
                    _LeagueMenuItem(
                      icon: Icons.person_outline,
                      title: 'Players',
                      subtitle: '$playerCount Players',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SelectPlayersScreen())),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── League Menu Item ──────────────────────────────────────────────────

class _LeagueMenuItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _LeagueMenuItem(
      {required this.icon,
        required this.title,
        required this.subtitle,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: Colors.white10),
        ),
        child: Row(children: [
          Icon(icon,
              color: Colors.white60, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward,
              color: Colors.white38, size: 20),
        ]),
      ),
    );
  }
}

// ── Teams Screen ──────────────────────────────────────────────────────

class _TeamsScreen extends StatefulWidget {
  const _TeamsScreen({required this.leagueId});
  final String leagueId;

  @override
  State<_TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<_TeamsScreen> {
  List<Map<String, dynamic>> _teams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        SportyQoApi.leagueTeams(widget.leagueId),
        SportyQoApi.leagueStandings(widget.leagueId),
      ]);
      if (!mounted) return;
      final standings = results[1].cast<Map<String, dynamic>>();
      final winsByTeam = {
        for (final st in standings)
          st['teamId'] as String: (st['wins'] as num?)?.toInt() ?? 0,
      };
      setState(() {
        _teams = results[0].cast<Map<String, dynamic>>()
            .map((t) => {
                  'id': t['id'],
                  'name': t['name'] ?? '',
                  'players': (t['rosterCount'] as num?)?.toInt() ?? 0,
                  'wins': winsByTeam[t['id'] as String] ?? 0,
                  'emoji': t['icon'] ?? '🏅',
                })
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20)),
                const SizedBox(width: 16),
                const Text('Teams',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w800)),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853)
                        .withOpacity(0.15),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: const Text('8 Teams',
                      style: TextStyle(
                          color:
                          Color(0xFF00C853),
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00C853)))
                  : _teams.isEmpty
                      ? const Center(
                          child: Text('No teams yet',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : ListView.separated(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: _teams.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final t = _teams[i];
                  return Container(
                    padding:
                    const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF111111),
                      borderRadius:
                      BorderRadius.circular(
                          14),
                      border: Border.all(
                          color: Colors.white10),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFF1A6BFF)
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius
                              .circular(12),
                        ),
                        child: Center(
                            child: Text(
                                t['emoji']
                                as String,
                                style: const TextStyle(
                                    fontSize:
                                    26))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                                t['name']
                                as String,
                                style: const TextStyle(
                                    color:
                                    Colors.white,
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                    fontSize:
                                    14)),
                            Text(
                                '${t['players']} Players  •  ${t['wins']} Wins',
                                style: const TextStyle(
                                    color: Colors
                                        .white38,
                                    fontSize:
                                    12)),
                          ],
                        ),
                      ),
                      const Icon(
                          Icons.chevron_right,
                          color: Colors.white24),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Matches Screen ────────────────────────────────────────────────────

class _MatchesScreen extends StatefulWidget {
  const _MatchesScreen({required this.leagueId});
  final String leagueId;

  @override
  State<_MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<_MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.matches(leagueId: widget.leagueId);
      if (!mounted) return;
      setState(() {
        _matches = data.cast<Map<String, dynamic>>().map((m) {
          final dt =
              DateTime.tryParse(m['scheduledAt'] as String? ?? '')?.toLocal();
          final status = (m['status'] as String? ?? 'SCHEDULED').toUpperCase();
          return {
            'team1':
                (m['homeTeam'] as Map<String, dynamic>?)?['name'] ?? 'TBD',
            'team2':
                (m['awayTeam'] as Map<String, dynamic>?)?['name'] ?? 'TBD',
            'date': dt == null
                ? ''
                : '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}',
            'time': dt == null
                ? ''
                : '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}',
            'status': status == 'COMPLETED'
                ? 'Completed'
                : status == 'LIVE'
                    ? 'Live'
                    : status == 'CANCELLED'
                        ? 'Cancelled'
                        : 'Upcoming',
            'statusColor': status == 'COMPLETED'
                ? const Color(0xFF00C853)
                : status == 'LIVE'
                    ? Colors.redAccent
                    : status == 'CANCELLED'
                        ? Colors.white38
                        : const Color(0xFF1A6BFF),
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20)),
                const SizedBox(width: 16),
                const Text('Matches',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A6BFF)))
                  : _matches.isEmpty
                      ? const Center(
                          child: Text('No matches scheduled yet',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : ListView.separated(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: _matches.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final m = _matches[i];
                  return Container(
                    padding:
                    const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFF111111),
                      borderRadius:
                      BorderRadius.circular(
                          14),
                      border: Border.all(
                          color: Colors.white10),
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  m['team1']
                                  as String,
                                  style: const TextStyle(
                                      color: Colors
                                          .white,
                                      fontWeight:
                                      FontWeight
                                          .w700),
                                  textAlign:
                                  TextAlign
                                      .center)),
                          const Text('VS',
                              style: TextStyle(
                                  color: Colors
                                      .white38,
                                  fontWeight:
                                  FontWeight
                                      .w800)),
                          Expanded(
                              child: Text(
                                  m['team2']
                                  as String,
                                  style: const TextStyle(
                                      color: Colors
                                          .white,
                                      fontWeight:
                                      FontWeight
                                          .w700),
                                  textAlign:
                                  TextAlign
                                      .center)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                          color: Colors.white10,
                          height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Text(
                              '${m['date']}  •  ${m['time']}',
                              style: const TextStyle(
                                  color:
                                  Colors.white38,
                                  fontSize: 12)),
                          Container(
                            padding: const EdgeInsets
                                .symmetric(
                                horizontal: 10,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: (m['statusColor']
                              as Color)
                                  .withOpacity(0.15),
                              borderRadius:
                              BorderRadius
                                  .circular(20),
                            ),
                            child: Text(
                                m['status']
                                as String,
                                style: TextStyle(
                                    color: m[
                                    'statusColor']
                                    as Color,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight
                                        .w700)),
                          ),
                        ],
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Standings Screen ──────────────────────────────────────────────────

class _StandingsScreen extends StatefulWidget {
  const _StandingsScreen({required this.leagueId});
  final String leagueId;

  @override
  State<_StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<_StandingsScreen> {
  List<Map<String, dynamic>> _standings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.leagueStandings(widget.leagueId);
      if (!mounted) return;
      setState(() {
        _standings = data
            .cast<Map<String, dynamic>>()
            .map((st) => {
                  'pos': st['rank'],
                  'team': st['name'] ?? '',
                  'p': (st['played'] as num?)?.toInt() ?? 0,
                  'w': (st['wins'] as num?)?.toInt() ?? 0,
                  'l': (st['losses'] as num?)?.toInt() ?? 0,
                  'pts': (st['points'] as num?)?.toInt() ?? 0,
                  'emoji': st['icon'] ?? '🏅',
                })
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20)),
                const SizedBox(width: 16),
                const Text('Standings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6BFF)
                      .withOpacity(0.15),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: const Row(children: [
                  SizedBox(
                      width: 30,
                      child: Text('#',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w700))),
                  Expanded(
                      child: Text('Team',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w700))),
                  SizedBox(
                      width: 30,
                      child: Text('P',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w700),
                          textAlign:
                          TextAlign.center)),
                  SizedBox(
                      width: 30,
                      child: Text('W',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w700),
                          textAlign:
                          TextAlign.center)),
                  SizedBox(
                      width: 30,
                      child: Text('L',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w700),
                          textAlign:
                          TextAlign.center)),
                  SizedBox(
                      width: 40,
                      child: Text('PTS',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w700),
                          textAlign:
                          TextAlign.center)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00C853)))
                  : _standings.isEmpty
                      ? const Center(
                          child: Text('No standings yet — play some matches',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : ListView.separated(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: _standings.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final s = _standings[i];
                  final isTop =
                      (s['pos'] as int) <= 3;
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12),
                    decoration: BoxDecoration(
                      color: isTop
                          ? const Color(0xFF1A6BFF)
                          .withOpacity(0.08)
                          : const Color(0xFF111111),
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                          color: isTop
                              ? const Color(
                              0xFF1A6BFF)
                              .withOpacity(0.2)
                              : Colors.white10),
                    ),
                    child: Row(children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                            '${s['pos']}',
                            style: TextStyle(
                                color: isTop
                                    ? const Color(
                                    0xFF1A6BFF)
                                    : Colors.white38,
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 13)),
                      ),
                      Expanded(
                        child: Row(children: [
                          Text(
                              s['emoji'] as String,
                              style: const TextStyle(
                                  fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  s['team']
                                  as String,
                                  style: const TextStyle(
                                      color:
                                      Colors.white,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                      fontSize: 13),
                                  overflow:
                                  TextOverflow
                                      .ellipsis)),
                        ]),
                      ),
                      SizedBox(
                          width: 30,
                          child: Text('${s['p']}',
                              style: const TextStyle(
                                  color:
                                  Colors.white54,
                                  fontSize: 13),
                              textAlign:
                              TextAlign.center)),
                      SizedBox(
                          width: 30,
                          child: Text('${s['w']}',
                              style: const TextStyle(
                                  color:
                                  Colors.white54,
                                  fontSize: 13),
                              textAlign:
                              TextAlign.center)),
                      SizedBox(
                          width: 30,
                          child: Text('${s['l']}',
                              style: const TextStyle(
                                  color:
                                  Colors.white54,
                                  fontSize: 13),
                              textAlign:
                              TextAlign.center)),
                      SizedBox(
                        width: 40,
                        child: Text('${s['pts']}',
                            style: TextStyle(
                                color: isTop
                                    ? const Color(
                                    0xFF1A6BFF)
                                    : Colors.white,
                                fontWeight:
                                FontWeight.w800,
                                fontSize: 14),
                            textAlign:
                            TextAlign.center),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}