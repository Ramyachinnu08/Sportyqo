import 'package:flutter/material.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

class SelectPlayersScreen extends StatefulWidget {
  final String teamName;
  final String matchName;
  final String? teamId;
  final String? matchId;
  const SelectPlayersScreen({
    super.key,
    this.teamName = 'Players',
    this.matchName = '',
    this.teamId,
    this.matchId,
  });

  @override
  State<SelectPlayersScreen> createState() =>
      _SelectPlayersScreenState();
}

class _SelectPlayersScreenState
    extends State<SelectPlayersScreen> {
  int _tabIndex = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _players = [];

  static const _palette = [
    Color(0xFF1A3A5C), Color(0xFF1A5C3A), Color(0xFF3A1A5C),
    Color(0xFF5C3A1A), Color(0xFF1A5C5C), Color(0xFF5C1A3A),
    Color(0xFF3A5C1A), Color(0xFF5C5C1A),
  ];

  static String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      List<Map<String, dynamic>> rows;
      if (widget.teamId != null) {
        // Roster of a specific team, prefilled with any saved stats
        // for the selected match.
        final results = await Future.wait([
          SportyQoApi.teamRoster(widget.teamId!),
          if (widget.matchId != null)
            SportyQoApi.matchStats(widget.matchId!, teamId: widget.teamId),
        ]);
        final roster = ((results[0] as Map<String, dynamic>)['roster']
                as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final statLines = results.length > 1
            ? (results[1] as List<dynamic>).cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];
        final byPlayer = {
          for (final l in statLines) l['playerId'] as String: l,
        };
        rows = List.generate(roster.length, (i) {
          final r = roster[i];
          final line = byPlayer[r['playerId'] as String];
          final stats =
              (line?['stats'] as Map<String, dynamic>?) ?? const {};
          return {
            'id': r['playerId'],
            'name': r['fullName'] ?? 'Player',
            'initials': _initialsOf(r['fullName'] as String? ?? '?'),
            'role': r['position'] ?? 'Player',
            'runs': (stats['runs'] as num?)?.toInt() ?? 0,
            'fours': (stats['fours'] as num?)?.toInt() ?? 0,
            'sixes': (stats['sixes'] as num?)?.toInt() ?? 0,
            'wkts': (stats['wickets'] as num?)?.toInt() ?? 0,
            'catches': (stats['catches'] as num?)?.toInt() ?? 0,
            'runOuts': (stats['runOuts'] as num?)?.toInt() ?? 0,
            'pts': ((line?['qoPoints'] as num?) ?? 0).toDouble(),
            'color': _palette[i % _palette.length],
          };
        });
      } else {
        // All players across the coach's leagues.
        final data = await SportyQoApi.searchPlayers();
        rows = List.generate(data.length, (i) {
          final r = data[i] as Map<String, dynamic>;
          return {
            'id': r['id'],
            'name': r['fullName'] ?? 'Player',
            'initials': _initialsOf(r['fullName'] as String? ?? '?'),
            'role': r['playerCode'] ?? 'Player',
            'runs': 0,
            'fours': 0,
            'sixes': 0,
            'wkts': 0,
            'catches': 0,
            'runOuts': 0,
            'pts': ((r['qoScore'] as num?) ?? 0).toDouble(),
            'color': _palette[i % _palette.length],
          };
        });
      }
      if (!mounted) return;
      setState(() {
        _players = rows;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveToBackend(int index, Map<String, dynamic> updated) async {
    if (widget.teamId == null || widget.matchId == null) return;
    try {
      await SportyQoApi.savePlayerStats(
        teamId: widget.teamId!,
        playerId: updated['id'] as String,
        matchId: widget.matchId!,
        stats: {
          'runs': updated['runs'],
          'fours': updated['fours'],
          'sixes': updated['sixes'],
          'wickets': updated['wkts'],
          'catches': updated['catches'],
          'runOuts': updated['runOuts'],
        },
        qoPoints: (updated['pts'] as double).round(),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not save stats: ${e.message}'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6BFF).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.4)),
                  ),
                  child: const Center(child: Text('🦅', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Text(widget.teamName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ),

            const SizedBox(height: 12),

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Column(children: [
                      Text('Players', style: TextStyle(color: _tabIndex == 0 ? const Color(0xFF1A6BFF) : Colors.white38, fontWeight: _tabIndex == 0 ? FontWeight.w700 : FontWeight.w400, fontSize: 15)),
                      const SizedBox(height: 6),
                      Container(height: 2, color: _tabIndex == 0 ? const Color(0xFF1A6BFF) : Colors.transparent),
                    ]),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Column(children: [
                      Text('Team Summary', style: TextStyle(color: _tabIndex == 1 ? const Color(0xFF1A6BFF) : Colors.white38, fontWeight: _tabIndex == 1 ? FontWeight.w700 : FontWeight.w400, fontSize: 15)),
                      const SizedBox(height: 6),
                      Container(height: 2, color: _tabIndex == 1 ? const Color(0xFF1A6BFF) : Colors.transparent),
                    ]),
                  ),
                ),
              ]),
            ),

            Container(height: 1, color: Colors.white10),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1A6BFF)))
                  : _players.isEmpty
                      ? const Center(
                          child: Text('No players yet',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : _tabIndex == 0
                          ? _buildPlayersList()
                          : _buildTeamSummary(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList() {
    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: const [
            Expanded(child: Text('Player', style: TextStyle(color: Colors.white38, fontSize: 12))),
            SizedBox(width: 50, child: Text('Runs', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center)),
            SizedBox(width: 50, child: Text('Wkts', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center)),
            SizedBox(width: 50, child: Text('Pts', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center)),
            SizedBox(width: 50),
          ]),
        ),

        const Divider(color: Colors.white10, height: 1),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _players.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 16),
            itemBuilder: (context, i) {
              final p = _players[i];
              return Row(children: [
                // Avatar
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: (p['color'] as Color).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(p['initials'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                ),
                const SizedBox(width: 10),
                // Name + role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(p['role'] as String, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                // Runs
                SizedBox(width: 50, child: Text('${p['runs']}', style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)),
                // Wkts
                SizedBox(width: 50, child: Text('${p['wkts']}', style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)),
                // Pts
                SizedBox(width: 50, child: Text('${p['pts']}', style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)),
                // Edit button
                GestureDetector(
                  onTap: widget.matchId == null
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _EditPlayerStatsScreen(
                                  player: p,
                                  onSave: (updated) {
                                    setState(() => _players[i] = updated);
                                    _saveToBackend(i, updated);
                                  }))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A6BFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.3)),
                    ),
                    child: const Text('Edit', style: TextStyle(color: Color(0xFF1A6BFF), fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
              ]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSummary() {
    final totalRuns = _players.fold<int>(0, (sum, p) => sum + (p['runs'] as int));
    final totalPts = _players.fold<double>(0, (sum, p) => sum + (p['pts'] as double));
    final sorted = List<Map<String, dynamic>>.from(_players)..sort((a, b) => (b['pts'] as double).compareTo(a['pts'] as double));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total Runs', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  Text('$totalRuns', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const Text('This match', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
                Container(height: 50, width: 1, color: Colors.white10),
                Column(children: [
                  const Text('Total Qo Points', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  Text(totalPts.toStringAsFixed(1), style: const TextStyle(color: Color(0xFF1A6BFF), fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
                Container(height: 50, width: 1, color: Colors.white10),
                Column(children: [
                  const Text('Result', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const Text('–', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Top Performers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Performers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                Row(children: const [
                  SizedBox(width: 30),
                  Text('Player', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Spacer(),
                  Text('Qo Points', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                ...sorted.take(3).toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      SizedBox(width: 30, child: Text('${i + 1}', style: const TextStyle(color: Colors.white38, fontSize: 13))),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: (p['color'] as Color).withOpacity(0.6), shape: BoxShape.circle),
                        child: Center(child: Text(p['initials'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13))),
                      Text('${p['pts']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match Saved! ✅'), backgroundColor: Color(0xFF1A6BFF)));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Match', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Player Stats Screen ──────────────────────────────────────────

class _EditPlayerStatsScreen extends StatefulWidget {
  final Map<String, dynamic> player;
  final Function(Map<String, dynamic>) onSave;
  const _EditPlayerStatsScreen({required this.player, required this.onSave});

  @override
  State<_EditPlayerStatsScreen> createState() => _EditPlayerStatsScreenState();
}

class _EditPlayerStatsScreenState extends State<_EditPlayerStatsScreen> {
  late int _runs;
  late int _fours;
  late int _sixes;
  late int _wickets;
  late int _catches;
  late int _runOuts;
  bool _strikeRateBonus = true;
  bool _boundaryBonus = true;

  @override
  void initState() {
    super.initState();
    _runs = (widget.player['runs'] as num?)?.toInt() ?? 0;
    _fours = (widget.player['fours'] as num?)?.toInt() ?? 0;
    _sixes = (widget.player['sixes'] as num?)?.toInt() ?? 0;
    _wickets = (widget.player['wkts'] as num?)?.toInt() ?? 0;
    _catches = (widget.player['catches'] as num?)?.toInt() ?? 0;
    _runOuts = (widget.player['runOuts'] as num?)?.toInt() ?? 0;
  }

  double _calculatePts() {
    double pts = 0;
    pts += _runs * 0.3;
    pts += _fours * 0.5;
    pts += _sixes * 1.0;
    pts += _wickets * 3.0;
    pts += _catches * 1.0;
    pts += _runOuts * 1.5;
    if (_strikeRateBonus) pts += 2.0;
    if (_boundaryBonus) pts += 1.5;
    return double.parse(pts.toStringAsFixed(1));
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text('Edit Player Stats', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
            ),

            const SizedBox(height: 16),

            // Player info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: (widget.player['color'] as Color).withOpacity(0.6), shape: BoxShape.circle),
                  child: Center(child: Text(widget.player['initials'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.player['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(widget.player['role'] as String, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ]),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batting
                      const Text('Batting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 12),
                      _StatRow(label: 'Runs Scored', value: _runs, onDec: () => setState(() => _runs = (_runs - 1).clamp(0, 999)), onInc: () => setState(() => _runs++)),
                      _StatRow(label: '4s', value: _fours, onDec: () => setState(() => _fours = (_fours - 1).clamp(0, 99)), onInc: () => setState(() => _fours++)),
                      _StatRow(label: '6s', value: _sixes, onDec: () => setState(() => _sixes = (_sixes - 1).clamp(0, 99)), onInc: () => setState(() => _sixes++)),

                      const SizedBox(height: 16),
                      // Bowling
                      const Text('Bowling', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 12),
                      _StatRow(label: 'Wickets Taken', value: _wickets, onDec: () => setState(() => _wickets = (_wickets - 1).clamp(0, 10)), onInc: () => setState(() => _wickets++)),

                      const SizedBox(height: 16),
                      // Fielding
                      const Text('Fielding', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 12),
                      _StatRow(label: 'Catches', value: _catches, onDec: () => setState(() => _catches = (_catches - 1).clamp(0, 10)), onInc: () => setState(() => _catches++)),
                      _StatRow(label: 'Run Outs / Assists', value: _runOuts, onDec: () => setState(() => _runOuts = (_runOuts - 1).clamp(0, 10)), onInc: () => setState(() => _runOuts++)),

                      const SizedBox(height: 16),
                      // Extras
                      const Text('Extras', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(children: [
                        GestureDetector(
                          onTap: () => setState(() => _strikeRateBonus = !_strikeRateBonus),
                          child: Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: _strikeRateBonus ? const Color(0xFF1A6BFF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF1A6BFF)),
                            ),
                            child: _strikeRateBonus ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Strike Rate Bonus', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        GestureDetector(
                          onTap: () => setState(() => _boundaryBonus = !_boundaryBonus),
                          child: Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: _boundaryBonus ? const Color(0xFF1A6BFF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF1A6BFF)),
                            ),
                            child: _boundaryBonus ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Boundary Bonus', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = Map<String, dynamic>.from(widget.player);
                    updated['runs'] = _runs;
                    updated['fours'] = _fours;
                    updated['sixes'] = _sixes;
                    updated['wkts'] = _wickets;
                    updated['catches'] = _catches;
                    updated['runOuts'] = _runOuts;
                    updated['pts'] = _calculatePts();
                    widget.onSave(updated);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _StatsUpdatedScreen(
                          playerName: widget.player['name'] as String,
                          runs: _runs,
                          fours: _fours,
                          sixes: _sixes,
                          catches: _catches,
                          wickets: _wickets,
                          totalPts: _calculatePts(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save & Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDec, onInc;
  const _StatRow({required this.label, required this.value, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13))),
        GestureDetector(
          onTap: onDec,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.remove, color: Colors.white60, size: 16),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center),
        ),
        GestureDetector(
          onTap: onInc,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: const Color(0xFF1A6BFF).withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1A6BFF).withOpacity(0.4))),
            child: const Icon(Icons.add, color: Color(0xFF1A6BFF), size: 16),
          ),
        ),
      ]),
    );
  }
}

// ── Stats Updated Screen ──────────────────────────────────────────────

class _StatsUpdatedScreen extends StatelessWidget {
  final String playerName;
  final int runs, fours, sixes, catches, wickets;
  final double totalPts;

  const _StatsUpdatedScreen({
    required this.playerName,
    required this.runs,
    required this.fours,
    required this.sixes,
    required this.catches,
    required this.wickets,
    required this.totalPts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('$playerName Updated', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ),

            const Spacer(),

            // Success animation
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFF00C853).withOpacity(0.3), Colors.transparent]),
                  ),
                ),
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00C853), width: 3),
                    color: const Color(0xFF00C853).withOpacity(0.1),
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF00C853), size: 50),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Stats updated successfully!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Qo Points generated', style: TextStyle(color: Colors.white38, fontSize: 13)),

            const SizedBox(height: 28),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatDisplay(label: 'Runs', value: '$runs'),
                    _StatDisplay(label: '4s', value: '$fours'),
                    _StatDisplay(label: '6s', value: '$sixes'),
                    _StatDisplay(label: 'Catches', value: '$catches'),
                    _StatDisplay(label: 'Wickets', value: '$wickets'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Total Qo Points
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(children: [
                  const Text('Total Qo Points', style: TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('$totalPts', style: const TextStyle(color: Color(0xFF00C853), fontSize: 36, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),

            const Spacer(),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6BFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('View Player', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Team', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDisplay extends StatelessWidget {
  final String label, value;
  const _StatDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
    ]);
  }
}