import 'package:flutter/material.dart';
import 'dart:async';
import 'player_id_ready_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';

class GeneratingIdScreen extends StatefulWidget {
  final String selectedSport;
  const GeneratingIdScreen({super.key, required this.selectedSport});

  @override
  State<GeneratingIdScreen> createState() => _GeneratingIdScreenState();
}

class _GeneratingIdScreenState extends State<GeneratingIdScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _register();
  }

  Future<void> _register() async {
    // Keep the animation visible for at least a moment even on fast networks.
    final minDelay = Future.delayed(const Duration(milliseconds: 1500));
    try {
      RegistrationDraft.instance.sportName = widget.selectedSport;
      final playerId = await AuthService.registerPlayerFromDraft();
      await minDelay;
      if (!mounted) return;
      RegistrationDraft.instance.reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PlayerIdReadyScreen(
            playerId: playerId,
            selectedSport: widget.selectedSport,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final detail = (e.details != null && e.details!.isNotEmpty)
          ? (e.details!.first['message'] ?? e.message)
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'CONFLICT'
            ? 'An account with this email/phone already exists'
            : '$detail'),
        backgroundColor: Colors.redAccent,
      ));
      Navigator.of(context).pop(); // back to sport selection to retry
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Generating\nPlayer ID...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _spinController,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFF7B2FFF).withOpacity(0.0),
                              const Color(0xFF7B2FFF).withOpacity(0.9),
                            ],
                            startAngle: 0,
                            endAngle: 2 * pi,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0A0A1A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7B2FFF).withOpacity(0.15),
                        border: Border.all(
                          color: const Color(0xFF7B2FFF),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF7B2FFF),
                        size: 44,
                      ),
                    ),
                    Positioned(
                      bottom: 28,
                      right: 28,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00C853),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'Please wait while we\ncreate your unique\nPlayer ID.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}