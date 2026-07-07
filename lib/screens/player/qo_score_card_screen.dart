import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';

class QoScoreCardScreen extends StatefulWidget {
  const QoScoreCardScreen({super.key});

  @override
  State<QoScoreCardScreen> createState() => _QoScoreCardScreenState();
}

class _QoScoreCardScreenState extends State<QoScoreCardScreen> {
  int _qoScore = 0;
  int _matchCount = 0;
  int _totalRuns = 0;
  int _totalWickets = 0;
  int _matchPoints = 0;
  int? _rank;
  bool _loading = true;

  String get _cardName {
    if (_qoScore >= 750) return 'Purple Card';
    if (_qoScore >= 500) return 'Blue Card';
    if (_qoScore >= 250) return 'Yellow Card';
    return 'Green Card';
  }

  String get _levelLabel {
    if (_qoScore >= 750) return 'Elite Performer';
    if (_qoScore >= 500) return 'Strong Performer';
    if (_qoScore >= 250) return 'Rising Player';
    return 'Getting Started';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.playerPerformance();
      if (!mounted) return;
      final recent = (data['recentMatches'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      var runs = 0, wickets = 0, pts = 0;
      for (final m in recent) {
        final st = m['stats'] as Map<String, dynamic>? ?? {};
        runs += (st['runs'] as num?)?.toInt() ?? 0;
        wickets += (st['wickets'] as num?)?.toInt() ?? 0;
        pts += (m['qoPoints'] as num?)?.toInt() ?? 0;
      }
      final ranking = data['ranking'] as Map<String, dynamic>?;
      setState(() {
        _rank = (ranking?['position'] as num?)?.toInt();
        _qoScore = (data['qoScore'] as num?)?.toInt() ?? 0;
        _matchCount = recent.length;
        _totalRuns = runs;
        _totalWickets = wickets;
        _matchPoints = pts;
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
        backgroundColor: Color(0xFF0A0A1A),
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text('Qo Score Card', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              ]),

              const SizedBox(height: 24),

              // Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D1B69), Color(0xFF7B2FFF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Qo Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text('$_qoScore', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w800, height: 1)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.green.withOpacity(0.4)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(_cardName, style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: const Center(child: Text('🏆', style: TextStyle(fontSize: 44))),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_cardName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(_levelLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_qoScore / 1000).clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: AppColors.green,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_qoScore pts', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        Text('${(1000 - _qoScore).clamp(0, 1000)} pts to next level', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Grid
              Row(children: [
                Expanded(child: _StatCard(label: 'Current Rank', value: _rank == null ? '—' : '#$_rank', icon: Icons.leaderboard, color: Colors.amber)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Matches', value: '$_matchCount', icon: Icons.sports_cricket, color: AppColors.primary)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(label: 'Total Runs', value: '$_totalRuns', icon: Icons.trending_up, color: AppColors.green)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Wickets', value: '$_totalWickets', icon: Icons.sports, color: Colors.orange)),
              ]),

              const SizedBox(height: 20),

              // Points Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Points Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),
                    _PointRow(label: 'Match Performance', points: _matchPoints, icon: Icons.sports_cricket),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Qo Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('$_qoScore pts', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card Progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Card Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),
                    _CardProgress(label: '🟢 Green Card', value: _qoScore.clamp(0, 250), max: 250, color: const Color(0xFF00C853)),
                    const SizedBox(height: 12),
                    _CardProgress(label: '🟡 Yellow Card', value: _qoScore.clamp(0, 500), max: 500, color: const Color(0xFFFFD600)),
                    const SizedBox(height: 12),
                    _CardProgress(label: '🔵 Blue Card', value: _qoScore.clamp(0, 750), max: 750, color: const Color(0xFF1A6BFF)),
                    const SizedBox(height: 12),
                    _CardProgress(label: '🟣 Purple Card', value: _qoScore.clamp(0, 1000), max: 1000, color: AppColors.primary),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  final String label;
  final int points;
  final IconData icon;
  const _PointRow({required this.label, required this.points, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13))),
        Text('$points pts', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }
}

class _CardProgress extends StatelessWidget {
  final String label;
  final int value, max;
  final Color color;
  const _CardProgress({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            Text('$value / $max pts', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: max > 0 ? value / max : 0,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}