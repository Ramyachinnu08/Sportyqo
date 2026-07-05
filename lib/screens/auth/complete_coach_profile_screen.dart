import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../coach/select_coach_sport_screen.dart';
import '../shared/app_toast.dart';

class CompleteCoachProfileScreen extends StatefulWidget {
  const CompleteCoachProfileScreen({super.key});

  @override
  State<CompleteCoachProfileScreen> createState() =>
      _CompleteCoachProfileScreenState();
}

class _CompleteCoachProfileScreenState
    extends State<CompleteCoachProfileScreen> {
  String _experience = '8+ Years';
  String _level = 'A License';
  String? _photoPath; // picked locally; uploaded right after registration

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _photoPath = picked.path);
        RegistrationDraft.instance.avatarPath = picked.path;
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Could not pick an image on this device.');
    }
  }

  void _showPhotoOptions() {
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
            const Text(
              'Update Profile Photo',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFF00C853)),
              title: const Text('Take Photo',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
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
                _pickPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios,
                    color:
                    isDark ? AppColors.textWhite : AppColors.textDark),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color:
                    isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Add your details',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textGrey)),
              ),
              const SizedBox(height: 28),

              // ── Profile Photo ──
              Center(
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF00C853), width: 3),
                          color: AppColors.darkCard,
                        ),
                        child: _photoPath == null
                            ? const Icon(Icons.person,
                                size: 44, color: AppColors.textGrey)
                            : ClipOval(
                                child: Image.file(
                                  File(_photoPath!),
                                  width: 90,
                                  height: 90,
                                  cacheWidth: 220, // decode small on low-RAM devices
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 44,
                                      color: AppColors.textGrey),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkBg
                                    : Colors.white,
                                width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Name, email and phone were already collected on the previous
              // screen — only coach-specific details are asked here.
              _buildDropdown(
                label: 'Experience',
                value: _experience,
                items: ['1-3 Years', '3-5 Years', '5-8 Years', '8+ Years'],
                isDark: isDark,
                onChanged: (v) => setState(() => _experience = v!),
              ),
              const SizedBox(height: 14),
              _buildDropdown(
                label: 'Coaching Level',
                value: _level,
                items: [
                  'Grassroots',
                  'C License',
                  'B License',
                  'A License',
                  'Pro License'
                ],
                isDark: isDark,
                onChanged: (v) => setState(() => _level = v!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final draft = RegistrationDraft.instance;
                    draft.yearsExperience = switch (_experience) {
                      '1-3 Years' => 2,
                      '3-5 Years' => 4,
                      '5-8 Years' => 6,
                      _ => 8,
                    };
                    draft.coachTitle = '$_level Coach';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const SelectCoachSportScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save & Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          style: TextStyle(
              color: isDark ? AppColors.textWhite : AppColors.textDark,
              fontFamily: 'Poppins'),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}