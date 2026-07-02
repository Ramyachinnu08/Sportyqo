import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../auth/choose_role_screen.dart';
import '../../services/sportyqo_api.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() =>
      _CoachProfileScreenState();
}

class _CoachProfileScreenState
    extends State<CoachProfileScreen> {
  bool _notificationsOn = true;
  bool _darkMode = true;
  bool _privateProfile = false;

  // Live profile data (GET /me, /coach/dashboard, /coach/performance,
  // /coach/certifications). Placeholders show until loaded.
  String _name = '';
  String _title = 'Coach';
  String _academy = '';
  String _location = '';
  String _bio = '';
  String _yearsExp = '—';
  bool _isVerified = false;
  int _playerCount = 0;
  int _leagueCount = 0;
  int _matchCount = 0;
  int _recCount = 0;
  String _certTitle = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final me = await SportyQoApi.me();
      if (!mounted) return;
      setState(() {
        _name = me['fullName'] as String? ?? '';
        _title = me['title'] as String? ?? 'Coach';
        _academy = me['academy'] as String? ?? '';
        _location = me['location'] as String? ?? '';
        _bio = me['bio'] as String? ?? '';
        _isVerified = me['isVerifiedCoach'] == true;
        final y = me['yearsExperience'];
        _yearsExp = y == null ? '—' : '$y';
      });
    } catch (_) {}
    try {
      final dash = await SportyQoApi.coachDashboard();
      if (!mounted) return;
      final counts = dash['counts'] as Map<String, dynamic>? ?? {};
      setState(() {
        _playerCount = (counts['players'] as num?)?.toInt() ?? 0;
        _leagueCount = (counts['leagues'] as num?)?.toInt() ?? 0;
        _recCount = (counts['recommendations'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
    try {
      final perf = await SportyQoApi.coachPerformance();
      if (!mounted) return;
      final totals = perf['totals'] as Map<String, dynamic>? ?? {};
      setState(() {
        _matchCount = (totals['matchesCompleted'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
    try {
      final certs = await SportyQoApi.coachCertifications();
      if (!mounted) return;
      final approved = certs.cast<Map<String, dynamic>>().where(
          (c) => (c['status'] as String?)?.toUpperCase() == 'APPROVED');
      setState(() {
        _certTitle = approved.isEmpty
            ? ''
            : approved.first['title'] as String? ?? '';
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 0),
                      child: Row(children: [
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: const [
                              Text('Coach Profile',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight.w800)),
                              Text(
                                  'View coach details and track impact',
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        // Share button
                        GestureDetector(
                          onTap: () => _shareProfile(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius:
                                BorderRadius.circular(10)),
                            child: const Icon(
                                Icons.ios_share_outlined,
                                color: Colors.white,
                                size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 3 dots menu
                        GestureDetector(
                          onTap: () =>
                              _showMoreMenu(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius:
                                BorderRadius.circular(10)),
                            child: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 18),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // ── Profile Info ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: () =>
                                _showPhotoOptions(context),
                            child: Stack(children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                      const Color(0xFF00C853),
                                      width: 2),
                                  color:
                                  const Color(0xFF1A1A1A),
                                ),
                                child: const Center(
                                    child: Text('👤',
                                        style: TextStyle(
                                            fontSize: 40))),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF00C853),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(
                                            0xFF0A0A0A),
                                        width: 1.5),
                                  ),
                                  child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 12),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF1A6BFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(
                                            0xFF0A0A0A),
                                        width: 1.5),
                                  ),
                                  child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 13),
                                ),
                              ),
                            ]),
                          ),

                          const SizedBox(width: 16),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Flexible(
                                    child: Text(
                                        _name.isEmpty ? 'Coach' : _name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 6),
                                  if (_isVerified)
                                    const Icon(Icons.verified,
                                        color: Color(0xFF1A6BFF),
                                        size: 16),
                                ]),
                                Text(_title,
                                    style: const TextStyle(
                                        color:
                                        Color(0xFF00C853),
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w600)),
                                Text(
                                    _academy,
                                    style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12)),
                                const SizedBox(height: 6),
                                if (_location.isNotEmpty)
                                  Row(children: [
                                    const Icon(
                                        Icons
                                            .location_on_outlined,
                                        color: Colors.white38,
                                        size: 12),
                                    const SizedBox(width: 3),
                                    Text(_location,
                                        style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11)),
                                  ]),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white38,
                                      size: 12),
                                  const SizedBox(width: 3),
                                  Text('$_yearsExp Years Experience',
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11)),
                                ]),
                                const SizedBox(height: 4),
                                if (_certTitle.isNotEmpty)
                                  Row(children: [
                                    const Icon(
                                        Icons
                                            .workspace_premium_outlined,
                                        color: Colors.white38,
                                        size: 12),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                          _certTitle,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11)),
                                    ),
                                  ]),
                                const SizedBox(height: 6),
                                if (_isVerified)
                                  Row(children: const [
                                    Icon(Icons.check_circle,
                                        color: Color(0xFF00C853),
                                        size: 14),
                                    SizedBox(width: 4),
                                    Text('Verified Coach',
                                        style: TextStyle(
                                            color:
                                            Color(0xFF00C853),
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.w600)),
                                  ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Stats Row ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius:
                          BorderRadius.circular(16),
                          border:
                          Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            _StatCol(
                                icon: Icons.people_outline,
                                value: '$_playerCount',
                                label: 'Total\nPlayers'),
                            _Divider(),
                            _StatCol(
                                icon: Icons
                                    .emoji_events_outlined,
                                value: '$_leagueCount',
                                label: 'Leagues'),
                            _Divider(),
                            _StatCol(
                                icon: Icons
                                    .sports_cricket_outlined,
                                value: '$_matchCount',
                                label: 'Matches'),
                            _Divider(),
                            _StatCol(
                                icon: Icons
                                    .access_time_outlined,
                                value: _yearsExp,
                                label: 'Years\nExperience'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── About Coach ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius:
                          BorderRadius.circular(16),
                          border:
                          Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(children: const [
                              Icon(Icons.person_outline,
                                  color: Color(0xFF00C853),
                                  size: 18),
                              SizedBox(width: 8),
                              Text('About Coach',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.w700,
                                      fontSize: 15)),
                            ]),
                            const SizedBox(height: 10),
                            Text(
                                _bio.isEmpty
                                    ? 'No bio added yet. Tap Edit Profile to add one.'
                                    : _bio,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                    height: 1.6)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Experience ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius:
                          BorderRadius.circular(16),
                          border:
                          Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(children: const [
                              Icon(
                                  Icons
                                      .calendar_today_outlined,
                                  color: Color(0xFF00C853),
                                  size: 18),
                              SizedBox(width: 8),
                              Text('Experience',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.w700,
                                      fontSize: 15)),
                            ]),
                            const SizedBox(height: 16),
                            _ExperienceTile(
                              period: 'Present',
                              role: _title,
                              org: _academy.isEmpty
                                  ? 'Independent'
                                  : _academy,
                              desc: _bio.isEmpty
                                  ? 'Coaching on SportyQo.'
                                  : _bio,
                              isActive: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Recommended Players ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius:
                          BorderRadius.circular(16),
                          border:
                          Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: const [
                                Row(children: [
                                  Icon(Icons.people_outline,
                                      color:
                                      Color(0xFF00C853),
                                      size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                      'Recommended Players',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.w700,
                                          fontSize: 15)),
                                ]),
                                Row(children: [
                                  Text('View All',
                                      style: TextStyle(
                                          color: Color(
                                              0xFF1A6BFF),
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.w600)),
                                  Icon(Icons.chevron_right,
                                      color: Color(0xFF1A6BFF),
                                      size: 16),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                _RecommendCard(
                                    value: '$_recCount',
                                    label:
                                    'Players\nRecommended',
                                    icon: Icons.people),
                                _RecommendCard(
                                    value: '$_playerCount',
                                    label: 'Players\nCoached',
                                    icon: Icons
                                        .check_circle_outline,
                                    color: const Color(
                                        0xFF00C853)),
                                _RecommendCard(
                                    value: '$_matchCount',
                                    label: 'Matches\nCompleted',
                                    icon: Icons
                                        .emoji_events_outlined,
                                    color: const Color(
                                        0xFFFFB300)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding:
                              const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.03),
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white10),
                              ),
                              child: Row(children: const [
                                Icon(Icons.info_outline,
                                    color: Colors.white38,
                                    size: 14),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                      'Helping players get noticed by academies and clubs.',
                                      style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12)),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Settings & Logout ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      child: Column(children: [
                        _SettingsItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () =>
                              _showSettings(context),
                        ),
                        const SizedBox(height: 8),
                        _SettingsItem(
                          icon: Icons.logout,
                          label: 'Logout',
                          isLogout: true,
                          onTap: () =>
                              _showLogout(context),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3 Dots Menu ──
  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Options',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // Edit Profile
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853)
                      .withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Color(0xFF00C853), size: 20),
              ),
              title: const Text('Edit Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              subtitle: const Text(
                  'Update your name, photo and details',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right,
                  color: Colors.white24),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEditProfile(context);
              },
            ),

            const Divider(color: Colors.white10),

            // Share Profile
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6BFF)
                      .withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_outlined,
                    color: Color(0xFF1A6BFF), size: 20),
              ),
              title: const Text('Share Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              subtitle: const Text(
                  'Share your coach profile link',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right,
                  color: Colors.white24),
              onTap: () {
                Navigator.pop(sheetContext);
                _shareProfile(context);
              },
            ),

            const Divider(color: Colors.white10),

            // Report
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.report_outlined,
                    color: Colors.red, size: 20),
              ),
              title: const Text('Report',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              subtitle: const Text(
                  'Report an issue or concern',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right,
                  color: Colors.white24),
              onTap: () {
                Navigator.pop(sheetContext);
                _showReport(context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Edit Profile ──
  void _showEditProfile(BuildContext context) {
    final nameController = TextEditingController(text: _name);
    final roleController = TextEditingController(text: _title);
    final orgController = TextEditingController(text: _academy);
    final bioController = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),

              // Avatar
              Center(
                child: Stack(children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF00C853),
                          width: 2),
                      color: const Color(0xFF1A1A1A),
                    ),
                    child: const Center(
                        child: Text('👤',
                            style:
                            TextStyle(fontSize: 40))),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              _EditField(
                  label: 'Full Name',
                  controller: nameController),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Role',
                  controller: roleController),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Organisation',
                  controller: orgController),
              const SizedBox(height: 12),
              _EditField(
                  label: 'Bio',
                  controller: bioController,
                  maxLines: 3),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await ApiClient.instance
                          .patch('/me/profile', body: {
                        'fullName': nameController.text.trim(),
                        'title': roleController.text.trim(),
                        'academy': orgController.text.trim(),
                        'bio': bioController.text.trim(),
                      });
                      if (!mounted) return;
                      setState(() {
                        _name = nameController.text.trim();
                        _title = roleController.text.trim();
                        _academy = orgController.text.trim();
                        _bio = bioController.text.trim();
                      });
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                          Text('Profile updated! ✅'),
                          backgroundColor:
                          Color(0xFF00C853),
                        ),
                      );
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content:
                          Text('Could not update profile'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF00C853),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Share Profile ──
  void _shareProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // Profile link
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(children: [
                const Icon(Icons.link,
                    color: Color(0xFF00C853), size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                      'sportyqo.app/coach/rahul-sharma',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13)),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(
                        text:
                        'sportyqo.app/coach/rahul-sharma'));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                        Text('Profile link copied! 📋'),
                        backgroundColor:
                        Color(0xFF00C853),
                      ),
                    );
                  },
                  child: const Text('Copy',
                      style: TextStyle(
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ]),
            ),

            const SizedBox(height: 20),
            const Text('Share via',
                style: TextStyle(
                    color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                _ShareOption(
                    emoji: '💬',
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content:
                        Text('Opening WhatsApp...'),
                        backgroundColor:
                        Color(0xFF25D366),
                      ));
                    }),
                _ShareOption(
                    emoji: '✉️',
                    label: 'Email',
                    color: const Color(0xFF1A6BFF),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text('Opening Email...'),
                        backgroundColor:
                        Color(0xFF1A6BFF),
                      ));
                    }),
                _ShareOption(
                    emoji: '📱',
                    label: 'Message',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content:
                        Text('Opening Messages...'),
                        backgroundColor: Colors.purple,
                      ));
                    }),
              ],
            ),

            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style:
                    TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  // ── Report ──
  void _showReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'What would you like to report?',
                style: TextStyle(
                    color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 16),
            ...[
              'Inappropriate content',
              'Fake profile',
              'Spam or misleading',
              'Harassment or bullying',
              'Other',
            ].map((reason) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flag_outlined,
                  color: Colors.red, size: 20),
              title: Text(reason,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                        'Reported: $reason. Thank you! ✅'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            )),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  // ── Photo Options ──
  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Profile Photo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFF00C853)),
              title: const Text('Take Photo',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Camera opened 📷'),
                      backgroundColor: Color(0xFF00C853)),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.photo_library,
                  color: Color(0xFF00C853)),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Gallery opened 🖼️'),
                      backgroundColor: Color(0xFF00C853)),
                );
              },
            ),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style:
                    TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  // ── Settings ──
  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // Notifications
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'Get match & league alerts',
                trailing: Switch(
                  value: _notificationsOn,
                  onChanged: (v) {
                    setSheetState(
                            () => _notificationsOn = v);
                    setState(() => _notificationsOn = v);
                  },
                  activeColor: const Color(0xFF00C853),
                ),
              ),

              const Divider(color: Colors.white10),

              // Dark Mode
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                subtitle: 'Switch app appearance',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (v) {
                    setSheetState(() => _darkMode = v);
                    setState(() => _darkMode = v);
                  },
                  activeColor: const Color(0xFF00C853),
                ),
              ),

              const Divider(color: Colors.white10),

              // Private Profile
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Private Profile',
                subtitle: 'Only followers can see your profile',
                trailing: Switch(
                  value: _privateProfile,
                  onChanged: (v) {
                    setSheetState(
                            () => _privateProfile = v);
                    setState(() => _privateProfile = v);
                  },
                  activeColor: const Color(0xFF00C853),
                ),
              ),

              const Divider(color: Colors.white10),

              // Privacy
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Color(0xFF00C853),
                    size: 22),
                title: const Text('Privacy Policy',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                subtitle: const Text(
                    'Read our privacy policy',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white24),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content:
                        Text('Opening Privacy Policy...'),
                        backgroundColor:
                        Color(0xFF00C853)),
                  );
                },
              ),

              const Divider(color: Colors.white10),

              // Terms
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF00C853),
                    size: 22),
                title: const Text('Terms of Service',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                subtitle: const Text(
                    'Read our terms and conditions',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white24),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Opening Terms of Service...'),
                        backgroundColor:
                        Color(0xFF00C853)),
                  );
                },
              ),

              const Divider(color: Colors.white10),

              // Help
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF00C853),
                    size: 22),
                title: const Text('Help & Support',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                subtitle: const Text(
                    'Get help or contact us',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: Colors.white24),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content:
                        Text('Opening Help & Support...'),
                        backgroundColor:
                        Color(0xFF00C853)),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Logout from settings too
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 200),
                        () => _showLogout(context),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout,
                          color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Logout',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logout ──
  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800)),
        content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Cancel',
                  style:
                  TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AuthService.logout();
              Future.microtask(() =>
                  Navigator.of(context)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) =>
                        const ChooseRoleScreen()),
                        (route) => false,
                  ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _EditField(
      {required this.label,
        required this.controller,
        this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
              color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _ShareOption extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _ShareOption(
      {required this.emoji,
        required this.label,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child:
          Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12)),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Widget trailing;
  const _SettingsTile(
      {required this.icon,
        required this.label,
        required this.subtitle,
        required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
      Icon(icon, color: const Color(0xFF00C853), size: 22),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style:
          const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: trailing,
    );
  }
}

class _StatCol extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatCol(
      {required this.icon,
        required this.value,
        required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.white38, size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800)),
      Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white38, fontSize: 10)),
    ]);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40, width: 1, color: Colors.white10);
  }
}

