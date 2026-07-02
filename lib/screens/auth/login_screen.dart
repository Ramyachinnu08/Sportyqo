import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../player/home_screen.dart';
import '../coach/coach_home_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isPlayer = true;
  bool _loading = false;
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter your email/phone and password'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      final role = await AuthService.login(identifier, password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => role == 'COACH'
                ? const CoachHomeScreen()
                : const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
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
                child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white),
              ),
              const SizedBox(height: 32),

              // Title
              Center(
                child: Column(children: [
                  const Text('Welcome Back!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text(
                      'Login to your account',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54)),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Player / Coach Toggle ──
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white10),
                ),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                              () => _isPlayer = true),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 12),
                        decoration: BoxDecoration(
                          color: _isPlayer
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius:
                          BorderRadius.circular(
                              10),
                        ),
                        child: Center(
                          child: Text('Player',
                              style: TextStyle(
                                  color: _isPlayer
                                      ? Colors.white
                                      : Colors.white38,
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(
                              () => _isPlayer = false),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isPlayer
                              ? const Color(0xFF00C853)
                              : Colors.transparent,
                          borderRadius:
                          BorderRadius.circular(
                              10),
                        ),
                        child: Center(
                          child: Text('Coach',
                              style: TextStyle(
                                  color: !_isPlayer
                                      ? Colors.white
                                      : Colors.white38,
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Email Field ──
              const Text('Email / Phone Number',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _identifierCtrl,
                keyboardType:
                TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                  'Email or phone number',
                  hintStyle: const TextStyle(
                      color: Colors.white24),
                  filled: true,
                  fillColor:
                  const Color(0xFF0F0F2A),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.white10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _isPlayer
                            ? AppColors.primary
                            : const Color(
                            0xFF00C853)),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // ── Password Field ──
              const Text('Password',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(
                    color: Colors.white),
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  hintStyle: const TextStyle(
                      color: Colors.white24),
                  filled: true,
                  fillColor:
                  const Color(0xFF0F0F2A),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.white10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _isPlayer
                            ? AppColors.primary
                            : const Color(
                            0xFF00C853)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons
                          .visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                    ),
                    onPressed: () => setState(() =>
                    _obscurePassword =
                    !_obscurePassword),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16),
                ),
              ),

              const SizedBox(height: 10),

              // ── Forgot Password ──
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () =>
                      _showForgotPassword(context),
                  child: Text('Forgot Password?',
                      style: TextStyle(
                          color: _isPlayer
                              ? AppColors.primary
                              : const Color(
                              0xFF00C853),
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 24),

              // ── Login Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlayer
                        ? AppColors.primary
                        : const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white))
                      : const Text('Login',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 24),

              // ── OR Divider ──
              Row(children: [
                Expanded(
                    child: Divider(
                        color: Colors.white10)),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12),
                  child: Text('or continue with',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13)),
                ),
                Expanded(
                    child: Divider(
                        color: Colors.white10)),
              ]),

              const SizedBox(height: 24),

              // ── Social Buttons ──
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  _SocialBtn(
                    icon: Icons.g_mobiledata,
                    color: const Color(0xFFDB4437),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const HomeScreen()),
                            (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _SocialBtn(
                    icon: Icons.apple,
                    color: Colors.white,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const HomeScreen()),
                            (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _SocialBtn(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const HomeScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Sign Up Link ──
              Center(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                          text:
                          "Don't have an account? ",
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14)),
                      TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w600)),
                    ]),
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

  void _showForgotPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom +
                24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text('Forgot Password',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
                'Enter your email to reset your password',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(
                  color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(
                    color: Colors.white24),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                    content:
                    Text('Reset link sent! 📧'),
                    backgroundColor:
                    AppColors.primary,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                  const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                ),
                child: const Text(
                    'Send Reset Link',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F2A),
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: Colors.white10),
        ),
        child:
        Icon(icon, color: color, size: 30),
      ),
    );
  }
}