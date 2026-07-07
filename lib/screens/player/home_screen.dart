import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../shared/avatar_picker.dart';
import 'dugout_screen.dart';
import 'playbook_screen.dart';
import 'performance_screen.dart';
import 'profile_screen.dart';
import 'join_league_screen.dart';
import 'qo_score_card_screen.dart';

/// Player shell: bottom navigation (Home • Dugout • Playbook •
/// Performance • Profile) hosting the five tabs.
class HomeScreen extends StatefulWidget {
  final String selectedSport;
  final String? playerId;
  const HomeScreen({
    super.key,
    this.selectedSport = 'Cricket',
    this.playerId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    _HomeTab(playerId: widget.playerId),
    const DugoutScreen(),
    const PlaybookScreen(),
    const PerformanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F2A),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          unselectedLabelStyle:
              const TextStyle(fontSize: 11, fontFamily: 'Poppins'),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Dugout'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Playbook'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Performance'),
          ],
        ),
      ),
    );
  }
}

// ── HOME TAB (design p.2) ─────────────────────────────────────────────
// Greeting header → Qo Score card with sparkline → Active League card →
// Upcoming Match card → Join League card. All fields come from
// GET /players/:id/home and GET /players/:id/performance.

class _HomeTab extends StatefulWidget {
  final String? playerId;
  const _HomeTab({this.playerId});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _loading = true;

