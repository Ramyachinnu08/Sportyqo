import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'select_sport_screen.dart';
import '../../services/auth_service.dart';

class CreateProfileScreen extends StatefulWidget {
  final bool isPlayer;
  const CreateProfileScreen(
      {super.key, required this.isPlayer});

  @override
  State<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState
    extends State<CreateProfileScreen> {
  String _selectedGender = 'Male';
  bool _hasPhoto = false;
  final TextEditingController _locationCtrl = TextEditingController(
      text: RegistrationDraft.instance.location ?? '');

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius:
                BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Upload Photo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'Choose how to upload your profile photo',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13)),
            const SizedBox(height: 24),

            // Camera option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() => _hasPhoto = true);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content:
                  Text('Camera opened! 📷'),
                  backgroundColor:
                  AppColors.primary,
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.15),
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary
                          .withOpacity(0.5)),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withOpacity(0.2),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                        size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text('Take Photo',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 16)),
                        Text('Use your camera',
                            style: TextStyle(
                                color:
                                Colors.white54,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 16),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // Gallery option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() => _hasPhoto = true);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content:
                  Text('Gallery opened! 🖼️'),
                  backgroundColor:
                  AppColors.primary,
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853)
                      .withOpacity(0.15),
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF00C853)
                          .withOpacity(0.5)),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853)
                          .withOpacity(0.2),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Icon(
                        Icons.photo_library,
                        color: Color(0xFF00C853),
                        size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text('Choose from Gallery',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 16)),
                        Text(
                            'Pick from your photos',
                            style: TextStyle(
                                color:
                                Colors.white54,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF00C853),
                      size: 16),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14)),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios,
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textDark),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Your Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textWhite
                      : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Help us know more about you',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),

              // ── Profile Photo ──
              Center(
                child: GestureDetector(
                  onTap: () =>
                      _showPhotoOptions(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary,
                              width: 3),
                          color: _hasPhoto
                              ? AppColors.primary
                              .withOpacity(0.3)
                              : AppColors.darkCard,
                        ),
                        child: _hasPhoto
                            ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors
                                .primary)
                            : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors
                                .textGrey),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () =>
                              _showPhotoOptions(
                                  context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isDark
                                      ? AppColors
                                      .darkBg
                                      : Colors.white,
                                  width: 2),
                            ),
                            child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_hasPhoto) ...[
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                      '✅ Photo selected!',
                      style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600)),
                ),
              ],

              const SizedBox(height: 28),

              // ── Date of Birth ──
              Text('Date of Birth',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      fontWeight:
                      FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey[300]!),
                ),
                child: ListTile(
                  leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textGrey,
                      size: 20),
                  title: Text('15 / 08 / 2005',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textDark)),
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime(2005, 8, 15),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ── Gender ──
              Text('Gender',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      fontWeight:
                      FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 16),
                    dropdownColor: isDark
                        ? AppColors.darkCard
                        : Colors.white,
                    style: TextStyle(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textDark,
                        fontFamily: 'Poppins'),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(
                            () => _selectedGender = v!),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Location ──
              Text('Location',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      fontWeight:
                      FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationCtrl,
                style: TextStyle(
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'City, State (e.g. Bangalore, Karnataka)',
                  prefixIcon: Icon(Icons.location_on_outlined,
                      color: AppColors.textGrey, size: 20),
                ),
              ),

              const SizedBox(height: 32),

              // ── Next Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final draft =
                        RegistrationDraft.instance;
                    draft.location =
                        _locationCtrl.text.trim().isEmpty
                            ? null
                            : _locationCtrl.text.trim();
                    draft.gender = {
                      'Male': 'MALE',
                      'Female': 'FEMALE',
                      'Other': 'OTHER',
                    }[_selectedGender];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const SelectSportScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                    const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            14)),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: const [
                      Text('Next',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward,
                          size: 18),
                    ],
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