import 'package:flutter/material.dart';
import 'coach_home_screen.dart';

class SelectCoachSportScreen extends StatefulWidget {
  const SelectCoachSportScreen({super.key});

  @override
  State<SelectCoachSportScreen> createState() =>
      _SelectCoachSportScreenState();
}

class _SelectCoachSportScreenState extends State<SelectCoachSportScreen> {
  String? _selectedSport;

  final List<Map<String, dynamic>> _sports = [
    {
      'name': 'Cricket',
      'emoji': '🏏',
      'image': 'https://i.ibb.co/mC7w3JvY/Screenshot-2026-06-30-122618.png',
    },
    {
      'name': 'Football',
      'emoji': '⚽',
      'image': 'https://i.ibb.co/bgZY2Qb9/Screenshot-2026-06-30-122653.png',
    },
    {
      'name': 'Volleyball',
      'emoji': '🏐',
      'image': 'https://i.ibb.co/Jj2fLjFX/Screenshot-2026-06-30-122700.png',
    },
    {
      'name': 'Basketball',
      'emoji': '🏀',
      'image': 'https://i.ibb.co/WN5yRxqX/Screenshot-2026-06-30-122705.png',
    },
    {
      'name': 'Swimming',
      'emoji': '🏊',
      'image': 'https://i.ibb.co/N6X7pRvv/Screenshot-2026-06-30-122716.png',
    },
    {
      'name': 'Badminton',
      'emoji': '🏸',
      'image': 'https://i.ibb.co/sJNf2nWT/Screenshot-2026-06-30-122810.png',
    },
    {
      'name': 'Tennis',
      'emoji': '🎾',
      'image': 'https://i.ibb.co/XTmSVLH/Screenshot-2026-06-30-122816.png',
    },
    {
      'name': 'Kabaddi',
      'emoji': '🤼',
      'image': 'https://i.ibb.co/MDbR7Fw2/Screenshot-2026-06-30-122823.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                        text: 'Select Your Sport',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 26,
                            fontWeight: FontWeight.w800),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose the sport you coach.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Sports Grid ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: _sports.length,
                  itemBuilder: (context, i) {
                    final sport = _sports[i];
                    final isSelected = _selectedSport == sport['name'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedSport = sport['name']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F2A),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00C853)
                                : Colors.white12,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: const Color(0xFF00C853)
                                  .withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                sport['image'] as String,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  sport['emoji'] as String,
                                  style: const TextStyle(fontSize: 52),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              sport['name'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF00C853)
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C853),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Continue Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSport == null
                      ? null
                      : () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CoachHomeScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    disabledBackgroundColor:
                    const Color(0xFF00C853).withOpacity(0.3),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _selectedSport == null
                        ? 'Select a Sport'
                        : 'Continue as $_selectedSport Coach',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}