class _ExperienceTile extends StatelessWidget {
  final String period, role, org, desc;
  final bool isActive;
  const _ExperienceTile(
      {required this.period,
        required this.role,
        required this.org,
        required this.desc,
        required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF1A6BFF)
                  : Colors.white24,
            ),
          ),
          Container(
              width: 1, height: 60, color: Colors.white10),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(period,
                  style: TextStyle(
                      color: isActive
                          ? const Color(0xFF1A6BFF)
                          : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Text(role,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text(org,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12)),
              const SizedBox(height: 4),
              Text(desc,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _RecommendCard(
      {required this.value,
        required this.label,
        required this.icon,
        this.color = const Color(0xFF1A6BFF)});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 6),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800)),
      Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white38, fontSize: 10)),
    ]);
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLogout;
  final VoidCallback onTap;
  const _SettingsItem(
      {required this.icon,
        required this.label,
        required this.onTap,
        this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isLogout
                ? Colors.red.withOpacity(0.3)
                : Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: isLogout ? Colors.red : const Color(0xFF00C853),
            size: 22),
        title: Text(label,
            style: TextStyle(
                color: isLogout ? Colors.red : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15)),
        trailing: isLogout
            ? null
            : const Icon(Icons.chevron_right,
            color: Colors.white24),
      ),
    );
  }
}