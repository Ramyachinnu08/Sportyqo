import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'create_account_screen.dart';
import 'create_coach_account_screen.dart';
import 'login_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  const ChooseRoleScreen({super.key});

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

              // ── Back Button ──
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 18),
                ),
              ),

              const SizedBox(height: 20),

              // ── Logo ──
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sporty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textDark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const TextSpan(
                      text: 'Qo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Title ──
              Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textWhite
                      : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you want to continue',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),

              // ── Player Card ──
              _RoleCard(
                title: 'I am a',
                role: 'Player',
                description:
                'Join, compete and\nimprove your game.',
                gradientColors: [
                  const Color(0xFF2D1B69),
                  const Color(0xFF7B2FFF),
                ],
                imageUrl:
                'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400',
                arrowColor: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const CreateAccountScreen(
                          isPlayer: true),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── Coach Card ──
              _RoleCard(
                title: 'I am a',
                role: 'Coach',
                description:
                'Manage teams and\ndevelop athletes.',
                gradientColors: [
                  const Color(0xFF1A2E1A),
                  const Color(0xFF2E5C2E),
                ],
                imageUrl:
                'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=400',
                arrowColor: const Color(0xFF00C853),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const CreateCoachAccountScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // ── Login Link ──
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const LoginScreen())),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text:
                          'Already have an account? ',
                          style: TextStyle(
                              color:
                              AppColors.textGrey,
                              fontSize: 14),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w600,
                          ),
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
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String role;
  final String description;
  final List<Color> gradientColors;
  final String imageUrl;
  final Color arrowColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.role,
    required this.description,
    required this.gradientColors,
    required this.imageUrl,
    required this.arrowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image on right side
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 160,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const SizedBox(),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      gradientColors[0],
                      gradientColors[0]
                          .withOpacity(0.9),
                      gradientColors[1]
                          .withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [
                      0.0,
                      0.4,
                      0.7,
                      1.0
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: arrowColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}