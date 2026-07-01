import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'create_profile_screen.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final bool isPlayer;
  const CreateAccountScreen(
      {super.key, required this.isPlayer});

  @override
  State<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends State<CreateAccountScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

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
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  "Let's get you started",
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                hint: 'Full Name',
                icon: Icons.person_outline,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                hint: 'Phone Number',
                icon: Icons.phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                isDark: isDark,
                keyboardType:
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              if (!widget.isPlayer) ...[
                _buildTextField(
                  hint: 'Coach Code',
                  icon: Icons.lock_outline,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
              ],
              _buildTextField(
                hint: 'Password',
                icon: Icons.lock_outline,
                isDark: isDark,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textGrey,
                  ),
                  onPressed: () => setState(() =>
                  _obscurePassword =
                  !_obscurePassword),
                ),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                isDark: isDark,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textGrey,
                  ),
                  onPressed: () => setState(() =>
                  _obscureConfirm =
                  !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (v) => setState(
                            () => _agreeToTerms =
                            v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            4)),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                                color:
                                AppColors.textGrey,
                                fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                                color:
                                AppColors.primary,
                                fontSize: 13),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(
                                color:
                                AppColors.textGrey,
                                fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                                color:
                                AppColors.primary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateProfileScreen(
                                isPlayer:
                                widget.isPlayer),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
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
                      Text('Sign Up',
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: isDark
                              ? AppColors.darkBorder
                              : Colors.grey[300])),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 12),
                    child: Text('OR',
                        style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13)),
                  ),
                  Expanded(
                      child: Divider(
                          color: isDark
                              ? AppColors.darkBorder
                              : Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  _SocialButton(
                      icon: Icons.g_mobiledata,
                      color: const Color(0xFFDB4437),
                      onTap: () {}),
                  const SizedBox(width: 16),
                  _SocialButton(
                      icon: Icons.apple,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                      onTap: () {}),
                  const SizedBox(width: 16),
                  _SocialButton(
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      onTap: () {}),
                ],
              ),
              const SizedBox(height: 24),

              // ── Already have an account ──
              Center(
                child: GestureDetector(
                  onTap: () {
                    // ── Show Player/Coach login options ──
                    showModalBottomSheet(
                      context: context,
                      backgroundColor:
                      const Color(0xFF111111),
                      shape:
                      const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(
                              top: Radius
                                  .circular(
                                  24))),
                      builder: (_) => Padding(
                        padding:
                        const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            // Handle bar
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius:
                                BorderRadius
                                    .circular(2),
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text('Log In As',
                                style: TextStyle(
                                    color:
                                    Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight
                                        .w800)),

                            const SizedBox(height: 8),

                            const Text(
                                'Choose your role to continue',
                                style: TextStyle(
                                    color:
                                    Colors.white54,
                                    fontSize: 13)),

                            const SizedBox(height: 24),

                            // ── Player Login ──
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const LoginScreen()));
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                const EdgeInsets
                                    .all(16),
                                decoration:
                                BoxDecoration(
                                  color: const Color(
                                      0xFF7B2FFF)
                                      .withOpacity(
                                      0.15),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      16),
                                  border: Border.all(
                                      color: const Color(
                                          0xFF7B2FFF)
                                          .withOpacity(
                                          0.5)),
                                ),
                                child:
                                Row(children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration:
                                    BoxDecoration(
                                      color: const Color(
                                          0xFF7B2FFF)
                                          .withOpacity(
                                          0.2),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          14),
                                    ),
                                    child: const Icon(
                                        Icons
                                            .sports_cricket,
                                        color: Color(
                                            0xFF7B2FFF),
                                        size: 26),
                                  ),
                                  const SizedBox(
                                      width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: const [
                                        Text(
                                            'Login as Player',
                                            style: TextStyle(
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                FontWeight
                                                    .w700,
                                                fontSize:
                                                16)),
                                        Text(
                                            'Track performance & join leagues',
                                            style: TextStyle(
                                                color: Colors
                                                    .white54,
                                                fontSize:
                                                12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      color: Color(
                                          0xFF7B2FFF),
                                      size: 16),
                                ]),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Coach Login ──
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const LoginScreen()));
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                const EdgeInsets
                                    .all(16),
                                decoration:
                                BoxDecoration(
                                  color: const Color(
                                      0xFF00C853)
                                      .withOpacity(
                                      0.15),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      16),
                                  border: Border.all(
                                      color: const Color(
                                          0xFF00C853)
                                          .withOpacity(
                                          0.5)),
                                ),
                                child:
                                Row(children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration:
                                    BoxDecoration(
                                      color: const Color(
                                          0xFF00C853)
                                          .withOpacity(
                                          0.2),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          14),
                                    ),
                                    child: const Icon(
                                        Icons
                                            .sports_outlined,
                                        color: Color(
                                            0xFF00C853),
                                        size: 26),
                                  ),
                                  const SizedBox(
                                      width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: const [
                                        Text(
                                            'Login as Coach',
                                            style: TextStyle(
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                FontWeight
                                                    .w700,
                                                fontSize:
                                                16)),
                                        Text(
                                            'Manage players & track teams',
                                            style: TextStyle(
                                                color: Colors
                                                    .white54,
                                                fontSize:
                                                12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      color: Color(
                                          0xFF00C853),
                                      size: 16),
                                ]),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text:
                          'Already have an account? ',
                          style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w600),
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

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
          color: isDark
              ? AppColors.textWhite
              : AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
        Icon(icon, color: AppColors.textGrey, size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 16),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.icon,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : Colors.grey[300]!),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}