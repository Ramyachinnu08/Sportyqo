import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool _loading = true;
  String? _error;
  String _journeyRange = 'This Season'; // This Season | Last 6 Months | Last 3 Months
  int _qoScore = 0;
  int _weekPoints = 0;
  Map<String, dynamic>? _ranking;
  List<Map<String, dynamic>> _journey = [];
  List<Map<String, dynamic>> _recent = [];

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  // Card tiers by Qo score
  ({String name, String label, Color color, int target, String next}) get _tier {
    if (_qoScore >= 750) {
      return (name: 'Purple Card', label: 'Elite Performer', color: AppColors.primary, target: 1000, next: 'Legend Card');
    } else if (_qoScore >= 500) {
      return (name: 'Blue Card', label: 'Strong Performer', color: Colors.blueAccent, target: 750, next: 'Purple Card');
    } else if (_qoScore >= 250) {
      return (name: 'Silver Card', label: 'Solid Performer', color: Colors.blueGrey, target: 500, next: 'Blue Card');
    }
    return (name: 'Bronze Card', label: 'Rising Star', color: Colors.orangeAccent, target: 250, next: 'Silver Card');
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _qoScore == 0 && _journey.isEmpty;
      _error = null;
    });
    try {
      final data = await SportyQoApi.playerPerformance();
      if (!mounted) return;
      final recent = (data['recentMatches'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final now = DateTime.now();
      int week = 0;
      for (final r in recent) {
        final dt = DateTime.tryParse(r['playedAt'] as String? ?? '');
        if (dt != null && now.difference(dt).inDays < 7) {
          week += (r['qoPoints'] as num?)?.toInt() ?? 0;
        }
      }
      setState(() {
        _qoScore = (data['qoScore'] as num?)?.toInt() ?? 0;
        _ranking = data['ranking'] as Map<String, dynamic>?;
        _journey = (data['qoJourney'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        _recent = recent;
        _weekPoints = week;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.code == 'NETWORK'
            ? 'Could not reach the SportyQo server.\nCheck your connection and try again.'
            : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong while loading your performance.';
      });
    }
  }

  /// Journey points filtered by the selected range dropdown.
  List<Map<String, dynamic>> get _visibleJourney {
    switch (_journeyRange) {
      case 'Last 3 Months':
        return _journey.length <= 3
            ? _journey
            : _journey.sublist(_journey.length - 3);
      case 'Last 6 Months':
        return _journey.length <= 6
            ? _journey
            : _journey.sublist(_journey.length - 6);
      default:
        return _journey;
    }
  }

  static String _fmtDate(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}';
  }

  static List<String> _statStrings(Map<String, dynamic>? stats) {
    if (stats == null) return [];
    final out = <String>[];
    void add(String key, String singular, String plural) {
      final v = (stats[key] as num?)?.toInt();
      if (v != null && v > 0) out.add('$v ${v == 1 ? singular : plural}');
    }
    add('runs', 'Run', 'Runs');
    add('wickets', 'Wicket', 'Wickets');
    add('catches', 'Catch', 'Catches');
    add('goals', 'Goal', 'Goals');
    add('assists', 'Assist', 'Assists');
    add('points', 'Point', 'Points');
    return out;
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
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A1A),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: Colors.white38, size: 44),
                  const SizedBox(height: 14),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: const Color(0xFF0F0F2A),
          onRefresh: _load,
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          Text('$_qoScore', style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w800, height: 1)),
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
                              Text(_tier.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                          const SizedBox(height: 6),
                          Text(_tier.label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 6),
                          if (_weekPoints > 0)
                            Row(children: [
                              const Icon(Icons.arrow_upward, color: AppColors.primary, size: 14),
                              Text('+$_weekPoints points this week', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
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
                      Text(_tier.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(text: '$_qoScore', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14)),
                          TextSpan(text: ' / ${_tier.target}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: (_qoScore / _tier.target).clamp(0.0, 1.0), backgroundColor: Colors.white10, color: AppColors.primary, minHeight: 8),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: '${(_tier.target - _qoScore).clamp(0, _tier.target)} points to ', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        TextSpan(text: _tier.next, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
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
                      PopupMenuButton<String>(
                        color: const Color(0xFF13132B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white10)),
                        onSelected: (v) =>
                            setState(() => _journeyRange = v),
                        itemBuilder: (_) => const [
                          'This Season',
                          'Last 6 Months',
                          'Last 3 Months',
                        ]
                            .map((v) => PopupMenuItem<String>(
                                  value: v,
                                  child: Text(v,
                                      style: TextStyle(
                                          color: v == _journeyRange
                                              ? AppColors.primary
                                              : Colors.white70,
                                          fontSize: 13,
                                          fontWeight: v == _journeyRange
                                              ? FontWeight.w700
                                              : FontWeight.w400)),
                                ))
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_journeyRange,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white38, size: 16),
                          ]),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (_visibleJourney.length >= 2) ...[
                      SizedBox(
                        height: 140,
                        child: CustomPaint(
                            painter: _PerformanceGraphPainter(
                                values: _visibleJourney
                                    .map((j) =>
                                        ((j['qoScore'] as num?) ?? 0)
                                            .toDouble())
                                    .toList(),
                                lastValueLabel:
                                    '${(_visibleJourney.last['qoScore'] as num?)?.toInt() ?? 0}',
                                lastDateLabel: _visibleJourney.last['label']
                                        as String? ??
                                    ''),
                            size: const Size(double.infinity, 140)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _visibleJourney
                            .map((j) => Text(j['label'] as String? ?? '',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 10)))
                            .toList(),
                      ),
                    ] else
                      const SizedBox(
                        height: 100,
                        child: Center(
                            child: Text(
                                'Play matches to start your Qo Journey',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13))),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Recent Matches ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Matches',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              _AllRecentMatchesScreen(matches: _recent)),
                    ),
                    child: const Text('View All',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (_recent.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Center(
                      child: Text('No matches played yet',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14))),
                )
              else
                ..._recent.take(3).map((r) {
                  final stats = _statStrings(r['stats'] as Map<String, dynamic>?);
                  final opponent = r['opponent'] as String? ?? 'Match';
                  final qp = (r['qoPoints'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MatchTile(
                      teamLetter: opponent.replaceFirst('vs ', '').isEmpty
                          ? '?'
                          : opponent.replaceFirst('vs ', '')[0],
                      opponent: opponent,
                      date: _fmtDate(r['playedAt'] as String?),
                      stat1: stats.isNotEmpty ? stats[0] : '',
                      stat2: stats.length > 1 ? stats[1] : '',
                      badge: (r['resultSummary'] as String?)?.isNotEmpty == true
                          ? r['resultSummary'] as String
                          : 'Completed',
                      points: qp >= 0 ? '+$qp' : '$qp',
                      badgeColor: const Color(0xFF00C853),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // ── Ranking ──
              if (_ranking != null)
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
                        children: [
                          const Text('Ranking',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('#${_ranking!['position']}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800)),
                          const Text('In your leagues',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.people_outline,
                            color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(height: 4),
                      Text('Out of ${_ranking!['totalPlayers']}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10)),
                      const Text('players',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 10)),
                    ]),
                  ]),
                ),

              const SizedBox(height: 32),
            ],
          ),
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

  const _MatchTile({
    required this.teamLetter,
    required this.opponent,
    required this.date,
    required this.stat1,
    required this.stat2,
    required this.badge,
    required this.points,
    required this.badgeColor,
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
  final List<double> values;
  final String lastValueLabel;
  final String lastDateLabel;
  _PerformanceGraphPainter({
    required this.values,
    this.lastValueLabel = '',
    this.lastDateLabel = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Normalize raw Qo scores into 0..1 painter space (inverted: 0 = top).
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final points = values
        .map((v) => 0.9 - 0.8 * ((v - minV) / range))
        .toList();

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
      if (i == points.length - 1 && lastValueLabel.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(children: [
            TextSpan(
                text: '$lastValueLabel\n',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            TextSpan(
                text: lastDateLabel,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 9)),
          ]),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - 20, y - 36));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PerformanceGraphPainter oldDelegate) =>
      oldDelegate.values != values;
}

// ── All Recent Matches (View All) ─────────────────────────────────────

class _AllRecentMatchesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> matches;
  const _AllRecentMatchesScreen({required this.matches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text('All Matches',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: matches.isEmpty
                  ? const Center(
                      child: Text('No matches played yet',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: matches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final r = matches[i];
                        final stats = _PerformanceScreenState._statStrings(
                            r['stats'] as Map<String, dynamic>?);
                        final opponent = r['opponent'] as String? ?? 'Match';
                        final qp = (r['qoPoints'] as num?)?.toInt() ?? 0;
                        return _MatchTile(
                          teamLetter: opponent.replaceFirst('vs ', '').isEmpty
                              ? '?'
                              : opponent.replaceFirst('vs ', '')[0],
                          opponent: opponent,
                          date: _PerformanceScreenState._fmtDate(
                              r['playedAt'] as String?),
                          stat1: stats.isNotEmpty ? stats[0] : '',
                          stat2: stats.length > 1 ? stats[1] : '',
                          badge: (r['resultSummary'] as String?)?.isNotEmpty ==
                                  true
                              ? r['resultSummary'] as String
                              : 'Completed',
                          points: qp >= 0 ? '+$qp' : '$qp',
                          badgeColor: const Color(0xFF00C853),
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
