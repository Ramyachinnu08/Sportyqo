import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../auth/choose_role_screen.dart';
import '../shared/app_toast.dart';
import '../shared/avatar_picker.dart';

/// Profile (design p.9): identity block (avatar + camera, name +
/// verified, sport, location/school/club rows) → Academy Experience
/// (editable, /me/academy) → Recommendations (real coach
/// recommendations) → Edit / Share actions. Data: GET /me and
/// GET /players/:id/profile.
class ProfileScreen extends StatefulWidget {
  final String? playerId;
  const ProfileScreen({super.key, this.playerId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _me;
  Map<String, dynamic>? _profile;

  List<Map<String, dynamic>> get _academy =>
      ((_profile?['academyHistory'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _recs =>
      ((_profile?['recommendations'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait(
          [SportyQoApi.me(), SportyQoApi.playerProfile()]);
      if (!mounted) return;
      setState(() {
        _me = results[0] as Map<String, dynamic>;
        _profile = results[1] as Map<String, dynamic>;
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
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Row(children: [
                      if (Navigator.canPop(context))
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      const Expanded(
                        child: Text('Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                      ),
                      GestureDetector(
                        onTap: _showSettings,
                        child: const Icon(Icons.settings_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    _identityBlock(),
                    const SizedBox(height: 18),
                    _academyCard(),
                    const SizedBox(height: 14),
                    _recommendationsCard(),
                    const SizedBox(height: 18),
                    _actionsRow(),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Identity block ──
  Widget _identityBlock() {
    final me = _me ?? const {};
    final name = me['fullName'] as String? ?? 'Player';
    final sport = (me['sport'] as Map<String, dynamic>?)?['name'] as String?;

    Widget infoRow(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 8),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12.5)),
            ),
          ]),
        );

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primary.withOpacity(0.6), width: 1.5),
          ),
          child: AvatarCircle(
            avatarUrl: me['avatarUrl'] as String?,
            name: name,
            size: 104,
            borderColor: Colors.transparent,
            borderWidth: 0,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: _changePhoto,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B38),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  size: 15, color: Colors.white),
            ),
          ),
        ),
      ]),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ),
            if (me['isVerified'] == true) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified,
                  color: AppColors.primaryLight, size: 17),
            ],
          ]),
          if (sport != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(children: [
                Text(sport,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13)),
                if ((me['playerId'] as String?) != null) ...[
                  const Text('  •  ',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 13)),
                  Text(me['playerId'] as String,
                      style: const TextStyle(
                          color: AppColors.primaryLight, fontSize: 13)),
                ],
              ]),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white12, height: 1),
          ),
          if ((me['location'] as String?)?.isNotEmpty == true)
            infoRow(Icons.location_on_outlined, me['location'] as String),
          if ((me['schoolAcademy'] as String?)?.isNotEmpty == true)
            infoRow(Icons.school_outlined, me['schoolAcademy'] as String),
          if ((me['club'] as String?)?.isNotEmpty == true)
            infoRow(Icons.shield_outlined, me['club'] as String),
          if ((me['location'] as String?)?.isNotEmpty != true &&
              (me['schoolAcademy'] as String?)?.isNotEmpty != true &&
              (me['club'] as String?)?.isNotEmpty != true)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: _showEditProfile,
                child: const Text('Add your location, school and club →',
                    style: TextStyle(
                        color: AppColors.primaryLight, fontSize: 12)),
              ),
            ),
        ]),
      ),
    ]);
  }

  // ── Academy Experience ──
  Widget _academyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.school_rounded,
              color: AppColors.primaryLight, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Academy Experience',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
          GestureDetector(
            onTap: () => _showAcademySheet(),
            child: const Icon(Icons.add_circle_outline,
                color: AppColors.primaryLight, size: 20),
          ),
        ]),
        const SizedBox(height: 14),
        if (_academy.isEmpty)
          const Text(
            'No academies added yet.\nTap + to add where you have trained.',
            style: TextStyle(
                color: Colors.white38, fontSize: 12.5, height: 1.5),
          )
        else
          for (var i = 0; i < _academy.length; i++) ...[
            _academyRow(_academy[i]),
            if (i != _academy.length - 1)
              const Divider(color: Colors.white10, height: 22),
          ],
      ]),
    );
  }

  Widget _academyRow(Map<String, dynamic> a) {
    final start = a['startYear'];
    final end = a['endYear'];
    final years = start == null
        ? null
        : '$start – ${end ?? 'Present'}';
    final initials = (a['academy'] as String? ?? '?')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return GestureDetector(
      onTap: () => _showAcademySheet(existing: a),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.12),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.35)),
          ),
          child: Center(
            child: Text(initials,
                style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['academy'] as String? ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            if (years != null)
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: Colors.white38),
                const SizedBox(width: 5),
                Text(years,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11.5)),
              ]),
            if ((a['role'] as String?)?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  const Icon(Icons.sports_outlined,
                      size: 11, color: Colors.white38),
                  const SizedBox(width: 5),
                  Text(a['role'] as String,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11.5)),
                ]),
              ),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.primaryLight, size: 18),
      ]),
    );
  }

  // ── Recommendations (real coach recommendations) ──
  Widget _recommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.star_rounded, color: AppColors.primaryLight, size: 20),
          SizedBox(width: 8),
          Text('Recommendations',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        if (_recs.isEmpty)
          const Text(
            'No recommendations yet.\nCoaches who spot your talent can recommend you to clubs & leagues.',
            style: TextStyle(
                color: Colors.white38, fontSize: 12.5, height: 1.5),
          )
        else
          for (var i = 0; i < _recs.length; i++) ...[
            _recRow(_recs[i]),
            if (i != _recs.length - 1) const SizedBox(height: 12),
          ],
      ]),
    );
  }

  Widget _recRow(Map<String, dynamic> r) {
    final coach = r['coachName'] as String? ?? 'Coach';
    final initials = coach
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.2),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coach,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700)),
                  if ((r['coachTitle'] as String?)?.isNotEmpty == true)
                    Text(r['coachTitle'] as String,
                        style: const TextStyle(
                            color: AppColors.primaryLight, fontSize: 11)),
                ]),
          ),
          const Icon(Icons.star_border_rounded,
              color: AppColors.primaryLight, size: 20),
        ]),
        if ((r['text'] as String?)?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('❝ ',
                  style: TextStyle(
                      color: AppColors.primaryLight, fontSize: 12)),
              Expanded(
                child: Text(r['text'] as String,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5)),
              ),
            ]),
          ),
      ]),
    );
  }

  // ── Bottom actions ──
  Widget _actionsRow() {
    Widget action(IconData icon, String label, VoidCallback onTap) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 5),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        action(Icons.edit_outlined, 'Edit Profile', _showEditProfile),
        Container(width: 1, height: 30, color: Colors.white10),
        action(Icons.share_outlined, 'Share Profile', _shareProfile),
      ]),
    );
  }

  void _shareProfile() {
    final me = _me ?? const {};
    final code = me['playerId'] as String? ?? '';
    final name = me['fullName'] as String? ?? 'A player';
    Share.share(
        '$name is on SportyQo! 🏏\nPlayer ID: $code\nDownload SportyQo to follow their journey.');
  }

  Future<void> _changePhoto() async {
    final url = await pickAndUploadAvatar(context, ImageSource.gallery,
        accent: AppColors.primary);
    if (url != null && mounted) {
      setState(() => _me = {...?_me, 'avatarUrl': url});
    }
  }

  // ── Settings sheet (Edit Profile / Logout preserved) ──
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14142B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined,
                color: AppColors.primaryLight),
            title: const Text('Edit Profile',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _showEditProfile();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.share_outlined, color: Colors.white70),
            title: const Text('Share Profile',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _shareProfile();
            },
          ),
          const Divider(color: Colors.white10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout',
                style: TextStyle(color: Colors.redAccent, fontSize: 15)),
            onTap: () {
              Navigator.pop(sheetCtx);
              _confirmLogout();
            },
          ),
        ]),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F2A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AuthService.logout();
              Future.microtask(() {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ChooseRoleScreen()),
                  (route) => false,
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Edit Profile sheet → PATCH /me/profile ──
  void _showEditProfile() {
    final me = _me ?? const {};
    final nameCtrl =
        TextEditingController(text: me['fullName'] as String? ?? '');
    final locationCtrl =
        TextEditingController(text: me['location'] as String? ?? '');
    final schoolCtrl =
        TextEditingController(text: me['schoolAcademy'] as String? ?? '');
    final clubCtrl = TextEditingController(text: me['club'] as String? ?? '');
    final bioCtrl = TextEditingController(text: me['bio'] as String? ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14142B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(sheetCtx).viewInsets.bottom),
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
              const SizedBox(height: 16),
              _field('Full Name', nameCtrl),
              _field('Location (e.g. Mumbai, India)', locationCtrl),
              _field('School / Academy', schoolCtrl),
              _field('Club', clubCtrl),
              _field('Bio', bioCtrl, maxLines: 3),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.length < 2) {
                      AppToast.error(sheetCtx, 'Please enter your full name');
                      return;
                    }
                    Navigator.pop(sheetCtx);
                    try {
                      await ApiClient.instance.patch('/me/profile', body: {
                        'fullName': name,
                        'location': locationCtrl.text.trim(),
                        'schoolAcademy': schoolCtrl.text.trim(),
                        'club': clubCtrl.text.trim(),
                        'bio': bioCtrl.text.trim(),
                      });
                      await _load();
                      if (!mounted) return;
                      AppToast.success(this.context, 'Profile updated! ✅');
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Academy add/edit sheet → /me/academy ──
  void _showAcademySheet({Map<String, dynamic>? existing}) {
    final academyCtrl =
        TextEditingController(text: existing?['academy'] as String? ?? '');
    final roleCtrl =
        TextEditingController(text: existing?['role'] as String? ?? '');
    final startCtrl = TextEditingController(
        text: existing?['startYear']?.toString() ?? '');
    final endCtrl =
        TextEditingController(text: existing?['endYear']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14142B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add Academy' : 'Edit Academy',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _field('Academy name', academyCtrl),
              _field('Role (e.g. Batter) — optional', roleCtrl),
              Row(children: [
                Expanded(
                    child: _field('Start year', startCtrl,
                        keyboard: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(
                    child: _field('End year (blank = Present)', endCtrl,
                        keyboard: TextInputType.number)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                if (existing != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        try {
                          await SportyQoApi
                              .deleteAcademy(existing['id'] as String);
                          await _load();
                          if (!mounted) return;
                          AppToast.success(this.context, 'Removed');
                        } on ApiException catch (e) {
                          if (!mounted) return;
                          AppToast.error(this.context, e.message);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                if (existing != null) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      final academy = academyCtrl.text.trim();
                      if (academy.length < 2) {
                        AppToast.error(
                            sheetCtx, 'Please enter the academy name');
                        return;
                      }
                      final start = int.tryParse(startCtrl.text.trim());
                      final end = int.tryParse(endCtrl.text.trim());
                      Navigator.pop(sheetCtx);
                      try {
                        if (existing == null) {
                          await SportyQoApi.addAcademy(
                              academy: academy,
                              role: roleCtrl.text.trim(),
                              startYear: start,
                              endYear: end);
                        } else {
                          await SportyQoApi.updateAcademy(
                              existing['id'] as String,
                              academy: academy,
                              role: roleCtrl.text.trim(),
                              startYear: start,
                              endYear: end);
                        }
                        await _load();
                        if (!mounted) return;
                        AppToast.success(this.context, 'Saved ✅');
                      } on ApiException catch (e) {
                        if (!mounted) return;
                        AppToast.error(this.context, e.message);
                      } catch (_) {
                        if (!mounted) return;
                        AppToast.error(this.context, 'Could not save');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
          {int maxLines = 1, TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1B1B38),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ]),
      );
}
