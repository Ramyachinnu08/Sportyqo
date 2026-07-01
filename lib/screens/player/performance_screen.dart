import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
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

              // ── Qo Score Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Qo Score', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const Text('242', style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w800, height: 1)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            ),
                            child: Row(children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text('Purple Card', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                          const SizedBox(height: 6),
                          const Text('Elite Performer', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(children: const [
                            Icon(Icons.arrow_upward, color: AppColors.primary, size: 14),
                            Text('+63 points this week', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.shield, color: AppColors.primary, size: 36),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Card Progress ──
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
                    const Text('Card Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(0.4))),
                        child: const Icon(Icons.bolt, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text('Purple Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      RichText(
                        text: const TextSpan(children: [
                          TextSpan(text: '758', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14)),
                          TextSpan(text: ' / 1000', style: TextStyle(color: Colors.white38, fontSize: 13)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: 758 / 1000, backgroundColor: Colors.white10, color: AppColors.primary, minHeight: 8),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(children: [
                        TextSpan(text: '242 points to ', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        TextSpan(text: 'Blue Card', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Qo Journey Graph ──
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
                    Row(children: [
                      const Text('Qo Journey', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                        child: Row(children: const [
                          Text('This Season', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: CustomPaint(painter: _PerformanceGraphPainter(), size: const Size(double.infinity, 140)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Jan', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text('Feb', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text('Mar', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text('Apr', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text('May', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text('Jun', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Recent Matches ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Recent Matches', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 10),

              _MatchTile(
                teamLetter: 'W',
                opponent: 'vs Thunder Strikers',
                date: '18 May 2025',
                stat1: '78 Runs',
                stat2: '1 Catch',
                badge: 'Won Match',
                extraBadge: 'MOM ⭐',
                points: '+63',
                badgeColor: const Color(0xFF00C853),
                extraBadgeColor: const Color(0xFFFFB300),
              ),
              const SizedBox(height: 10),
              _MatchTile(
                teamLetter: 'W',
                opponent: 'vs Royal Challengers',
                date: '14 May 2025',
                stat1: '32 Runs',
                stat2: '2 Wickets',
                badge: 'Won Match',
                points: '+48',
                badgeColor: const Color(0xFF00C853),
              ),
              const SizedBox(height: 10),
              _MatchTile(
                teamLetter: 'W',
                opponent: 'vs Super Kings',
                date: '10 May 2025',
                stat1: '',
                stat2: '2 Catches',
                badge: 'Won Match',
                points: '+37',
                badgeColor: const Color(0xFF00C853),
              ),

              const SizedBox(height: 16),

              // ── Ranking ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Ranking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        SizedBox(height: 8),
                        Text('#14', style: TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w800)),
                        Text('U16 Cricket', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Text('Top 5%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.people_outline, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(height: 4),
                    const Text('Out of 280', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    const Text('players', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ]),
                ]),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Match Tile ────────────────────────────────────────────────────────

class _MatchTile extends StatelessWidget {
  final String teamLetter, opponent, date, stat1, stat2, badge, points;
  final Color badgeColor;
  final String? extraBadge;
  final Color? extraBadgeColor;

  const _MatchTile({
    required this.teamLetter,
    required this.opponent,
    required this.date,
    required this.stat1,
    required this.stat2,
    required this.badge,
    required this.points,
    required this.badgeColor,
    this.extraBadge,
    this.extraBadgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Center(child: Text(teamLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(opponent, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              Text(date, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 4),
              Row(children: [
                if (stat1.isNotEmpty) ...[
                  Text(stat1, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(width: 8),
                ],
                Text(stat2, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: badgeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                if (extraBadge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: extraBadgeColor!.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(extraBadge!, style: TextStyle(color: extraBadgeColor, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(points, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
            const Text('Qo Points', style: TextStyle(color: Colors.white38, fontSize: 10)),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ]),
    );
  }
}

// ── Graph Painter ─────────────────────────────────────────────────────

class _PerformanceGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.9, 0.75, 0.65, 0.5, 0.35, 0.1];

    final gridPaint = Paint()..color = Colors.white10..strokeWidth = 0.5;
    for (int i = 0; i < 4; i++) {
      final y = size.height * (1 - i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final fillPath = Path();
    final xOffset = 20.0;
    final usableWidth = size.width - xOffset;

    for (int i = 0; i < points.length; i++) {
      final x = xOffset + i * usableWidth / (points.length - 1);
      final y = points[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = xOffset + (i - 1) * usableWidth / (points.length - 1);
        final prevY = points[i - 1] * size.height;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final x = xOffset + i * usableWidth / (points.length - 1);
      final y = points[i] * size.height;
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = AppColors.primary..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
      if (i == points.length - 1) {
        final tp = TextPainter(
          text: const TextSpan(children: [
            TextSpan(text: '242\n', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            TextSpan(text: '18 May', style: TextStyle(color: Colors.white38, fontSize: 9)),
          ]),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - 20, y - 36));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}