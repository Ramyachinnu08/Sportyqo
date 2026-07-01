import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class QoScoreCardScreen extends StatelessWidget {
  const QoScoreCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            const Text('720', style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w800, height: 1)),
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
                                const Text('Purple Card', style: TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600)),
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
                      children: const [
                        Text('Level 4', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Pro Player ⭐', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.72,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: AppColors.green,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('720 pts', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        Text('1000 pts to next level', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Grid
              Row(children: [
                Expanded(child: _StatCard(label: 'Current Rank', value: '#14', icon: Icons.leaderboard, color: Colors.amber)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Matches', value: '24', icon: Icons.sports_cricket, color: AppColors.primary)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(label: 'Total Runs', value: '1286', icon: Icons.trending_up, color: AppColors.green)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Wickets', value: '36', icon: Icons.sports, color: Colors.orange)),
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
                    _PointRow(label: 'Match Performance', points: 180, icon: Icons.sports_cricket),
                    _PointRow(label: 'Bonus Points', points: 40, icon: Icons.star),
                    _PointRow(label: 'Consistency', points: 22, icon: Icons.trending_up),
                    const Divider(color: Colors.white10, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        const Text('242 pts', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
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
                    _CardProgress(label: '🟣 Purple Card', value: 720, max: 1000, color: AppColors.primary),
                    const SizedBox(height: 12),
                    _CardProgress(label: '🟢 Green Card', value: 0, max: 2000, color: AppColors.green),
                    const SizedBox(height: 12),
                    _CardProgress(label: '🔵 Blue Card', value: 0, max: 5000, color: Colors.blueAccent),
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