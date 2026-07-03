import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';
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
  String? _activeLeague;
  String? _activeTeam;

  // Live data from GET /players/:id/home.
  String? _fullName;
  String? _firstName;
  String? _liveLeagueId;
  Map<String, dynamic>? _upcomingMatch;
  String? _liveSportName;
  String? _livePlayerCode;
  int? _liveQoScore;
  int _unreadCount = 0;
  int? _monthDelta; // Qo change vs the previous month (from /performance)
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    setState(() {
      _loading = _fullName == null; // full spinner only on first load
      _error = null;
    });
    try {
      final data = await SportyQoApi.playerHome();
      if (!mounted) return;
      final player = data['player'] as Map<String, dynamic>?;
      final league = data['activeLeague'] as Map<String, dynamic>?;
      final team = league?['team'] as Map<String, dynamic>?;
      final notif = data['notifications'] as Map<String, dynamic>?;
      final sport = player?['sport'] as Map<String, dynamic>?;
      setState(() {
        _upcomingMatch = data['upcomingMatch'] as Map<String, dynamic>?;
        _liveSportName = sport?['name'] as String?;
        _fullName = player?['fullName'] as String?;
        _firstName =
            (player?['fullName'] as String?)?.split(' ').first;
        _livePlayerCode = player?['playerId'] as String?;
        _liveQoScore = (player?['qoScore'] as num?)?.toInt();
        _liveLeagueId = league?['id'] as String?;
        _activeLeague = league?['name'] as String?;
        _activeTeam = team?['name'] as String?;
        _unreadCount = (notif?['unreadCount'] as int?) ?? 0;
        _loading = false;
      });
      _loadMonthDelta();
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
        _error = 'Something went wrong while loading your home.';
      });
    }
  }

  /// Best-effort: "+X this month" badge under the Qo score.
  Future<void> _loadMonthDelta() async {
    try {
      final perf = await SportyQoApi.playerPerformance();
      if (!mounted) return;
      final journey = (perf['qoJourney'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      if (journey.length >= 2) {
        final last = (journey.last['qoScore'] as num?)?.toInt() ?? 0;
        final prev =
            (journey[journey.length - 2]['qoScore'] as num?)?.toInt() ?? 0;
        setState(() => _monthDelta = last - prev);
      }
    } catch (_) {
      // Non-critical decoration; skip silently.
    }
  }

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  DateTime? get _matchDt {
    final raw = _upcomingMatch?['scheduledAt'] as String?;
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }

  String _matchDate() {
    final dt = _matchDt;
    if (dt == null) return 'TBD';
    return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}';
  }

  String _matchTime() {
    final dt = _matchDt;
    if (dt == null) return 'TBD';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    return '$h:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get _tierName {
    final score = _liveQoScore ?? 0;
    if (score >= 750) return 'Purple Card';
    if (score >= 500) return 'Blue Card';
    if (score >= 250) return 'Silver Card';
    return 'Bronze Card';
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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



  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A1A),
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_error != null && _fullName == null) {
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
                    onPressed: _loadHome,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
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
          onRefresh: _loadHome,
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          Text(_firstName ?? '—',
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
                        Text(_activeLeague ??
                            _getSportRole(
                                _liveSportName ?? widget.selectedSport),
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

                  // Profile Picture (initials — no hardcoded stock photo)
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => _ProfileImageScreen(
                                  name: _fullName ?? 'Player',
                                  subtitle: [
                                    if (_activeLeague != null) _activeLeague!,
                                    if (_activeTeam != null) _activeTeam!,
                                  ].join(' • '),
                                ))),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        color: const Color(0xFF1A1A3A),
                      ),
                      child: Center(
                        child: Text(
                          _initials(_fullName ?? ''),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
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
                            Text('${_liveQoScore ?? 0}',
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
                              Text(_tierName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (_monthDelta != null && _monthDelta != 0) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(
                                _monthDelta! > 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: const Color(0xFF7B2FFF),
                                size: 14),
                            Text(
                                '${_monthDelta! > 0 ? '+' : ''}$_monthDelta this month',
                                style: const TextStyle(
                                    color: Color(0xFF7B2FFF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ],
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
                              leagueId: _liveLeagueId,
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
                          MaterialPageRoute(
                              builder: (_) => _AllMatchesScreen(
                                  leagueId: _liveLeagueId))),
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
                child: _upcomingMatch == null
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF13132B),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(children: const [
                          Icon(Icons.event_busy,
                              color: Colors.white38, size: 32),
                          SizedBox(height: 10),
                          Text('No upcoming matches',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text(
                              'Your next match will show up here once it is scheduled.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ]),
                      )
                    : Container(
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
                              errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF13132B)),
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
                                  Text((_upcomingMatch?['homeTeam']
                                              as Map<String, dynamic>?)?['name']
                                          as String? ??
                                      'TBD',
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
                                  Text((_upcomingMatch?['awayTeam']
                                              as Map<String, dynamic>?)?['name']
                                          as String? ??
                                      'TBD',
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
                        children: [
                          Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(_matchDate(),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ]),
                          Row(children: [
                            const Icon(Icons.access_time,
                                color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(_matchTime(),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ]),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                  _upcomingMatch?['venue'] as String? ??
                                      'Venue TBD',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ),
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
                              errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF13132B)),
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
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static ({IconData icon, Color color}) _styleFor(String type) {
    switch (type) {
      case 'QO_POINTS':
        return (icon: Icons.emoji_events, color: const Color(0xFFFFB300));
      case 'LEAGUE_UPDATE':
        return (icon: Icons.sports_cricket, color: const Color(0xFF00C853));
      case 'SOCIAL':
        return (icon: Icons.favorite, color: Colors.red);
      case 'MATCH':
        return (icon: Icons.shield, color: const Color(0xFF7B2FFF));
      case 'ACHIEVEMENT':
        return (icon: Icons.star, color: const Color(0xFFFFB300));
      default:
        return (icon: Icons.notifications, color: const Color(0xFF7B2FFF));
    }
  }

  static String _relativeTime(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.notifications();
      if (!mounted) return;
      setState(() {
        _notifications = data.cast<Map<String, dynamic>>().map((n) {
          final st = _styleFor(n['type'] as String? ?? '');
          return {
            'id': n['id'],
            'icon': st.icon,
            'color': st.color,
            'title': n['title'] ?? '',
            'subtitle': n['body'] ?? '',
            'time': _relativeTime(n['createdAt'] as String?),
            'read': n['isRead'] == true,
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                    SportyQoApi.markNotificationsRead();
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
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _notifications.isEmpty
                      ? const Center(
                          child: Text('No notifications yet',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _notifications[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _notifications[i] = {
                          ..._notifications[i],
                          'read': true
                        };
                      });
                      final id = _notifications[i]['id'] as String?;
                      if (id != null) {
                        SportyQoApi.markNotificationsRead(ids: [id]);
                      }
                    },
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

class _AllMatchesScreen extends StatefulWidget {
  const _AllMatchesScreen({this.leagueId});
  final String? leagueId;

  @override
  State<_AllMatchesScreen> createState() => _AllMatchesScreenState();
}

class _AllMatchesScreenState extends State<_AllMatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

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
          final dt = DateTime.tryParse(m['scheduledAt'] as String? ?? '')?.toLocal();
          final status = (m['status'] as String? ?? 'SCHEDULED').toUpperCase();
          String label;
          Color color;
          switch (status) {
            case 'COMPLETED':
              label = (m['resultSummary'] as String?)?.isNotEmpty == true
                  ? 'Completed'
                  : 'Completed';
              color = const Color(0xFF00C853);
              break;
            case 'LIVE':
              label = 'Live';
              color = Colors.redAccent;
              break;
            case 'CANCELLED':
              label = 'Cancelled';
              color = Colors.white38;
              break;
            default:
              label = 'Upcoming';
              color = const Color(0xFF7B2FFF);
          }
          return {
            'team1': (m['homeTeam'] as Map<String, dynamic>?)?['name'] ?? 'TBD',
            'team2': (m['awayTeam'] as Map<String, dynamic>?)?['name'] ?? 'TBD',
            'date': dt == null ? '' : '${dt.day} ${_months[dt.month - 1]} ${dt.year}',
            'time': dt == null
                ? ''
                : '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}',
            'venue': m['venue'] ?? 'Venue TBD',
            'status': label,
            'statusColor': color,
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

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
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _matches.isEmpty
                      ? const Center(
                          child: Text('No matches scheduled yet',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : ListView.separated(
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
                                  child: Center(
                                      child: Text(
                                          (m['team1'] as String).isEmpty
                                              ? '?'
                                              : (m['team1'] as String)[0],
                                          style: const TextStyle(
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

class _LeagueDetailScreen extends StatefulWidget {
  final String leagueName;
  final String teamName;
  final String sport;
  final String? leagueId;

  const _LeagueDetailScreen({
    required this.leagueName,
    required this.teamName,
    required this.sport,
    this.leagueId,
  });

  @override
  State<_LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends State<_LeagueDetailScreen> {
  String get leagueName => widget.leagueName;
  String get teamName => widget.teamName;
  String get sport => widget.sport;

  List<Map<String, dynamic>> _standings = [];
  bool _loadingStandings = true;

  @override
  void initState() {
    super.initState();
    _loadStandings();
  }

  Map<String, dynamic>? get _myRow {
    for (final r in _standings) {
      if (r['name'] == teamName) return r;
    }
    return null;
  }

  String get _myRankLabel =>
      _myRow == null ? '—' : '#${_myRow!['rank']}';
  String get _myPointsLabel =>
      _myRow == null ? '—' : '${_myRow!['points']}';

  Future<void> _loadStandings() async {
    if (widget.leagueId == null) {
      setState(() => _loadingStandings = false);
      return;
    }
    try {
      final data = await SportyQoApi.leagueStandings(widget.leagueId!);
      if (!mounted) return;
      setState(() {
        _standings = data.cast<Map<String, dynamic>>();
        _loadingStandings = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStandings = false);
    }
  }

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
                              Text(sport,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13)),
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
                          _LeagueStat(
                              label: 'Teams',
                              value: '${_standings.length}'),
                          Container(height: 40, width: 1, color: Colors.white10),
                          _LeagueStat(
                              label: 'Matches',
                              value:
                                  '${_standings.fold<int>(0, (a, r) => a + ((r['played'] as num?)?.toInt() ?? 0)) ~/ 2}'),
                          Container(height: 40, width: 1, color: Colors.white10),
                          _LeagueStat(
                              label: 'My Rank', value: _myRankLabel),
                          Container(height: 40, width: 1, color: Colors.white10),
                          _LeagueStat(
                              label: 'Points', value: _myPointsLabel),
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
                                Text(sport,
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
                        if (_loadingStandings)
                          const Center(
                              child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2),
                          ))
                        else if (_standings.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No completed matches yet',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                          )
                        else
                          ..._standings.map((r) => _StandingRow(
                                pos: '${r['rank']}',
                                team: r['name'] as String? ?? '',
                                pts: '${r['points']}',
                                isMe: r['name'] == teamName,
                              )),
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
  final String name;
  final String subtitle;
  const _ProfileImageScreen({required this.name, this.subtitle = ''});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

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
                  color: const Color(0xFF1A1A3A),
                ),
                child: Center(
                  child: Text(_initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w800)),
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
            Text(name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(subtitle,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Photo upload is coming soon in a future update.'),
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
                            content: Text(
                                'Photo upload is coming soon in a future update.'),
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