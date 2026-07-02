import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import 'coach_dugout_screen.dart';
import 'coach_playbook_screen.dart';
import 'coach_performance_screen.dart';
import 'coach_profile_screen.dart';
import 'create_league_screen.dart';
import 'coach_leagues_screen.dart';
import 'coach_certification_screen.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() =>
      _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const _CoachHomeTab(),
    const CoachDugoutScreen(),
    const CoachPlaybookScreen(),
    const CoachPerformanceScreen(),
    const CoachProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00C853),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins'),
          unselectedLabelStyle:
          const TextStyle(fontSize: 11, fontFamily: 'Poppins'),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Dugout'),
            BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline),
                activeIcon: Icon(Icons.play_circle),
                label: 'Playbook'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Team Performance'),
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

// ── Coach Home Tab ────────────────────────────────────────────────────

class _CoachHomeTab extends StatefulWidget {
  const _CoachHomeTab();

  @override
  State<_CoachHomeTab> createState() => _CoachHomeTabState();
}

class _CoachHomeTabState extends State<_CoachHomeTab> {
  // Live data from GET /coach/dashboard (mock text remains as fallback).
  String? _coachName;
  String? _coachTitle;
  String? _academy;
  bool _isVerified = true;
  int _playerCount = 0;
  int _leagueCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await SportyQoApi.coachDashboard();
      if (!mounted) return;
      final coach = data['coach'] as Map<String, dynamic>?;
      final counts = data['counts'] as Map<String, dynamic>?;
      setState(() {
        _coachName = coach?['fullName'] as String?;
        _coachTitle = coach?['title'] as String?;
        _academy = coach?['academy'] as String?;
        _isVerified = (coach?['isVerified'] as bool?) ?? false;
        _playerCount = (counts?['players'] as num?)?.toInt() ?? 0;
        _leagueCount = (counts?['leagues'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {
      // Offline / not logged in: keep mock visuals.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Profile image — left side
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://i.ibb.co/pjLXfmH4/29.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bolt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('SportyQo',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        Text('Every Player Counts.',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9)),
                      ],
                    ),
                    const Spacer(),
                    // Bell
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const _CoachNotificationScreen())),
                      child: Stack(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle),
                          child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22),
                        ),
                        Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF00C853),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF0A0A0A),
                                        width: 1.5)))),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    // Profile avatar — right side
                    GestureDetector(
                      onTap: () => _showProfileQuick(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF00C853),
                              width: 2),
                          color: const Color(0xFF1A1A1A),
                        ),
                        child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Coach Name ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(_coachName ?? 'Coach',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      if (_isVerified)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C853),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 14),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(_coachTitle ?? 'Coach',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 14)),
                      const Text(' • ',
                          style: TextStyle(
                              color: Colors.white24, fontSize: 14)),
                      Flexible(
                        child: Text(_academy ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14)),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Card 1: Create League ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateLeagueScreen())),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            'https://i.ibb.co/W4FHNPtR/1ab.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF0A0A1A)),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFF0A0A1A)
                                      .withOpacity(0.92),
                                  const Color(0xFF0A0A1A)
                                      .withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF00C853)
                                    .withOpacity(0.5),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853)
                                      .withOpacity(0.15),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFF00C853)
                                          .withOpacity(0.3)),
                                ),
                                child: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF00C853),
                                    size: 24),
                              ),
                              const SizedBox(height: 16),
                              const Text('Create League',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              const Text(
                                  'Create your first league and\nstart tracking player performance.',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.5)),
                              const SizedBox(height: 16),
                              Row(children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const CreateLeagueScreen())),
                                  child: const Text(
                                      '+ Create League',
                                      style: TextStyle(
                                          color: Color(0xFF00C853),
                                          fontSize: 14,
                                          fontWeight:
                                          FontWeight.w700)),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00C853),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Card 2: View Leagues ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CoachLeaguesScreen())),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            'https://i.ibb.co/9mWLqgf2/1ac.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF111111)),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFF111111)
                                      .withOpacity(0.92),
                                  const Color(0xFF111111)
                                      .withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white12),
                                ),
                                child: const Icon(
                                    Icons.people_outline,
                                    color: Colors.white60,
                                    size: 24),
                              ),
                              const SizedBox(height: 16),
                              const Text('View Leagues',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              const Text(
                                  'View and manage\nyour existing leagues.',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.5)),
                              const SizedBox(height: 16),
                              Row(children: [
                                const Text('View Leagues',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w700)),
                                const SizedBox(width: 12),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white24),
                                  ),
                                  child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white60,
                                      size: 18),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Card 3: Get Certified ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const CoachCertificationScreen())),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            'https://i.ibb.co/cXMzhM7N/1ad.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF0D0900)),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFF0D0900)
                                      .withOpacity(0.92),
                                  const Color(0xFF0D0900)
                                      .withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFFFB300)
                                    .withOpacity(0.5),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB300)
                                      .withOpacity(0.15),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFFFB300)
                                          .withOpacity(0.3)),
                                ),
                                child: const Icon(
                                    Icons.star_outline,
                                    color: Color(0xFFFFB300),
                                    size: 24),
                              ),
                              const SizedBox(height: 16),
                              const Text('Get Certified',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              const Text(
                                  'Become a verified SportyQo Coach\nand build player trust.',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.5)),
                              const SizedBox(height: 16),
                              Row(children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const CoachCertificationScreen())),
                                  child: const Text('Get Certified',
                                      style: TextStyle(
                                          color: Color(0xFFFFB300),
                                          fontSize: 14,
                                          fontWeight:
                                          FontWeight.w700)),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFB300),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 18),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
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

  void _showProfileQuick(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF00C853), width: 2),
                color: const Color(0xFF1A1A1A),
              ),
              child: const Icon(Icons.person,
                  size: 36, color: Colors.white38),
            ),
            const SizedBox(height: 12),
            Text(_coachName ?? 'Coach',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text(
                [
                  if ((_coachTitle ?? '').isNotEmpty) _coachTitle,
                  if ((_academy ?? '').isNotEmpty) _academy,
                ].join(' • '),
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(label: 'Players', value: '$_playerCount'),
                _StatChip(label: 'Leagues', value: '$_leagueCount'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Coach Notification Screen ─────────────────────────────────────────

class _CoachNotificationScreen extends StatefulWidget {
  const _CoachNotificationScreen();

  @override
  State<_CoachNotificationScreen> createState() =>
      _CoachNotificationScreenState();
}

class _CoachNotificationScreenState
    extends State<_CoachNotificationScreen> {
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
        return (icon: Icons.person_add, color: const Color(0xFF00C853));
      case 'MATCH':
        return (icon: Icons.sports_cricket, color: const Color(0xFF1A6BFF));
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
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius:
                            BorderRadius.circular(20)),
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
                      _notifications = _notifications
                          .map((n) => {...n, 'read': true})
                          .toList();
                    });
                    SportyQoApi.markNotificationsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All marked as read ✅'),
                        backgroundColor: Color(0xFF00C853),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Mark all read',
                      style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Notification List ──
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00C853)))
                  : _notifications.isEmpty
                      ? const Center(
                          child: Text('No notifications yet',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14)))
                      : ListView.separated(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _notifications[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _notifications[i] = {
                          ..._notifications[i],
                          'read': true,
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
                            ? const Color(0xFF111111)
                            : const Color(0xFF00C853)
                            .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: n['read'] as bool
                              ? Colors.white10
                              : const Color(0xFF00C853)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (n['color'] as Color)
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                              n['icon'] as IconData,
                              color: n['color'] as Color,
                              size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(
                                        n['title'] as String,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.w700,
                                            fontSize: 14))),
                                if (!(n['read'] as bool))
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration:
                                      const BoxDecoration(
                                          color: Color(
                                              0xFF00C853),
                                          shape: BoxShape
                                              .circle)),
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
                                      color: Colors.white38,
                                      fontSize: 11)),
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

// ── Widgets ───────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800)),
      Text(label,
          style: const TextStyle(
              color: Colors.white38, fontSize: 12)),
    ]);
  }
}