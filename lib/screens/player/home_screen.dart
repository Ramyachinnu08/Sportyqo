import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import 'dugout_screen.dart';
import 'playbook_screen.dart';
import 'performance_screen.dart';
import 'profile_screen.dart';
import 'join_league_screen.dart';
import 'qo_score_card_screen.dart';

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
    _HomeTab(selectedSport: widget.selectedSport, playerId: widget.playerId),
    const DugoutScreen(),
    const PlaybookScreen(),
    const PerformanceScreen(),
    ProfileScreen(playerId: widget.playerId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: _screens[_currentIndex],
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
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
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
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ── HOME TAB ──────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  final String selectedSport;
  final String? playerId;
  const _HomeTab({this.selectedSport = 'Cricket', this.playerId});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String? _activeLeague = 'U16 Division • Division 1';
  String? _activeTeam = 'Falcons FC';

  // Live data from GET /players/:id/home (falls back to mocks while loading
  // or if the backend is unreachable).
  String? _firstName;
  String? _livePlayerCode;
  int? _liveQoScore;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final data = await SportyQoApi.playerHome();
      if (!mounted) return;
      final player = data['player'] as Map<String, dynamic>?;
      final league = data['activeLeague'] as Map<String, dynamic>?;
      final team = league?['team'] as Map<String, dynamic>?;
      final notif = data['notifications'] as Map<String, dynamic>?;
      setState(() {
        _firstName =
            (player?['fullName'] as String?)?.split(' ').first;
        _livePlayerCode = player?['playerId'] as String?;
        _liveQoScore = player?['qoScore'] as int?;
        _activeLeague = league?['name'] as String?;
        _activeTeam = team?['name'] as String?;
        _unreadCount = (notif?['unreadCount'] as int?) ?? 0;
      });
    } catch (_) {
      // Not logged in / offline: keep the existing mock visuals.
    }
  }

  String _getSportRole(String sport) {
    switch (sport) {
      case 'Football':
        return 'Forward';
      case 'Cricket':
        return 'Batsman';
      case 'Basketball':
        return 'Point Guard';
      case 'Volleyball':
        return 'Setter';
      case 'Swimming':
        return 'Freestyle';
      case 'Badminton':
        return 'Singles';
      case 'Tennis':
        return 'Singles';
      case 'Kabaddi':
        return 'Raider';
      default:
        return 'Player';
    }
  }

  String _getTeam1(String sport) {
    switch (sport) {
      case 'Football':
        return 'Alpha FC';
      case 'Cricket':
        return 'Alpha Warriors';
      case 'Basketball':
        return 'Alpha Hoops';
      case 'Volleyball':
        return 'Alpha VB';
      case 'Swimming':
        return 'Alpha Swim';
      case 'Badminton':
        return 'Alpha Badminton';
      case 'Tennis':
        return 'Alpha Tennis';
      case 'Kabaddi':
        return 'Alpha Raiders';
      default:
        return 'Alpha Warriors';
    }
  }

  String _getTeam2(String sport) {
    switch (sport) {
      case 'Football':
        return 'Thunder FC';
      case 'Cricket':
        return 'Thunder Strikers';
      case 'Basketball':
        return 'Thunder Hoops';
      case 'Volleyball':
        return 'Thunder VB';
      case 'Swimming':
        return 'Thunder Swim';
      case 'Badminton':
        return 'Thunder Badminton';
      case 'Tennis':
        return 'Thunder Tennis';
      case 'Kabaddi':
        return 'Thunder Raiders';
      default:
        return 'Thunder Strikers';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(_firstName ?? 'Alex',
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const Text('.',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ]),
                        if (_livePlayerCode != null ||
                            widget.playerId != null) ...[
                          const SizedBox(height: 4),
                          Text(_livePlayerCode ?? widget.playerId!,
                              style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5)),
                        ],
                        const SizedBox(height: 8),
                        Text('U16 • ${_getSportRole(widget.selectedSport)}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(_activeTeam ?? 'No Team',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                  // Notification Bell
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _NotificationScreen())),
                    child: Stack(children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: Colors.white10, shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF0A0A1A), width: 1.5)),
                          ),
                        ),
                    ]),
                  ),

                  const SizedBox(width: 10),

                  // Profile Picture
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _ProfileImageScreen())),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=faces'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Qo Score Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QoScoreCardScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13132B),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Qo Score',
                                style: TextStyle(color: Colors.white54, fontSize: 13)),
                            Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('${_liveQoScore ?? 720}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 54,
                                    fontWeight: FontWeight.w800,
                                    height: 1)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: CustomPaint(painter: _ScoreGraphPainter()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: AppColors.primary, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text('Purple Card',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(children: const [
                          Icon(Icons.arrow_upward, color: Color(0xFF7B2FFF), size: 14),
                          Text('+35 this month',
                              style: TextStyle(
                                  color: Color(0xFF7B2FFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Active League ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _activeTeam == null
                      ? null
                      : () async {
                    final exited = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => _LeagueDetailScreen(
                              leagueName: _activeLeague!,
                              teamName: _activeTeam!,
                              sport: widget.selectedSport,
                            )));
                    if (exited == true) {
                      setState(() {
                        _activeTeam = null;
                        _activeLeague = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13132B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(children: [
                      _ShieldBadge(color: AppColors.primary, icon: Icons.shield),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ACTIVE LEAGUE',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                            const SizedBox(height: 2),
                            Text(_activeTeam ?? 'Not in a team',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                            Text(_activeLeague ?? 'Join a league to get started',
                                style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (_activeTeam != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.green.withOpacity(0.3)),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Upcoming Match ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upcoming Match',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const _AllMatchesScreen())),
                      child: const Text('View All',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF13132B),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://i.ibb.co/ksm7Jj8f/1a.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.45),
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 26),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: [
                                  _ShieldBadge(
                                      color: AppColors.primary,
                                      icon: Icons.shield,
                                      size: 56,
                                      letter: 'A'),
                                  const SizedBox(height: 8),
                                  Text(_getTeam1(widget.selectedSport),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ]),
                                const Text('VS',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800)),
                                Column(children: [
                                  _ShieldBadge(
                                      color: Colors.white24,
                                      icon: Icons.bolt,
                                      size: 56,
                                      iconColor: Colors.white),
                                  const SizedBox(height: 8),
                                  Text(_getTeam2(widget.selectedSport),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(children: [
                            Icon(Icons.calendar_today_outlined,
                                color: Colors.white54, size: 14),
                            SizedBox(width: 4),
                            Text('24 May 2025',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ]),
                          Row(children: [
                            Icon(Icons.access_time, color: Colors.white54, size: 14),
                            SizedBox(width: 4),
                            Text('06:00 PM',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ]),
                          Row(children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.white54, size: 14),
                            SizedBox(width: 4),
                            Text('Green Field Arena',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              // ── Join League ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => JoinLeagueScreen(
                            onJoined: (teamName, leagueName) {
                              setState(() {
                                _activeTeam = teamName;
                                _activeLeague = leagueName;
                              });
                            },
                          ))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://i.ibb.co/QjvzBGMY/1aa.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.55),
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add,
                                            color: AppColors.primary, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('Join League',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                    ]),
                                    const SizedBox(height: 8),
                                    const Text(
                                        'Enter a league code shared\nby your coach or organizer.',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            height: 1.5)),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text('Join League',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14)),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward,
                                              color: Colors.white, size: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
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

// ── Shield Badge Widget ───────────────────────────────────────────────

class _ShieldBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  final String? letter;
  final Color? iconColor;

  const _ShieldBadge({
    required this.color,
    required this.icon,
    this.size = 44,
    this.letter,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      child: Center(
        child: letter != null
            ? Text(letter!,
            style: TextStyle(
                color: iconColor ?? color,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800))
            : Icon(icon, color: iconColor ?? color, size: size * 0.5),
      ),
    );
  }
}

// ── Score Graph Painter (rising gradient line, like mockup) ────────────

class _ScoreGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.85, 0.7, 0.62, 0.5, 0.42, 0.3, 0.18, 0.05];

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.25),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = points[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = points[i] * size.height;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

    canvas.drawCircle(
        Offset(size.width, points.last * size.height), 4.5, dotPaint);
    canvas.drawCircle(
        Offset(size.width, points.last * size.height),
        4.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Notification Screen ───────────────────────────────────────────────

class _NotificationScreen extends StatefulWidget {
  const _NotificationScreen();

  @override
  State<_NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<_NotificationScreen> {
  late List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFB300),
      'title': 'Points Added!',
      'subtitle': '+52 Qo points added to your profile',
      'time': '2m ago',
      'read': false
    },
    {
      'icon': Icons.people,
      'color': const Color(0xFF7B2FFF),
      'title': 'New Follower',
      'subtitle': 'Rahul Sharma started following you',
      'time': '15m ago',
      'read': false
    },
    {
      'icon': Icons.sports_cricket,
      'color': const Color(0xFF00C853),
      'title': 'League Update',
      'subtitle': 'Summer League 2024 is now live!',
      'time': '1h ago',
      'read': false
    },
    {
      'icon': Icons.favorite,
      'color': Colors.red,
      'title': 'Post Liked',
      'subtitle': 'Jason liked your match highlight',
      'time': '2h ago',
      'read': true
    },
    {
      'icon': Icons.shield,
      'color': const Color(0xFF7B2FFF),
      'title': 'Match Scheduled',
      'subtitle': 'Alpha Warriors vs Thunder on 24 May',
      'time': '3h ago',
      'read': true
    },
    {
      'icon': Icons.star,
      'color': const Color(0xFFFFB300),
      'title': 'Achievement Unlocked!',
      'subtitle': 'You scored 100+ in a single match 🎉',
      'time': '1d ago',
      'read': true
    },
    {
      'icon': Icons.person_add,
      'color': const Color(0xFF7B2FFF),
      'title': 'Follow Request',
      'subtitle': 'Vikram Reddy wants to follow you',
      'time': '1d ago',
      'read': true
    },
    {
      'icon': Icons.emoji_events,
      'color': const Color(0xFF00C853),
      'title': 'Rank Improved!',
      'subtitle': 'You moved from #16 to #14',
      'time': '2d ago',
      'read': true
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => !(n['read'] as bool)).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
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
                Expanded(
                  child: Row(children: [
                    const Text('Notifications',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('$unreadCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _notifications =
                          _notifications.map((n) => {...n, 'read': true}).toList();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('All marked as read ✅'),
                      backgroundColor: AppColors.primary,
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: const Text('Mark all read',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _notifications[i];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _notifications[i] = {..._notifications[i], 'read': true};
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n['read'] as bool
                            ? const Color(0xFF0F0F2A)
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: n['read'] as bool
                                ? Colors.white10
                                : AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (n['color'] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(n['icon'] as IconData,
                              color: n['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(n['title'] as String,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14))),
                                if (!(n['read'] as bool))
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle)),
                              ]),
                              const SizedBox(height: 3),
                              Text(n['subtitle'] as String,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      height: 1.4)),
                              const SizedBox(height: 4),
                              Text(n['time'] as String,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 11)),
                            ],
                          ),
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

// ── All Matches Screen ────────────────────────────────────────────────

class _AllMatchesScreen extends StatelessWidget {
  const _AllMatchesScreen();

  final List<Map<String, dynamic>> _matches = const [
    {
      'team1': 'Alpha Warriors',
      'team2': 'Thunder Strikers',
      'date': '24 May 2025',
      'time': '06:00 PM',
      'venue': 'Green Field Arena',
      'status': 'Upcoming',
      'statusColor': Color(0xFF7B2FFF)
    },
    {
      'team1': 'Alpha Warriors',
      'team2': 'Royal Challengers',
      'date': '18 May 2025',
      'time': '05:00 PM',
      'venue': 'City Stadium',
      'status': 'Won',
      'statusColor': Color(0xFF00C853)
    },
    {
      'team1': 'Alpha Warriors',
      'team2': 'Super Kings',
      'date': '14 May 2025',
      'time': '04:00 PM',
      'venue': 'Green Field Arena',
      'status': 'Won',
      'statusColor': Color(0xFF00C853)
    },
    {
      'team1': 'Alpha Warriors',
      'team2': 'Blue Riders',
      'date': '10 May 2025',
      'time': '06:00 PM',
      'venue': 'Sports Complex',
      'status': 'Won',
      'statusColor': Color(0xFF00C853)
    },
    {
      'team1': 'Alpha Warriors',
      'team2': 'Red Panthers',
      'date': '05 May 2025',
      'time': '03:00 PM',
      'venue': 'City Stadium',
      'status': 'Lost',
      'statusColor': Colors.red
    },
    {
      'team1': 'Alpha Warriors',
      'team2': 'Green Giants',
      'date': '30 Apr 2025',
      'time': '05:00 PM',
      'venue': 'Green Field Arena',
      'status': 'Won',
      'statusColor': Color(0xFF00C853)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _matches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final m = _matches[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                            child: Column(children: [
                              Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.primary.withOpacity(0.4))),
                                  child: const Center(
                                      child: Text('A',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800)))),
                              const SizedBox(height: 6),
                              Text(m['team1'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center),
                            ])),
                        Column(children: [
                          const Text('VS',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                color: (m['statusColor'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(m['status'] as String,
                                style: TextStyle(
                                    color: m['statusColor'] as Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ]),
                        Expanded(
                            child: Column(children: [
                              Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24)),
                                  child: const Icon(Icons.bolt,
                                      color: Colors.white, size: 24)),
                              const SizedBox(height: 6),
                              Text(m['team2'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center),
                            ])),
                      ]),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(m['date'] as String,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ]),
                          Row(children: [
                            const Icon(Icons.access_time,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(m['time'] as String,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ]),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(m['venue'] as String,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ]),
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

// ── League Detail Screen ──────────────────────────────────────────────

class _LeagueDetailScreen extends StatelessWidget {
  final String leagueName;
  final String teamName;
  final String sport;

  const _LeagueDetailScreen({
    required this.leagueName,
    required this.teamName,
    required this.sport,
  });

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Team?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
            'Are you sure you want to leave $teamName? You will need to rejoin using a league code to come back.',
            style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, true); // pop screen, return true = exited
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Exit Team',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text('My League',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F2A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(children: [
                      Row(children: [
                        _ShieldBadge(color: AppColors.primary, icon: Icons.shield, size: 56),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(leagueName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                              const Text('U-16 • Season 2024-25',
                                  style: TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.green.withOpacity(0.3)),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _LeagueStat(label: 'Teams', value: '8'),
                          Container(height: 40, width: 1, color: Colors.white10),
                          _LeagueStat(label: 'Matches', value: '12'),
                          Container(height: 40, width: 1, color: Colors.white10),
                          _LeagueStat(label: 'My Rank', value: '#3'),
                          Container(height: 40, width: 1, color: Colors.white10),
                          _LeagueStat(label: 'Points', value: '24'),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
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
                        const Text('My Team',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        const SizedBox(height: 14),
                        Row(children: [
                          _ShieldBadge(color: AppColors.primary, icon: Icons.shield, size: 52),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(teamName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                                Text('U16 $sport • 28 Players',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('My Team',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        const Text('Standings',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        const SizedBox(height: 12),
                        _StandingRow(
                            pos: '1', team: 'Alpha Warriors', pts: '14', isMe: false),
                        _StandingRow(
                            pos: '2', team: 'Warriors United', pts: '12', isMe: false),
                        _StandingRow(pos: '3', team: teamName, pts: '10', isMe: true),
                        _StandingRow(pos: '4', team: 'Blaze Club', pts: '8', isMe: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Exit Team Button ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmExit(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      label: const Text('Exit Team',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeagueStat extends StatelessWidget {
  final String label, value;
  const _LeagueStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}

class _StandingRow extends StatelessWidget {
  final String pos, team, pts;
  final bool isMe;
  const _StandingRow(
      {required this.pos, required this.team, required this.pts, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isMe ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(children: [
        SizedBox(
            width: 24,
            child: Text(pos,
                style: TextStyle(
                    color: isMe ? AppColors.primary : Colors.white38,
                    fontWeight: FontWeight.w700,
                    fontSize: 13))),
        Expanded(
            child: Text(team,
                style: TextStyle(
                    color: isMe ? AppColors.primary : Colors.white,
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13))),
        if (isMe) const Icon(Icons.person, color: AppColors.primary, size: 14),
        const SizedBox(width: 4),
        Text(pts,
            style: TextStyle(
                color: isMe ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ]),
    );
  }
}

// ── Profile Image Screen ──────────────────────────────────────────────

class _ProfileImageScreen extends StatelessWidget {
  const _ProfileImageScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
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
                const Text('Profile Photo',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const Spacer(),
            Stack(alignment: Alignment.center, children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=faces'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0A0A1A), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            const Text('Alex Johnson',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const Text('U16 • Forward • Falcons FC',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Camera opened! 📷'),
                            backgroundColor: AppColors.primary)),
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    label: const Text('Take Photo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gallery opened! 🖼️'),
                            backgroundColor: AppColors.primary)),
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 20),
                    label: const Text('Choose from Gallery',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white54, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}