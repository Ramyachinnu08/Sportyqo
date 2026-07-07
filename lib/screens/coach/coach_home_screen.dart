import 'package:flutter/material.dart';
import '../../services/sportyqo_api.dart';
import '../shared/avatar_picker.dart';
import '../shared/notifications_sheet.dart';
import 'coach_dugout_screen.dart';
import 'coach_playbook_screen.dart';
import 'coach_performance_screen.dart';
import 'coach_profile_screen.dart';
import 'create_league_screen.dart';
import 'coach_leagues_screen.dart';
import 'coach_certification_screen.dart';

const _blue = Color(0xFF1A6BFF);
const _gold = Color(0xFFE0A93B);

/// Coach shell: Home • Dugout • Playbook • Team Performance • Profile.
class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
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
          selectedItemColor: _blue,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          unselectedLabelStyle:
              const TextStyle(fontSize: 10.5, fontFamily: 'Poppins'),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Dugout'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
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

// ── COACH HOME TAB (design p.1) ───────────────────────────────────────
// SportyQo logo header + bell + avatar → "Coach <Name> ✔" identity →
// three action cards: Create League / View Leagues / Get Certified.
// Data: GET /coach/dashboard.

class _CoachHomeTab extends StatefulWidget {
  const _CoachHomeTab();

  @override
  State<_CoachHomeTab> createState() => _CoachHomeTabState();
}

class _CoachHomeTabState extends State<_CoachHomeTab> {
  bool _loading = true;
  Map<String, dynamic> _coach = const {};
  int _unread = 0;
  bool _hasLeagues = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dash = await SportyQoApi.coachDashboard() as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _coach = dash['coach'] as Map<String, dynamic>? ?? const {};
        _unread = ((dash['counts']
                    as Map<String, dynamic>?)?['unreadNotifications'] as num?)
                ?.toInt() ??
            0;
        _hasLeagues = ((dash['counts'] as Map<String, dynamic>?)?['leagues']
                    as num?)
                ?.toInt() !=
            0;
        _isVerified = _coach['isVerified'] == true;
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
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _blue))
            : RefreshIndicator(
                color: _blue,
                backgroundColor: const Color(0xFF16162E),
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  children: [
                    _logoHeader(),
                    const SizedBox(height: 22),
                    _identity(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    _actionCard(
                      icon: Icons.shield_outlined,
                      accent: _blue,
                      title: 'Create League',
                      subtitle: _hasLeagues
                          ? 'Create a new league and\nstart tracking player performance.'
                          : 'Create your first league and\nstart tracking player performance.',
                      cta: '+  Create League',
                      art: '🏆',
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreateLeagueScreen()));
                        _load();
                      },
                    ),
                    const SizedBox(height: 14),
                    _actionCard(
                      icon: Icons.groups_outlined,
                      accent: Colors.white70,
                      title: 'View Leagues',
                      subtitle: 'View and manage\nyour existing leagues.',
                      cta: 'View Leagues',
                      art: '📋',
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CoachLeaguesScreen()));
                        _load();
                      },
                    ),
                    const SizedBox(height: 14),
                    _actionCard(
                      icon: _isVerified
                          ? Icons.verified_outlined
                          : Icons.star_border_rounded,
                      accent: _gold,
                      title: _isVerified ? 'Verified Coach' : 'Get Certified',
                      subtitle: _isVerified
                          ? 'You are a verified SportyQo Coach.\nPlayers can trust your profile.'
                          : 'Become a verified SportyQo Coach\nand build player trust.',
                      cta: _isVerified ? 'View Status' : 'Get Certified',
                      art: '🏅',
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CoachCertificationScreen()));
                        _load();
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Logo header: brand mark + bell + avatar ──
  Widget _logoHeader() {
    return Row(children: [
      const Icon(Icons.bolt_rounded, color: _blue, size: 30),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic),
              children: [
                TextSpan(text: 'Sporty', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Qo', style: TextStyle(color: _blue)),
              ],
            ),
          ),
          const Text('Every Player Counts.',
              style: TextStyle(color: Colors.white54, fontSize: 10.5)),
        ]),
      ),
      GestureDetector(
        onTap: () async {
          await showNotificationsSheet(context);
          if (mounted) setState(() => _unread = 0);
        },
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
                decoration:
                    const BoxDecoration(color: _blue, shape: BoxShape.circle),
              ),
            ),
        ]),
      ),
      const SizedBox(width: 10),
      AvatarCircle(
        avatarUrl: _coach['avatarUrl'] as String?,
        name: _coach['fullName'] as String? ?? 'C',
        size: 44,
        borderColor: _blue,
      ),
    ]);
  }

  // ── "Coach Suneeth ✔" identity block ──
  Widget _identity() {
    final name = _coach['fullName'] as String? ?? 'Coach';
    final sub = <String>[
      if ((_coach['title'] as String?)?.isNotEmpty == true)
        _coach['title'] as String,
      if ((_coach['academy'] as String?)?.isNotEmpty == true)
        _coach['academy'] as String,
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Flexible(
          child: Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
        ),
        if (_isVerified) ...[
          const SizedBox(width: 8),
          const Icon(Icons.verified, color: _blue, size: 20),
        ],
      ]),
      if (sub.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(children: [
            for (var i = 0; i < sub.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('•',
                      style: TextStyle(color: _blue, fontSize: 13)),
                ),
              Flexible(
                child: Text(sub[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13.5)),
              ),
            ],
          ]),
        ),
    ]);
  }

  // ── Big action card ──
  Widget _actionCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required String cta,
    required String art,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withOpacity(0.14), const Color(0xFF0E0E22)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withOpacity(0.5)),
                  color: accent.withOpacity(0.1),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12.5, height: 1.45)),
              const SizedBox(height: 12),
              Row(children: [
                Text(cta,
                    style: TextStyle(
                        color: accent,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 15),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text(art, style: const TextStyle(fontSize: 58)),
        ]),
      ),
    );
  }
}
