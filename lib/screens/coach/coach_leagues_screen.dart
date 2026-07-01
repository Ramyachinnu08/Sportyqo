import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'select_players_screen.dart';

class CoachLeaguesScreen extends StatelessWidget {
  const CoachLeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          child: const Center(
                              child: Text('🦅',
                                  style: TextStyle(
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
                                const Expanded(
                                  child: Text(
                                      'Falcons U16 Premier League',
                                      style: TextStyle(
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
                                  child: const Text(
                                      'Active',
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
                              const Text(
                                  'U16  •  Cricket  •  T20',
                                  style: TextStyle(
                                      color: Colors
                                          .white54,
                                      fontSize:
                                      13)),
                              const SizedBox(
                                  height: 2),
                              const Text(
                                  '8 Teams  •  Bangalore, Karnataka',
                                  style: TextStyle(
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
                      subtitle: '8 Teams',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const _TeamsScreen())),
                    ),
                    const SizedBox(height: 10),
                    _LeagueMenuItem(
                      icon: Icons
                          .calendar_today_outlined,
                      title: 'Matches',
                      subtitle: '12 Matches',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const _MatchesScreen())),
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
                              builder: (_) =>
                              const _StandingsScreen())),
                    ),
                    const SizedBox(height: 10),
                    _LeagueMenuItem(
                      icon: Icons.person_outline,
                      title: 'Players',
                      subtitle: '64 Players',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const SelectPlayersScreen(
                                teamName:
                                'Falcons FC',
                                matchName:
                                'Falcons FC vs Warriors United',
                              ))),
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

class _TeamsScreen extends StatelessWidget {
  const _TeamsScreen();

  final List<Map<String, dynamic>> _teams =
  const [
    {'name': 'Falcons FC', 'players': 8, 'wins': 5, 'emoji': '🦅'},
    {'name': 'Warriors United', 'players': 8, 'wins': 4, 'emoji': '⚔️'},
    {'name': 'Royal Strikers', 'players': 8, 'wins': 4, 'emoji': '👑'},
    {'name': 'Blaze Cricket Club', 'players': 8, 'wins': 3, 'emoji': '🔥'},
    {'name': 'Titans Academy', 'players': 8, 'wins': 3, 'emoji': '⚡'},
    {'name': 'Rising Stars', 'players': 8, 'wins': 2, 'emoji': '⭐'},
    {'name': 'Victory XI', 'players': 8, 'wins': 2, 'emoji': '🏆'},
    {'name': 'Eagle Hearts', 'players': 8, 'wins': 1, 'emoji': '🦅'},
  ];

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
              child: ListView.separated(
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

class _MatchesScreen extends StatelessWidget {
  const _MatchesScreen();

  final List<Map<String, dynamic>> _matches =
  const [
    {'team1': 'Falcons FC', 'team2': 'Warriors United', 'date': '24 May 2025', 'time': '06:00 PM', 'status': 'Upcoming', 'statusColor': Color(0xFF1A6BFF)},
    {'team1': 'Royal Strikers', 'team2': 'Blaze Cricket Club', 'date': '22 May 2025', 'time': '04:00 PM', 'status': 'Completed', 'statusColor': Color(0xFF00C853)},
    {'team1': 'Titans Academy', 'team2': 'Rising Stars', 'date': '20 May 2025', 'time': '05:00 PM', 'status': 'Completed', 'statusColor': Color(0xFF00C853)},
    {'team1': 'Victory XI', 'team2': 'Eagle Hearts', 'date': '18 May 2025', 'time': '03:00 PM', 'status': 'Completed', 'statusColor': Color(0xFF00C853)},
    {'team1': 'Falcons FC', 'team2': 'Royal Strikers', 'date': '26 May 2025', 'time': '06:00 PM', 'status': 'Upcoming', 'statusColor': Color(0xFF1A6BFF)},
  ];

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
              child: ListView.separated(
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

class _StandingsScreen extends StatelessWidget {
  const _StandingsScreen();

  final List<Map<String, dynamic>> _standings =
  const [
    {'pos': 1, 'team': 'Falcons FC', 'p': 10, 'w': 7, 'l': 2, 'pts': 14, 'emoji': '🦅'},
    {'pos': 2, 'team': 'Warriors United', 'p': 10, 'w': 6, 'l': 3, 'pts': 12, 'emoji': '⚔️'},
    {'pos': 3, 'team': 'Royal Strikers', 'p': 10, 'w': 5, 'l': 4, 'pts': 10, 'emoji': '👑'},
    {'pos': 4, 'team': 'Blaze Cricket Club', 'p': 10, 'w': 4, 'l': 5, 'pts': 8, 'emoji': '🔥'},
    {'pos': 5, 'team': 'Titans Academy', 'p': 10, 'w': 3, 'l': 6, 'pts': 6, 'emoji': '⚡'},
    {'pos': 6, 'team': 'Rising Stars', 'p': 10, 'w': 3, 'l': 6, 'pts': 6, 'emoji': '⭐'},
    {'pos': 7, 'team': 'Victory XI', 'p': 10, 'w': 2, 'l': 7, 'pts': 4, 'emoji': '🏆'},
    {'pos': 8, 'team': 'Eagle Hearts', 'p': 10, 'w': 1, 'l': 8, 'pts': 2, 'emoji': '🦅'},
  ];

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
              child: ListView.separated(
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