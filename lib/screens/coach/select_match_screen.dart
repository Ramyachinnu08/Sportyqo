import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'select_players_screen.dart';

class SelectMatchScreen extends StatefulWidget {
  final String leagueName;
  const SelectMatchScreen({super.key, required this.leagueName});

  @override
  State<SelectMatchScreen> createState() => _SelectMatchScreenState();
}

class _SelectMatchScreenState extends State<SelectMatchScreen> {
  int _tabIndex = 0;

  final List<Map<String, dynamic>> _matches = [
    {'id': '1', 'team1': 'Falcons FC', 'team2': 'Warriors United', 'date': '24 May 2025', 'time': '06:00 PM', 'venue': 'Green Field Arena', 'status': 'Upcoming'},
    {'id': '2', 'team1': 'Royal Strikers', 'team2': 'Blaze Cricket Club', 'date': '22 May 2025', 'time': '04:00 PM', 'venue': 'City Stadium', 'status': 'Live'},
    {'id': '3', 'team1': 'Titans Academy', 'team2': 'Rising Stars', 'date': '20 May 2025', 'time': '05:00 PM', 'venue': 'Sports Complex', 'status': 'Completed'},
    {'id': '4', 'team1': 'Victory XI', 'team2': 'Eagle Hearts', 'date': '18 May 2025', 'time': '03:00 PM', 'venue': 'City Stadium', 'status': 'Completed'},
    {'id': '5', 'team1': 'Falcons FC', 'team2': 'Royal Strikers', 'date': '26 May 2025', 'time': '06:00 PM', 'venue': 'Green Field Arena', 'status': 'Upcoming'},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_tabIndex == 0) return _matches;
    if (_tabIndex == 1) return _matches.where((m) => m['status'] == 'Live').toList();
    if (_tabIndex == 2) return _matches.where((m) => m['status'] == 'Upcoming').toList();
    return _matches.where((m) => m['status'] == 'Completed').toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Live': return Colors.red;
      case 'Upcoming': return const Color(0xFF1A6BFF);
      case 'Completed': return const Color(0xFF00C853);
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Match', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(widget.leagueName, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // Tabs
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _Tab(label: 'All', isActive: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                  const SizedBox(width: 10),
                  _Tab(label: 'Live', isActive: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1), color: Colors.red),
                  const SizedBox(width: 10),
                  _Tab(label: 'Upcoming', isActive: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
                  const SizedBox(width: 10),
                  _Tab(label: 'Completed', isActive: _tabIndex == 3, onTap: () => setState(() => _tabIndex = 3), color: const Color(0xFF00C853)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No matches found', style: TextStyle(color: Colors.white38)))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final m = _filtered[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectPlayersScreen(
                          teamName: m['team1'] as String,
                          matchName: '${m['team1']} vs ${m['team2']}',
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A6BFF).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(child: Text('🦅', style: TextStyle(fontSize: 22))),
                                ),
                                const SizedBox(height: 6),
                                Text(m['team1'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                              ]),
                            ),
                            Column(children: [
                              const Text('VS', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w800, fontSize: 16)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _statusColor(m['status'] as String).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(children: [
                                  if (m['status'] == 'Live')
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), margin: const EdgeInsets.only(right: 4)),
                                  Text(m['status'] as String, style: TextStyle(color: _statusColor(m['status'] as String), fontSize: 11, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            ]),
                            Expanded(
                              child: Column(children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                                  child: const Center(child: Text('⚡', style: TextStyle(fontSize: 22))),
                                ),
                                const SizedBox(height: 6),
                                Text(m['team2'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 12),
                              const SizedBox(width: 4),
                              Text(m['date'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ]),
                            Row(children: [
                              const Icon(Icons.access_time, color: Colors.white38, size: 12),
                              const SizedBox(width: 4),
                              Text(m['time'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ]),
                            Row(children: [
                              const Icon(Icons.location_on_outlined, color: Colors.white38, size: 12),
                              const SizedBox(width: 4),
                              Text(m['venue'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ]),
                          ],
                        ),
                      ]),
                    ),
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

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;
  const _Tab({required this.label, required this.isActive, required this.onTap, this.color = const Color(0xFF1A6BFF)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white38, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}