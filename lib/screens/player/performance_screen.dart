import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';

/// Performance (design p.8): Qo Score tier card → Card Progress →
/// Qo Journey chart → Recent Matches → Ranking. All values come from
/// GET /players/:id/performance (score, journey, matches, ranking).
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool _loading = true;
  int _qoScore = 0;
  Map<String, dynamic>? _ranking; // {position, totalPlayers}
  List<Map<String, dynamic>> _journey = [];
  List<Map<String, dynamic>> _matches = [];
  String? _sportName;
  bool _showAllMatches = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await SportyQoApi.playerPerformance() as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _qoScore = (data['qoScore'] as num?)?.toInt() ?? 0;
        _ranking = data['ranking'] as Map<String, dynamic>?;
        _journey = (data['qoJourney'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        _matches = (data['recentMatches'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    try {
      final me = await SportyQoApi.me() as Map<String, dynamic>;
      if (!mounted) return;
      setState(() =>
          _sportName = (me['sport'] as Map<String, dynamic>?)?['name']);
    } catch (_) {}
  }

  // Qo card tiers (same thresholds as the Qo Score Card screen).
  ({String name, Color color, int floor, int? ceil, String? next}) get _tier {
    if (_qoScore >= 750) {
      return (name: 'Purple Card', color: AppColors.primary, floor: 750, ceil: null, next: null);
    }
    if (_qoScore >= 500) {
      return (name: 'Blue Card', color: const Color(0xFF1A6BFF), floor: 500, ceil: 750, next: 'Purple Card');
    }
    if (_qoScore >= 250) {
      return (name: 'Yellow Card', color: const Color(0xFFFFD600), floor: 250, ceil: 500, next: 'Blue Card');
    }
    return (name: 'Green Card', color: const Color(0xFF00C853), floor: 0, ceil: 250, next: 'Yellow Card');
  }

  int? get _weekDelta {
    if (_journey.length < 2) return null;
    return ((_journey.last['qoScore'] as num?) ?? 0).toInt() -
        ((_journey[_journey.length - 2]['qoScore'] as num?) ?? 0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tier;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: const Color(0xFF16162E),
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Row(children: const [
                      Expanded(
                        child: Text('Performance',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                      ),
                      Icon(Icons.calendar_today_outlined,
                          color: Colors.white70, size: 20),
                    ]),
                    const Text('Track your growth.',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 18),
                    _scoreCard(tier),
                    const SizedBox(height: 14),
                    _cardProgress(tier),
                    const SizedBox(height: 14),
                    _qoJourney(),
                    const SizedBox(height: 14),
                    _recentMatches(),
                    const SizedBox(height: 14),
                    _rankingCard(),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Qo Score tier card ──
  Widget _scoreCard(
      ({String name, Color color, int floor, int? ceil, String? next}) tier) {
    final delta = _weekDelta;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tier.color.withOpacity(0.22), const Color(0xFF101024)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tier.color.withOpacity(0.35)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Qo Score',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 2),
            Text('$_qoScore',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.05)),
            Text(tier.name,
                style: TextStyle(
                    color: tier.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            if (_ranking != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                    'Rank #${_ranking!['position']} of ${_ranking!['totalPlayers']}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ),
            if (delta != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${delta >= 0 ? '↑ +' : '↓ '}$delta points this month',
                  style: TextStyle(
                      color:
                          delta >= 0 ? tier.color : Colors.redAccent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ]),
        ),
        Icon(Icons.shield_rounded, size: 76, color: tier.color),
      ]),
    );
  }

  // ── Card Progress toward the next tier ──
  Widget _cardProgress(
      ({String name, Color color, int floor, int? ceil, String? next}) tier) {
    final maxed = tier.ceil == null;
    final progress = maxed
        ? 1.0
        : ((_qoScore - tier.floor) / (tier.ceil! - tier.floor))
            .clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Card Progress',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.bolt_rounded, size: 16, color: tier.color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(tier.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600)),
          ),
          Text(
            maxed ? '$_qoScore' : '$_qoScore / ${tier.ceil}',
            style: TextStyle(
                color: tier.color,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: Colors.white10,
            color: tier.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          maxed
              ? 'You hold the highest card. Keep it up! 🏆'
              : '${tier.ceil! - _qoScore} points to ${tier.next}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ]),
    );
  }

  // ── Qo Journey chart ──
  Widget _qoJourney() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Expanded(
            child: Text('Qo Journey',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
          Text('This Season',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          Icon(Icons.keyboard_arrow_down,
              color: Colors.white54, size: 16),
        ]),
        const SizedBox(height: 14),
        if (_journey.length < 2)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Play matches to start building\nyour Qo journey.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12.5),
              ),
            ),
          )
        else
          SizedBox(
            height: 170,
            child: CustomPaint(
              size: const Size(double.infinity, 170),
              painter: _JourneyPainter(
                labels: _journey
                    .map((j) => j['label'] as String? ?? '')
                    .toList(),
                values: _journey
                    .map((j) => ((j['qoScore'] as num?) ?? 0).toDouble())
                    .toList(),
                color: _tier.color,
              ),
            ),
          ),
      ]),
    );
  }

  // ── Recent Matches ──
  Widget _recentMatches() {
    final list =
        _showAllMatches ? _matches : _matches.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
            child: Text('Recent Matches',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
          if (_matches.length > 3)
            GestureDetector(
              onTap: () =>
                  setState(() => _showAllMatches = !_showAllMatches),
              child: Text(_showAllMatches ? 'Show Less' : 'View All',
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 12),
        if (_matches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No completed matches yet.',
                style: TextStyle(color: Colors.white38, fontSize: 12.5)),
          )
        else
          for (var i = 0; i < list.length; i++) ...[
            _matchRow(list[i]),
            if (i != list.length - 1)
              const Divider(color: Colors.white10, height: 22),
          ],
      ]),
    );
  }

  Widget _matchRow(Map<String, dynamic> m) {
    final teamName = (m['teamName'] as String? ?? '').toLowerCase();
    final summary = (m['resultSummary'] as String? ?? '');
    final won = teamName.isNotEmpty &&
        summary.toLowerCase().contains('won') &&
        summary.toLowerCase().contains(teamName);
    final lost = summary.toLowerCase().contains('won') && !won;
    final dt =
        DateTime.tryParse(m['playedAt'] as String? ?? '')?.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr =
        dt == null ? '' : '${dt.day} ${months[dt.month - 1]} ${dt.year}';

    // {"runs": 78, "wickets": 1} -> "78 Runs", "1 Wicket"
    final stats = (m['stats'] as Map<String, dynamic>? ?? const {})
        .entries
        .where((e) => e.value is num && (e.value as num) > 0)
        .map((e) {
      final n = (e.value as num).toInt();
      var label = e.key[0].toUpperCase() + e.key.substring(1);
      if (n == 1 && label.endsWith('s')) {
        label = label.substring(0, label.length - 1);
      }
      return '$n $label';
    }).toList();

    final qoPoints = (m['qoPoints'] as num?)?.toInt() ?? 0;
    final badgeColor = won
        ? const Color(0xFF00C853)
        : lost
            ? Colors.redAccent
            : Colors.white38;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: badgeColor.withOpacity(0.15),
          border: Border.all(color: badgeColor.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(won ? 'W' : (lost ? 'L' : '•'),
              style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m['opponent'] as String? ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700)),
          Text(dateStr,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          if (stats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(stats.join(' • '),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ),
          if (won)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Won Match',
                    style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${qoPoints >= 0 ? '+' : ''}$qoPoints',
            style: TextStyle(
                color: qoPoints >= 0
                    ? const Color(0xFF00C853)
                    : Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
        const Text('Qo Points',
            style: TextStyle(color: Colors.white38, fontSize: 10.5)),
      ]),
      const SizedBox(width: 4),
      const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    ]);
  }

  // ── Ranking card ──
  Widget _rankingCard() {
    final r = _ranking;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: r == null
          ? const Text(
              'Join a league to get ranked against other players.',
              style: TextStyle(color: Colors.white54, fontSize: 12.5),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ranking',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${r['position']}',
                          style: TextStyle(
                              color: _tier.color,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1)),
                      Text(_sportName ?? 'Your leagues',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ]),
                const SizedBox(width: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Top ${(((r['position'] as num) / (r['totalPlayers'] as num)) * 100).clamp(1, 100).round()}%',
                    style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Column(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.people_outline,
                        color: Colors.white70, size: 20),
                  ),
                  const SizedBox(height: 4),
                  Text('Out of ${r['totalPlayers']}\nplayers',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10.5)),
                ]),
              ]),
            ]),
    );
  }
}

