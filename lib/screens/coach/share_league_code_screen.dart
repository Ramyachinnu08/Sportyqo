import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'coach_home_screen.dart';

class ShareLeagueCodeScreen extends StatelessWidget {
  final String leagueName;
  final String leagueCode;

  const ShareLeagueCodeScreen({
    super.key,
    required this.leagueName,
    required this.leagueCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Text('Share League Code', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
              ),

              const SizedBox(height: 32),

              // Shield success
              Stack(alignment: Alignment.center, children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFF00C853).withOpacity(0.3), Colors.transparent]),
                  ),
                ),
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00C853).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFF00C853), width: 2),
                  ),
                  child: const Icon(Icons.shield, color: Color(0xFF00C853), size: 50),
                ),
              ]),

              const SizedBox(height: 20),

              const Text('League Created!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Share this code with players to\ninvite them to join your league.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                ),
              ),

              const SizedBox(height: 28),

              // League Code Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('LEAGUE CODE', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: leagueCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code Copied! 📋'), backgroundColor: Color(0xFF00C853)),
                            );
                          },
                          child: Row(children: const [
                            Icon(Icons.copy_outlined, color: Color(0xFF00C853), size: 16),
                            SizedBox(width: 4),
                            Text('Copy', style: TextStyle(color: Color(0xFF00C853), fontSize: 13, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3), style: BorderStyle.solid),
                      ),
                      child: Center(
                        child: Text(leagueCode,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 4)),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(children: const [
                    Icon(Icons.info_outline, color: Color(0xFF00C853), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Players can use this code to join your league in the SportyQo app.',
                        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 20),

              // Share via
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Share via', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Share.share('Join my league "$leagueName" on SportyQo! Use code: $leagueCode'),
                            child: Column(children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(color: const Color(0xFF25D366).withOpacity(0.15), shape: BoxShape.circle),
                                child: const Center(child: Text('💬', style: TextStyle(fontSize: 28))),
                              ),
                              const SizedBox(height: 8),
                              const Text('WhatsApp', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            ]),
                          ),
                        ),
                        Container(height: 50, width: 1, color: Colors.white10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Share.share('Join my league "$leagueName" on SportyQo! Use code: $leagueCode'),
                            child: Column(children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(color: const Color(0xFF1A6BFF).withOpacity(0.15), shape: BoxShape.circle),
                                child: const Icon(Icons.message_outlined, color: Color(0xFF1A6BFF), size: 28),
                              ),
                              const SizedBox(height: 8),
                              const Text('SMS', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            ]),
                          ),
                        ),
                        Container(height: 50, width: 1, color: Colors.white10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: leagueCode));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link Copied!'), backgroundColor: Color(0xFF00C853)));
                            },
                            child: Column(children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.15), shape: BoxShape.circle),
                                child: const Icon(Icons.link, color: Color(0xFF00C853), size: 28),
                              ),
                              const SizedBox(height: 8),
                              const Text('Copy Link', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            ]),
                          ),
                        ),
                        Container(height: 50, width: 1, color: Colors.white10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Column(children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                                child: const Icon(Icons.more_horiz, color: Colors.white60, size: 28),
                              ),
                              const SizedBox(height: 8),
                              const Text('More', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const CoachHomeScreen()),
                            (route) => false,
                      ),
                      icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      label: const Text('View League Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Create Another League', style: TextStyle(color: Color(0xFF1A6BFF), fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}