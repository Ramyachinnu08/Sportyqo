import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../auth/choose_role_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? playerId;

  const ProfileScreen({super.key, this.playerId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  bool _darkMode = true;
  bool _notificationsOn = true;

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
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                              color: const Color(0xFF1A1A3A),
                            ),
                            child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
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
                                const Text('Aarav Mehta',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppColors.primary, size: 16),
                              ]),
                              if (widget.playerId != null) ...[
                                const SizedBox(height: 3),
                                Text(
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
                              Row(children: const [
                                Text('Cricket',
                                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                                Text(' • ', style: TextStyle(color: Colors.white38, fontSize: 13)),
                                Text('Batter',
                                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                              ]),
                              const SizedBox(height: 8),
                              Row(children: const [
                                Icon(Icons.location_on_outlined, color: Colors.white38, size: 13),
                                SizedBox(width: 4),
                                Text('Mumbai, India',
                                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ]),
                              const SizedBox(height: 3),
                              Row(children: const [
                                Icon(Icons.school_outlined, color: Colors.white38, size: 13),
                                SizedBox(width: 4),
                                Text('St. Xavier\'s School',
                                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ]),
                              const SizedBox(height: 3),
                              Row(children: const [
                                Icon(Icons.shield_outlined, color: Colors.white38, size: 13),
                                SizedBox(width: 4),
                                Text('Falcons Cricket Club',
                                    style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                          Row(children: const [
                            Icon(Icons.school, color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text('Academy Experience',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          ]),
                          const SizedBox(height: 14),
                          _AcademyTile(
                            logo: '🦅',
                            logoColor: const Color(0xFF1A3A5C),
                            name: 'Falcons Cricket Academy',
                            year: '2023 – Present',
                            location: 'Mumbai, India',
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _AcademyTile(
                            logo: '🏏',
                            logoColor: const Color(0xFF1A2A4A),
                            name: 'Mumbai Colts Academy',
                            year: '2020 – 2023',
                            location: 'Mumbai, India',
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _AcademyTile(
                            logo: 'U16',
                            logoColor: const Color(0xFF2A1A4A),
                            name: 'Under16 Pro League',
                            year: '2024 – Present',
                            location: 'Mumbai, India',
                            isText: true,
                          ),
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
                          _RecommendationTile(
                            initials: 'RS',
                            color: const Color(0xFF7B2FFF),
                            name: 'Rahul Sharma',
                            role: 'Head Coach • Falcons Cricket Academy',
                            quote:
                            'Aarav is one of the most disciplined players I\'ve worked with. Strong work ethic and excellent game awareness.',
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _RecommendationTile(
                            initials: 'VN',
                            color: const Color(0xFF1A5C3A),
                            name: 'Vivek Nair',
                            role: 'Performance Coach',
                            quote:
                            'A technically gifted batter with leadership qualities and a hunger to improve.',
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _RecommendationTile(
                            initials: 'JM',
                            color: const Color(0xFF3A2A1A),
                            name: 'John Matthews',
                            role: 'Former Coach',
                            quote: 'A Consistent performer and a great teammate.',
                          ),
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
                        onTap: () {
                          setState(() => _isFollowing = !_isFollowing);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isFollowing
                                  ? 'You are now following Aarav Mehta'
                                  : 'You unfollowed Aarav Mehta'),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isFollowing
                                    ? Icons.person_remove_outlined
                                    : Icons.person_add_outlined,
                                color: _isFollowing ? Colors.white60 : AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: TextStyle(
                                    color: _isFollowing ? Colors.white60 : AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening chat with Aarav Mehta...'),
                              backgroundColor: AppColors.primary,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
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
                            'Check out Aarav Mehta\'s profile on SportyQo! 🏏\nhttps://sportyqo.app/profile/aarav-mehta',
                            subject: 'Aarav Mehta - SportyQo Profile',
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
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera opened! 📷'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery opened! 🖼️'),
                    backgroundColor: AppColors.primary,
                  ),
                );
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
                leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (val) {
                    setModalState(() => _darkMode = val);
                    setState(() => _darkMode = val);
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: _notificationsOn,
                  onChanged: (val) {
                    setModalState(() => _notificationsOn = val);
                    setState(() => _notificationsOn = val);
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