import 'package:flutter/material.dart';
import 'choose_role_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ──
          Image.network(
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(
                    color: const Color(0xFF0A1A0A)),
          ),

          // ── Dark overlay ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // ── Logo ──
                RichText(
                  text: const TextSpan(children: [
                    TextSpan(
                      text: 'Sporty',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight:
                          FontWeight.w800,
                          fontFamily: 'Poppins'),
                    ),
                    TextSpan(
                      text: 'Qo',
                      style: TextStyle(
                          color: Color(0xFF7B2FFF),
                          fontSize: 36,
                          fontWeight:
                          FontWeight.w800,
                          fontFamily: 'Poppins'),
                    ),
                  ]),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Track. Perform. Rise.',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 0.5),
                ),

                const Spacer(),

                // ── Get Started Button ──
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 24),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const ChooseRoleScreen())),
                    child: Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 18),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF00C853),
                        borderRadius:
                        BorderRadius.circular(
                            30),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: const [
                          Text('Get Started',
                              style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight
                                      .w700)),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward,
                              color: Colors.white,
                              size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Log In Button ──
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 24),
                  child: GestureDetector(
                    onTap: () =>
                        _showLoginOptions(context),
                    child: Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(
                            30),
                        border: Border.all(
                            color: Colors.white24,
                            width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_outline,
                              color: Colors.white,
                              size: 20),
                          SizedBox(width: 8),
                          Text('Log In',
                              style: TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight
                                      .w600)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Trusted text ──
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified_outlined,
                        color: Colors.white38,
                        size: 14),
                    SizedBox(width: 6),
                    Text(
                        'Trusted by athletes & coaches worldwide',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Login Options Bottom Sheet ──
  void _showLoginOptions(BuildContext context) {
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

            const Text('Log In As',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),

            const SizedBox(height: 8),

            const Text(
                'Choose your role to continue',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13)),

            const SizedBox(height: 24),

            // ── Player Login Button ──
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2FFF)
                      .withOpacity(0.15),
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF7B2FFF)
                          .withOpacity(0.5)),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B2FFF)
                          .withOpacity(0.2),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Icon(
                        Icons.sports_cricket,
                        color: Color(0xFF7B2FFF),
                        size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text('Login as Player',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 16)),
                        Text(
                            'Track performance & join leagues',
                            style: TextStyle(
                                color:
                                Colors.white54,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFF7B2FFF),
                      size: 16),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // ── Coach Login Button ──
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
                        Icons.sports_outlined,
                        color: Color(0xFF00C853),
                        size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text('Login as Coach',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 16)),
                        Text(
                            'Manage players & track teams',
                            style: TextStyle(
                                color:
                                Colors.white54,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFF00C853),
                      size: 16),
                ]),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}