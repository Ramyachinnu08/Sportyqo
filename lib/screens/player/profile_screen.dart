import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../auth/choose_role_screen.dart';
import '../../services/sportyqo_api.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../shared/chat_screens.dart';
import '../shared/avatar_picker.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String? playerId;

  const ProfileScreen({super.key, this.playerId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _academyHistory = [];
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.playerProfile();
      if (!mounted) return;
      setState(() {
        _profile = data;
        _academyHistory = (data['academyHistory'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        _recommendations = (data['recommendations'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        final settings = data['settings'] as Map<String, dynamic>?;
        _notificationsOn = settings?['notifications'] != false;
      });
    } catch (_) {
      // keep placeholders when offline
    }
  }

  String _initials(String name) {
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Profile Info ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(children: [
                          AvatarCircle(
                            avatarUrl: _profile?['avatarUrl'] as String?,
                            name: _profile?['fullName'] as String? ?? '',
                            size: 80,
                            borderColor: AppColors.primary,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showPhotoOptions(context),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F0F2A),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24, width: 1.5),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white60, size: 14),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(_profile?['fullName'] as String? ?? '—',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 6),
                                if (_profile?['isVerified'] == true)
                                  const Icon(Icons.verified, color: AppColors.primary, size: 16),
                              ]),
                              if (_profile?['playerId'] != null ||
                                  widget.playerId != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _profile?['playerId'] as String? ??
                                      widget.playerId!,
                                  style: const TextStyle(
                                    color: Color(0xFF00C853),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(children: [
                                Text(
                                    (_profile?['sport']
                                            as Map<String, dynamic>?)?['name']
                                            as String? ??
                                        'Sport',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 13)),
                                if ((_profile?['club'] as String?)
                                        ?.isNotEmpty ==
                                    true) ...[
                                  const Text(' • ',
                                      style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 13)),
                                  Text(_profile!['club'] as String,
                                      style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13)),
                                ],
                              ]),
                              const SizedBox(height: 8),
                              if ((_profile?['location'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Row(children: [
                                  const Icon(Icons.location_on_outlined,
                                      color: Colors.white38, size: 13),
                                  const SizedBox(width: 4),
                                  Text(_profile!['location'] as String,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12)),
                                ]),
                              const SizedBox(height: 3),
                              if ((_profile?['schoolAcademy'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Row(children: [
                                  const Icon(Icons.school_outlined,
                                      color: Colors.white38, size: 13),
                                  const SizedBox(width: 4),
                                  Text(_profile!['schoolAcademy'] as String,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12)),
                                ]),
                              const SizedBox(height: 3),
                              if ((_profile?['club'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Row(children: [
                                  const Icon(Icons.shield_outlined,
                                      color: Colors.white38, size: 13),
                                  const SizedBox(width: 4),
                                  Text(_profile!['club'] as String,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12)),
                                ]),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showSettings(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Academy Experience ──
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
                            const Icon(Icons.school,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            const Text('Academy Experience',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showAcademyForm(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          AppColors.primary.withOpacity(0.4)),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add,
                                          color: AppColors.primary, size: 14),
                                      SizedBox(width: 2),
                                      Text('Add',
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ]),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 14),
                          if (_academyHistory.isEmpty)
                            const Text(
                                'No academy history yet — tap "Add" to add your first entry',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13))
                          else
                            ...List.generate(_academyHistory.length, (i) {
                              final a = _academyHistory[i];
                              final startYear = a['startYear']?.toString() ?? '';
                              final endYear =
                                  a['endYear']?.toString() ?? 'Present';
                              return Column(children: [
                                if (i > 0)
                                  const Divider(
                                      color: Colors.white10, height: 20),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      _showAcademyForm(context, entry: a),
                                  child: _AcademyTile(
                                    logo: _initials(
                                        a['academy'] as String? ?? '?'),
                                    logoColor: const Color(0xFF1A3A5C),
                                    name: a['academy'] as String? ?? '',
                                    year: startYear.isEmpty && a['endYear'] == null
                                        ? '—'
                                        : '$startYear – $endYear',
                                    location: a['role'] as String? ?? '',
                                    isText: true,
                                  ),
                                ),
                              ]);
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Recommendations ──
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
                          Row(children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text('Recommendations',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          ]),
                          const SizedBox(height: 14),
                          if (_recommendations.isEmpty)
                            const Text('No recommendations yet',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 13))
                          else
                            ...List.generate(_recommendations.length, (i) {
                              final r = _recommendations[i];
                              final coach =
                                  r['coachName'] as String? ?? 'Coach';
                              return Column(children: [
                                if (i > 0)
                                  const Divider(
                                      color: Colors.white10, height: 20),
                                _RecommendationTile(
                                  initials: _initials(coach),
                                  color: const Color(0xFF7B2FFF),
                                  name: coach,
                                  role: r['coachTitle'] as String? ?? 'Coach',
                                  quote: r['text'] as String? ?? '',
                                ),
                              ]);
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Action Bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F2A),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showEditProfile(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit_outlined,
                                  color: AppColors.primary, size: 22),
                              SizedBox(height: 4),
                              Text('Edit Profile',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 36, width: 1, color: Colors.white10),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChatListScreen()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.chat_bubble_outline, color: Colors.white60, size: 22),
                              SizedBox(height: 4),
                              Text('Message',
                                  style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 36, width: 1, color: Colors.white10),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Share.share(
                            'Check out ${_profile?['fullName'] ?? 'my'} profile on SportyQo! ${_profile?['playerId'] ?? ''}',
                            subject: '${_profile?['fullName'] ?? 'Player'} - SportyQo Profile',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.share_outlined, color: Colors.white60, size: 22),
                              SizedBox(height: 4),
                              Text('Share Profile',
                                  style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Add or edit an academy-experience entry. Pass [entry] to edit.
  void _showAcademyForm(BuildContext context, {Map<String, dynamic>? entry}) {
    final academyCtrl =
        TextEditingController(text: entry?['academy'] as String? ?? '');
    final roleCtrl =
        TextEditingController(text: entry?['role'] as String? ?? '');
    final startCtrl =
        TextEditingController(text: entry?['startYear']?.toString() ?? '');
    final endCtrl =
        TextEditingController(text: entry?['endYear']?.toString() ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0F2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                      entry == null
                          ? 'Add Academy Experience'
                          : 'Edit Academy Experience',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  if (entry != null)
                    GestureDetector(
                      onTap: saving
                          ? null
                          : () async {
                              setModalState(() => saving = true);
                              try {
                                await SportyQoApi.deleteAcademy(
                                    entry['id'] as String);
                                if (!sheetContext.mounted) return;
                                Navigator.pop(sheetContext);
                                _load();
                              } on ApiException catch (e) {
                                setModalState(() => saving = false);
                                if (!sheetContext.mounted) return;
                                ScaffoldMessenger.of(sheetContext)
                                    .showSnackBar(SnackBar(
                                  content: Text(e.message),
                                  backgroundColor: Colors.redAccent,
                                ));
                              }
                            },
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 22),
                    ),
                ]),
                const SizedBox(height: 18),
                _formField('Academy / Club name *', academyCtrl,
                    hint: 'e.g. Falcons Cricket Academy'),
                const SizedBox(height: 12),
                _formField('Role', roleCtrl, hint: 'e.g. Top-order Batsman'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _formField('Start year', startCtrl,
                          hint: 'e.g. 2022', number: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _formField('End year', endCtrl,
                          hint: 'Leave empty if current', number: true)),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final academy = academyCtrl.text.trim();
                            if (academy.length < 2) {
                              ScaffoldMessenger.of(sheetContext)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Enter the academy or club name'),
                                backgroundColor: Colors.redAccent,
                              ));
                              return;
                            }
                            final start =
                                int.tryParse(startCtrl.text.trim());
                            final end = int.tryParse(endCtrl.text.trim());
                            setModalState(() => saving = true);
                            try {
                              if (entry == null) {
                                await SportyQoApi.addAcademy(
                                  academy: academy,
                                  role: roleCtrl.text.trim(),
                                  startYear: start,
                                  endYear: end,
                                );
                              } else {
                                await SportyQoApi.updateAcademy(
                                  entry['id'] as String,
                                  academy: academy,
                                  role: roleCtrl.text.trim(),
                                  startYear: start,
                                  endYear: end,
                                );
                              }
                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                              _load();
                            } on ApiException catch (e) {
                              setModalState(() => saving = false);
                              if (!sheetContext.mounted) return;
                              ScaffoldMessenger.of(sheetContext)
                                  .showSnackBar(SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.redAccent,
                              ));
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(entry == null ? 'Add' : 'Save changes',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Edit the basic profile fields via PATCH /me/profile.
  void _showEditProfile(BuildContext context) {
    final locationCtrl =
        TextEditingController(text: _profile?['location'] as String? ?? '');
    final schoolCtrl = TextEditingController(
        text: _profile?['schoolAcademy'] as String? ?? '');
    final clubCtrl =
        TextEditingController(text: _profile?['club'] as String? ?? '');
    final bioCtrl =
        TextEditingController(text: _profile?['bio'] as String? ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0F2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _formField('Location', locationCtrl,
                    hint: 'e.g. Bangalore, Karnataka'),
                const SizedBox(height: 12),
                _formField('School / Academy', schoolCtrl,
                    hint: 'e.g. Falcons Cricket Academy'),
                const SizedBox(height: 12),
                _formField('Club', clubCtrl, hint: 'e.g. Falcons FC'),
                const SizedBox(height: 12),
                _formField('Bio', bioCtrl,
                    hint: 'Tell people about your game', maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setModalState(() => saving = true);
                            try {
                              await SportyQoApi.updateProfile({
                                'location': locationCtrl.text.trim(),
                                'schoolAcademy': schoolCtrl.text.trim(),
                                'club': clubCtrl.text.trim(),
                                'bio': bioCtrl.text.trim(),
                              });
                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                              _load();
                            } on ApiException catch (e) {
                              setModalState(() => saving = false);
                              if (!sheetContext.mounted) return;
                              ScaffoldMessenger.of(sheetContext)
                                  .showSnackBar(SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.redAccent,
                              ));
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save changes',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {String? hint, bool number = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Profile Photo',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final url = await pickAndUploadAvatar(
                    context, ImageSource.camera,
                    accent: AppColors.primary);
                if (url != null && mounted) _load();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final url = await pickAndUploadAvatar(
                    context, ImageSource.gallery,
                    accent: AppColors.primary);
                if (url != null && mounted) _load();
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: _notificationsOn,
                  onChanged: (val) {
                    setModalState(() => _notificationsOn = val);
                    setState(() => _notificationsOn = val);
                    final settings = Map<String, dynamic>.from(
                        _profile?['settings'] as Map<String, dynamic>? ??
                            <String, dynamic>{});
                    settings['notifications'] = val;
                    SportyQoApi.updateProfile({'settings': settings})
                        .then((updated) {
                      if (mounted) setState(() => _profile = {..._profile ?? {}, 'settings': updated['settings']});
                    }).catchError((_) {
                      if (!mounted) return;
                      setState(() => _notificationsOn = !val);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Could not save the notification setting. Check your connection.'),
                        backgroundColor: Colors.redAccent,
                      ));
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _showLogout(context);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Academy Tile ──────────────────────────────────────────────────────

class _AcademyTile extends StatelessWidget {
  final String logo, name, year, location;
  final Color logoColor;
  final bool isText;

  const _AcademyTile({
    required this.logo,
    required this.name,
    required this.year,
    required this.location,
    required this.logoColor,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: logoColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isText
              ? Text(logo,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))
              : Text(logo, style: const TextStyle(fontSize: 22)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 11),
              const SizedBox(width: 4),
              Text(year, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: Colors.white38, size: 11),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ],
        ),
      ),
      const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
    ]);
  }
}

// ── Recommendation Tile ───────────────────────────────────────────────

class _RecommendationTile extends StatefulWidget {
  final String initials, name, role, quote;
  final Color color;

  const _RecommendationTile({
    required this.initials,
    required this.name,
    required this.role,
    required this.quote,
    required this.color,
  });

  @override
  State<_RecommendationTile> createState() => _RecommendationTileState();
}

class _RecommendationTileState extends State<_RecommendationTile> {
  bool _starred = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(widget.initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                Text(widget.role,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _starred = !_starred),
            child: Icon(
              _starred ? Icons.star : Icons.star_border,
              color: _starred ? Colors.amber : AppColors.primary,
              size: 20,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(widget.quote,
                  style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
            ),
          ],
        ),
      ],
    );
  }
}