import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'select_players_screen.dart';
import '../../services/sportyqo_api.dart';

class SelectMatchScreen extends StatefulWidget {
  final String leagueName;
  final String leagueId;
  const SelectMatchScreen(
      {super.key, required this.leagueName, required this.leagueId});

  @override
  State<SelectMatchScreen> createState() => _SelectMatchScreenState();
}

class _SelectMatchScreenState extends State<SelectMatchScreen> {
  int _tabIndex = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _matches = [];

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
          final home = m['homeTeam'] as Map<String, dynamic>?;
          final away = m['awayTeam'] as Map<String, dynamic>?;
          return {
            'id': m['id'],
            'team1': home?['name'] ?? 'TBD',
            'team1Id': home?['id'],
            'team2': away?['name'] ?? 'TBD',
            'team2Id': away?['id'],
            'date': dt == null
                ? ''
                : '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}',
            'time': dt == null
                ? ''
                : '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}',
            'venue': m['venue'] ?? 'Venue TBD',
            'status': status == 'COMPLETED'
                ? 'Completed'
                : status == 'LIVE'
                    ? 'Live'
                    : 'Upcoming',
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _pickTeam(Map<String, dynamic> m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Whose stats do you want to update?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            for (final side in ['team1', 'team2'])
              if (m['${side}Id'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectPlayersScreen(
                              teamId: m['${side}Id'] as String,
                              matchId: m['id'] as String,
                              teamName: m[side] as String,
                              matchName: '${m['team1']} vs ${m['team2']}',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1A6BFF).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(m[side] as String,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

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
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A6BFF)))
                  : _filtered.isEmpty
                  ? const Center(child: Text('No matches found', style: TextStyle(color: Colors.white38)))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final m = _filtered[i];
                  return GestureDetector(
                    onTap: () => _pickTeam(m),
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