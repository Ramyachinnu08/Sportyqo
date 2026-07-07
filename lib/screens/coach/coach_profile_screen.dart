import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/sportyqo_api.dart';
import '../../services/auth_service.dart';
import '../auth/choose_role_screen.dart';
import '../shared/app_toast.dart';
import '../shared/avatar_picker.dart';

/// Coach Profile (design p.9): identity card with certification lines →
/// stats row (Players / Leagues / Certificates / Years) → About Coach →
/// Experience → Recommended Players impact card → settings & logout.
/// Data: /me, /coach/dashboard, /coach/certifications.
class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  bool _loading = true;

  String _name = '';
  String _title = '';
  String _academy = '';
  String _bio = '';
  String _location = '';
  String? _avatarUrl;
  int? _years;
  bool _isVerified = false;
  Map<String, dynamic> _counts = const {};
  List<Map<String, dynamic>> _certs = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        SportyQoApi.me(),
        SportyQoApi.coachDashboard(),
        SportyQoApi.coachCertifications(),
      ]);
      if (!mounted) return;
      final me = results[0] as Map<String, dynamic>;
      final dash = results[1] as Map<String, dynamic>;
      setState(() {
        _name = me['fullName'] as String? ?? '';
        _title = me['title'] as String? ?? '';
        _academy = me['academy'] as String? ?? '';
        _bio = me['bio'] as String? ?? '';
        _location = me['location'] as String? ?? '';
        _avatarUrl = me['avatarUrl'] as String?;
        _years = (me['yearsExperience'] as num?)?.toInt();
        _isVerified = me['isVerifiedCoach'] == true;
        _counts = dash['counts'] as Map<String, dynamic>? ?? const {};
        _certs = (results[2] as List<dynamic>).cast<Map<String, dynamic>>();
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
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: const Color(0xFF16162E),
                onRefresh: _loadProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    _header(),
                    const SizedBox(height: 16),
                    _identityCard(),
                    const SizedBox(height: 14),
                    _statsRow(),
                    const SizedBox(height: 14),
                    _aboutCard(),
                    const SizedBox(height: 14),
                    _experienceCard(),
                    const SizedBox(height: 14),
                    _recommendedCard(),
                    const SizedBox(height: 18),
                    _settingsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header ──
  Widget _header() => Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Coach Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            Text('View coach details and track impact',
                style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ),
        GestureDetector(
          onTap: () => _shareProfile(context),
          child: Column(children: const [
            Icon(Icons.ios_share, color: Colors.white, size: 20),
            SizedBox(height: 2),
            Text('Share',
                style: TextStyle(color: Colors.white54, fontSize: 9.5)),
          ]),
        ),
        const SizedBox(width: 18),
        GestureDetector(
          onTap: () => _showEditProfile(context),
          child: Column(children: const [
            Icon(Icons.more_horiz, color: Colors.white, size: 20),
            SizedBox(height: 2),
            Text('More',
                style: TextStyle(color: Colors.white54, fontSize: 9.5)),
          ]),
        ),
      ]);

  // ── Identity card ──
  Widget _identityCard() {
    final firstCert = _certs.isNotEmpty ? _certs.first : null;

    Widget infoRow(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(children: [
            Icon(icon, size: 13, color: Colors.white54),
            const SizedBox(width: 7),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ]),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          AvatarCircle(
            avatarUrl: _avatarUrl,
            name: _name.isEmpty ? 'C' : _name,
            size: 92,
            borderColor: AppColors.primary,
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: () async {
                final url = await pickAndUploadAvatar(
                    context, ImageSource.gallery,
                    accent: AppColors.primary);
                if (url != null && mounted) {
                  setState(() => _avatarUrl = url);
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B38),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(_name.isEmpty ? 'Coach' : _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ),
              if (_isVerified) ...[
                const SizedBox(width: 5),
                const Icon(Icons.verified,
                    color: AppColors.primaryLight, size: 15),
              ],
            ]),
            if (_title.isNotEmpty)
              Text(_title,
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            if (_academy.isNotEmpty)
              infoRow(Icons.shield_outlined, _academy),
            if (_location.isNotEmpty || _years != null)
              infoRow(
                  Icons.location_on_outlined,
                  [
                    if (_location.isNotEmpty) _location,
                    if (_years != null) '${_years}+ Years Experience',
                  ].join('  •  ')),
            if (firstCert != null)
              infoRow(Icons.workspace_premium_outlined,
                  firstCert['title'] as String? ?? ''),
            if (_isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('✓ Verified Coach',
                      style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  // ── Stats row ──
  Widget _statsRow() {
    Widget stat(IconData icon, String value, String label) => Expanded(
          child: Column(children: [
            Icon(icon, size: 17, color: AppColors.primaryLight),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        stat(Icons.people_outline,
            '${(_counts['players'] as num?)?.toInt() ?? 0}',
            'Total\nPlayers'),
        stat(Icons.emoji_events_outlined,
            '${(_counts['leagues'] as num?)?.toInt() ?? 0}', 'Leagues'),
        stat(Icons.workspace_premium_outlined, '${_certs.length}',
            'Certificates'),
        stat(Icons.calendar_today_outlined,
            _years == null ? '—' : '${_years}+', 'Years\nExperience'),
      ]),
    );
  }

  // ── About Coach (with the edit pencil) ──
  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person_outline,
              color: AppColors.primaryLight, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('About Coach',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
          GestureDetector(
            onTap: () => _showEditProfile(context),
            child: const Icon(Icons.edit_outlined,
                color: Colors.white38, size: 18),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
            _bio.isEmpty
                ? 'No bio added yet. Tap the pencil to add one.'
                : _bio,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13, height: 1.6)),
      ]),
    );
  }

  // ── Experience ──
  Widget _experienceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.work_outline, color: AppColors.primaryLight, size: 18),
          SizedBox(width: 8),
          Text('Experience',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
            Container(width: 2, height: 54, color: Colors.white10),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  _years == null
                      ? 'Present'
                      : '${DateTime.now().year - _years!} – Present',
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(_title.isEmpty ? 'Coach' : _title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text(
                  [
                    if (_academy.isNotEmpty) _academy,
                    if (_location.isNotEmpty) _location,
                  ].join(', '),
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
              if (_bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11.5,
                          height: 1.4)),
                ),
            ]),
          ),
        ]),
      ]),
    );
  }

  // ── Recommended Players impact card ──
  Widget _recommendedCard() {
    final recs = (_counts['recommendations'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.recommend_outlined,
              color: AppColors.primaryLight, size: 18),
          SizedBox(width: 8),
          Text('Recommended Players',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withOpacity(0.12),
              border:
                  Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: const Icon(Icons.person_search_outlined,
                color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 12),
          Text('$recs',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          const Text('Players\nRecommended',
              style: TextStyle(
                  color: Colors.white54, fontSize: 11, height: 1.3)),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: const [
            Icon(Icons.thumb_up_alt_outlined,
                color: Colors.white38, size: 14),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Helping players get noticed by academies and clubs.',
                  style: TextStyle(color: Colors.white54, fontSize: 11.5)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Settings & Logout ──
  Widget _settingsSection() {
    Widget item(IconData icon, String label, VoidCallback onTap,
            {bool danger = false}) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF14142B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(children: [
              Icon(icon,
                  size: 18,
                  color: danger ? Colors.redAccent : Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: danger ? Colors.redAccent : Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right,
                  color: Colors.white24, size: 18),
            ]),
          ),
        );
    return Column(children: [
      item(Icons.edit_outlined, 'Edit Profile',
          () => _showEditProfile(context)),
      item(Icons.share_outlined, 'Share Profile',
          () => _shareProfile(context)),
      item(Icons.logout, 'Logout', () => _showLogout(context),
          danger: true),
    ]);
  }

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
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
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
                  AvatarCircle(
                    avatarUrl: _avatarUrl,
                    name: _name,
                    size: 80,
                    borderColor: const Color(0xFF00C853),
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
                    final name = nameController.text.trim();
                    if (name.length < 2) {
                      AppToast.error(
                          sheetCtx, 'Please enter your full name');
                      return;
                    }
                    Navigator.pop(sheetCtx);
                    try {
                      await ApiClient.instance
                          .patch('/me/profile', body: {
                        'fullName': name,
                        'title': roleController.text.trim(),
                        'academy': orgController.text.trim(),
                        'bio': bioController.text.trim(),
                      });
                      if (!mounted) return;
                      setState(() {
                        _name = name;
                        _title = roleController.text.trim();
                        _academy = orgController.text.trim();
                        _bio = bioController.text.trim();
                      });
                      AppToast.success(
                          this.context, 'Profile updated! ✅');
                    } on ApiException catch (e) {
                      if (!mounted) return;
                      AppToast.error(this.context, e.message);
                    } catch (_) {
                      if (!mounted) return;
                      AppToast.error(
                          this.context, 'Could not update profile');
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