  String _firstName = '';
  String _fullName = '';
  String? _avatarUrl;
  String? _sportName;
  String? _playerCode;
  int _qoScore = 0;
  int _unread = 0;
  Map<String, dynamic>? _league; // activeLeague
  Map<String, dynamic>? _match; // upcomingMatch
  List<double> _journey = const []; // Qo journey points for the sparkline
  int? _monthDelta;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final home = await SportyQoApi.playerHome() as Map<String, dynamic>;
      final player = home['player'] as Map<String, dynamic>? ?? const {};
      if (!mounted) return;
      setState(() {
        _fullName = player['fullName'] as String? ?? '';
        _firstName = _fullName.split(' ').first;
        _avatarUrl = player['avatarUrl'] as String?;
        _qoScore = (player['qoScore'] as num?)?.toInt() ?? 0;
        _sportName = (player['sport'] as Map<String, dynamic>?)?['name'];
        _playerCode = player['playerId'] as String?;
        _league = home['activeLeague'] as Map<String, dynamic>?;
        _match = home['upcomingMatch'] as Map<String, dynamic>?;
        _unread = ((home['notifications']
                    as Map<String, dynamic>?)?['unreadCount'] as num?)
                ?.toInt() ??
            0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    // Sparkline + monthly delta come from the performance journey.
    try {
      final perf =
          await SportyQoApi.playerPerformance() as Map<String, dynamic>;
      final journey = (perf['qoJourney'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _journey = journey
            .map((j) => ((j['qoScore'] as num?) ?? 0).toDouble())
            .toList();
        if (journey.length >= 2) {
          _monthDelta = ((journey.last['qoScore'] as num?) ?? 0).toInt() -
              ((journey[journey.length - 2]['qoScore'] as num?) ?? 0).toInt();
        }
      });
    } catch (_) {/* chart simply stays hidden */}
  }

  ({String label, Color color}) get _tier {
    if (_qoScore >= 750) return (label: 'Purple Card', color: AppColors.primary);
    if (_qoScore >= 500) return (label: 'Blue Card', color: const Color(0xFF1A6BFF));
    if (_qoScore >= 250) return (label: 'Yellow Card', color: const Color(0xFFFFD600));
    return (label: 'Green Card', color: const Color(0xFF00C853));
  }

  @override
  Widget build(BuildContext context) {
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
                    _header(),
                    const SizedBox(height: 20),
                    _qoScoreCard(),
                    const SizedBox(height: 14),
                    if (_league != null) ...[
                      _activeLeagueCard(),
                      const SizedBox(height: 14),
                    ],
                    _upcomingMatchSection(),
                    const SizedBox(height: 14),
                    _joinLeagueCard(),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header: "Alex." + sport/position + team, bell, avatar ──
  Widget _header() {
    final team =
        (_league?['team'] as Map<String, dynamic>?)?['name'] as String?;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1),
                children: [
                  TextSpan(text: _firstName.isEmpty ? 'Player' : _firstName),
                  const TextSpan(
                      text: '.', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (_sportName != null) _sportName!,
                if (_playerCode != null) _playerCode!,
              ].join(' • '),
              style: const TextStyle(color: Colors.white60, fontSize: 13.5),
            ),
            if (team != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(team,
                    style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
        ),
        GestureDetector(
          onTap: _openNotifications,
          child: Stack(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 22),
            ),
            if (_unread > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
          ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ProfileScreen(playerId: widget.playerId)));
            _load(); // reflect avatar/name edits made in the profile
          },
          child: AvatarCircle(
            avatarUrl: _avatarUrl,
            name: _fullName.isEmpty ? 'P' : _fullName,
            size: 44,
            borderColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ── Qo Score card with tier chip, monthly delta and sparkline ──
  Widget _qoScoreCard() {
    final tier = _tier;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const QoScoreCardScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171732), Color(0xFF101024)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Qo Score',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('$_qoScore',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          height: 1.05)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shield_rounded, size: 13, color: tier.color),
                      const SizedBox(width: 6),
                      Text(tier.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  if (_monthDelta != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${_monthDelta! >= 0 ? '↑ +' : '↓ '}$_monthDelta this month',
                      style: TextStyle(
                          color: _monthDelta! >= 0
                              ? AppColors.primaryLight
                              : Colors.redAccent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            Column(children: [
              const Icon(Icons.chevron_right, color: Colors.white38),
              const SizedBox(height: 8),
              if (_journey.length >= 2)
                SizedBox(
                  width: 130,
                  height: 80,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                        points: _journey, color: AppColors.primaryLight),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Active League card ──
  Widget _activeLeagueCard() {
    final l = _league!;
    final subtitleParts = <String>[
      if ((l['gender'] as String?)?.isNotEmpty == true) l['gender'] as String,
      if ((l['season'] as String?)?.isNotEmpty == true) l['season'] as String,
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(l['icon'] as String? ?? '🛡️',
                style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ACTIVE LEAGUE',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(l['name'] as String? ?? 'League',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            if (subtitleParts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitleParts.join(' • '),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12.5)),
              ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Active',
              style: TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
      ]),
    );
  }

  // ── Upcoming Match ──
  Widget _upcomingMatchSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(
          child: Text('Upcoming Match',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700)),
        ),
        if (_match != null)
          const Text('View All',
              style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      if (_match == null)
        Container(
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: const Text(
            'No upcoming matches scheduled yet.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        )
      else
        _matchCard(_match!),
    ]);
  }

  Widget _matchCard(Map<String, dynamic> m) {
    final home = m['homeTeam'] as Map<String, dynamic>? ?? const {};
    final away = m['awayTeam'] as Map<String, dynamic>? ?? const {};
    final dt = DateTime.tryParse(m['scheduledAt'] as String? ?? '')?.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr =
        dt == null ? '' : '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    final h = dt == null ? 0 : (dt.hour % 12 == 0 ? 12 : dt.hour % 12);
    final timeStr = dt == null
        ? ''
        : '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';

    Widget teamBadge(Map<String, dynamic> t) => Column(children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B38),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Text(t['icon'] as String? ?? '🛡️',
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 110,
            child: Text(t['name'] as String? ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ]);

    Widget info(IconData icon, String text) => Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 5),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 11.5)),
            ),
          ]),
        );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A38), Color(0xFF121226)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              teamBadge(home),
              const Text('VS',
                  style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              teamBadge(away),
            ],
          ),
        ),
        Container(height: 1, color: Colors.white10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(children: [
            info(Icons.calendar_today_outlined, dateStr),
            Container(width: 1, height: 18, color: Colors.white10),
            info(Icons.access_time_rounded, timeStr),
            Container(width: 1, height: 18, color: Colors.white10),
            info(Icons.location_on_outlined,
                m['venue'] as String? ?? 'TBA'),
          ]),
        ),
      ]),
    );
  }

  // ── Join League card ──
  Widget _joinLeagueCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF191936), Color(0xFF241A48)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.primaryLight, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Join League',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            const Text('Enter a league code shared\nby your coach or organizer.',
                style: TextStyle(
                    color: Colors.white60, fontSize: 12.5, height: 1.45)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JoinLeagueScreen()));
                _load(); // refresh league/team after joining
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4BE0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Text('Join League',
                    style:
                        TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ]),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        const Text('🏆', style: TextStyle(fontSize: 56)),
      ]),
    );
  }

  // ── Notifications sheet ──
  Future<void> _openNotifications() async {
    List<Map<String, dynamic>> items = const [];
    try {
      items = (await SportyQoApi.notifications()).cast<Map<String, dynamic>>();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _unread = 0);
    SportyQoApi.markNotificationsRead().catchError((_) {});
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14142B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Notifications',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No notifications yet.',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 13)))
                  : ListView.separated(
                      controller: controller,
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 18),
                      itemBuilder: (_, i) {
                        final n = items[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['emoji'] as String? ?? '🔔',
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n['title'] as String? ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700)),
                                  if ((n['body'] as String?)?.isNotEmpty ==
                                      true)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(n['body'] as String,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12.5,
                                              height: 1.35)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Sparkline painter for the Qo journey mini-chart ───────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  const _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    Offset at(int i) => Offset(
          i * size.width / (points.length - 1),
          size.height - ((points[i] - minV) / span) * (size.height - 8) - 4,
        );

    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(path, line);

    // vertical dotted guides + point dots, like the design
    final guide = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1;
    final dot = Paint()..color = color;
    for (var i = 0; i < points.length; i++) {
      final p = at(i);
      double y = p.dy + 4;
      while (y < size.height) {
        canvas.drawLine(Offset(p.dx, y), Offset(p.dx, y + 2), guide);
        y += 5;
      }
      canvas.drawCircle(p, i == points.length - 1 ? 3.4 : 2.4, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.points != points || old.color != color;
}
