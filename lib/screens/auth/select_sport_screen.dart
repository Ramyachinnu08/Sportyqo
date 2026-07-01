import 'package:flutter/material.dart';
import 'generating_id_screen.dart';

class SelectSportScreen extends StatefulWidget {
  const SelectSportScreen({super.key});

  @override
  State<SelectSportScreen> createState() => _SelectSportScreenState();
}

class _SelectSportScreenState extends State<SelectSportScreen> {
  String? selectedSport;

  final List<Map<String, String>> sports = [
    {
      'name': 'Cricket',
      'image': 'https://i.ibb.co/mC7w3JvY/Screenshot-2026-06-30-122618.png',
    },
    {
      'name': 'Football',
      'image': 'https://i.ibb.co/bgZY2Qb9/Screenshot-2026-06-30-122653.png',
    },
    {
      'name': 'Volleyball',
      'image': 'https://i.ibb.co/Jj2fLjFX/Screenshot-2026-06-30-122700.png',
    },
    {
      'name': 'Basketball',
      'image': 'https://i.ibb.co/WN5yRxqX/Screenshot-2026-06-30-122705.png',
    },
    {
      'name': 'Swimming',
      'image': 'https://i.ibb.co/N6X7pRvv/Screenshot-2026-06-30-122716.png',
    },
    {
      'name': 'Badminton',
      'image': 'https://i.ibb.co/sJNf2nWT/Screenshot-2026-06-30-122810.png',
    },
    {
      'name': 'Tennis',
      'image': 'https://i.ibb.co/XTmSVLH/Screenshot-2026-06-30-122816.png',
    },
    {
      'name': 'Kabaddi',
      'image': 'https://i.ibb.co/MDbR7Fw2/Screenshot-2026-06-30-122823.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Select Your Sport',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the sport you play to continue',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  itemCount: sports.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final sport = sports[index];
                    final isSelected = selectedSport == sport['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSport = sport['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14142B),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7B2FFF)
                                : Colors.white10,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: const Color(0xFF7B2FFF)
                                  .withOpacity(0.4),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                sport['image']!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white24,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.white10,
                                    child: const Icon(
                                      Icons.sports,
                                      color: Colors.white38,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sport['name']!,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF7B2FFF)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedSport == null
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GeneratingIdScreen(selectedSport: selectedSport!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2FFF),
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}