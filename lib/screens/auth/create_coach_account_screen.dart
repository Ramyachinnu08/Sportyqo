import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import 'enter_mobile_screen.dart';

class CreateCoachAccountScreen extends StatefulWidget {
  const CreateCoachAccountScreen({super.key});

  @override
  State<CreateCoachAccountScreen> createState() =>
      _CreateCoachAccountScreenState();
}

class _CreateCoachAccountScreenState extends State<CreateCoachAccountScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                    color: isDark ? AppColors.textWhite : AppColors.textDark),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Create Coach Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  "Let's get you started",
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                hint: 'Full Name',
                icon: Icons.person_outline,
                isDark: isDark,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
                controller: _emailCtrl,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                hint: 'Phone Number',
                icon: Icons.phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
                controller: _phoneCtrl,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                hint: 'Password',
                icon: Icons.lock_outline,
                isDark: isDark,
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textGrey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (v) =>
                        setState(() => _agreeToTerms = v ?? false),
                    activeColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                                color: AppColors.textGrey, fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                                color: Color(0xFF00C853), fontSize: 13),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(
                                color: AppColors.textGrey, fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                                color: Color(0xFF00C853), fontSize: 13),
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
                    final name = _nameCtrl.text.trim();
                    final email = _emailCtrl.text.trim();
                    final phone = _phoneCtrl.text.trim();
                    final password = _passwordCtrl.text;
                    String? error;
                    if (name.length < 2) {
                      error = 'Please enter your full name';
                    } else if (email.isEmpty && phone.isEmpty) {
                      error = 'Enter an email or phone number';
                    } else if (password.length < 8) {
                      error = 'Password must be at least 8 characters';
                    }
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error),
                        backgroundColor: Colors.redAccent,
                      ));
                      return;
                    }
                    final draft = RegistrationDraft.instance;
                    draft.fullName = name;
                    draft.email = email;
                    draft.phone = phone;
                    draft.password = password;
                    draft.isPlayer = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EnterMobileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: TextStyle(
                            color: AppColors.textGrey, fontSize: 13)),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                      icon: Icons.g_mobiledata,
                      color: const Color(0xFFDB4437),
                      onTap: () {}),
                  const SizedBox(width: 16),
                  _SocialButton(
                      icon: Icons.apple,
                      color: isDark ? Colors.white : Colors.black,
                      onTap: () {}),
                  const SizedBox(width: 16),
                  _SocialButton(
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      onTap: () {}),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style:
                        TextStyle(color: AppColors.textGrey, fontSize: 14),
                      ),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
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

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
          color: isDark ? AppColors.textWhite : AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey[300]!),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}