// ── Journey line chart painter ────────────────────────────────────────
class _JourneyPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final Color color;
  const _JourneyPainter(
      {required this.labels, required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0, bottomPad = 22.0, topPad = 10.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;

    final maxV = values.reduce((a, b) => a > b ? a : b);
    final niceMax = ((maxV / 100).ceil() * 100).clamp(100, 100000).toDouble();

    final grid = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    final textStyle = const TextStyle(color: Colors.white38, fontSize: 9.5);

    // horizontal gridlines + y labels
    for (var i = 0; i <= 3; i++) {
      final v = niceMax * i / 3;
      final y = topPad + chartH - (v / niceMax) * chartH;
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width, y), grid);
      final tp = TextPainter(
          text: TextSpan(text: v.round().toString(), style: textStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    Offset at(int i) => Offset(
          leftPad +
              (values.length == 1
                  ? chartW / 2
                  : i * chartW / (values.length - 1)),
          topPad + chartH - (values[i] / niceMax) * chartH,
        );

    // area fill
    final area = Path()..moveTo(at(0).dx, topPad + chartH);
    for (var i = 0; i < values.length; i++) {
      area.lineTo(at(i).dx, at(i).dy);
    }
    area.lineTo(at(values.length - 1).dx, topPad + chartH);
    area.close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.22), color.withOpacity(0.0)],
          ).createShader(
              Rect.fromLTWH(0, topPad, size.width, chartH)));

    // line
    final line = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(path, line);

    // dots + x labels
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final p = at(i);
      canvas.drawCircle(p, i == values.length - 1 ? 4 : 2.6, dot);
      final tp = TextPainter(
          text: TextSpan(text: labels[i], style: textStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(
          canvas,
          Offset(
              (p.dx - tp.width / 2)
                  .clamp(leftPad, size.width - tp.width),
              size.height - tp.height));
    }
    // highlight bubble for the latest value
    final last = at(values.length - 1);
    final label = values.last.round().toString();
    final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(
        canvas,
        Offset((last.dx - tp.width - 8).clamp(leftPad, size.width),
            (last.dy - tp.height - 6).clamp(0, size.height)));
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter old) =>
      old.values != values || old.color != color;
}
