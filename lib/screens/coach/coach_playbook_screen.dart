import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CoachPlaybookScreen extends StatefulWidget {
  const CoachPlaybookScreen({super.key});

  @override
  State<CoachPlaybookScreen> createState() =>
      _CoachPlaybookScreenState();
}

class _CoachPlaybookScreenState extends State<CoachPlaybookScreen> {
  int _tabIndex = 0;

  final List<Map<String, dynamic>> _trainingContent = [
    {'title': 'Batting Practice Session', 'date': '12 May 2025', 'photos': 12, 'emoji': '🏏', 'color': const Color(0xFF1A2A1A)},
    {'title': 'Bowling Drills', 'date': '10 May 2025', 'photos': 8, 'emoji': '🎯', 'color': const Color(0xFF1A1A2A)},
    {'title': 'Strength & Conditioning', 'date': '08 May 2025', 'photos': 6, 'emoji': '💪', 'color': const Color(0xFF2A1A1A)},
    {'title': 'Match Preparation', 'date': '05 May 2025', 'photos': 10, 'emoji': '📋', 'color': const Color(0xFF1A2A2A)},
  ];

  final List<Map<String, dynamic>> _teamsContent = [
    {'title': 'Falcons U16 Team', 'date': '01 May 2025', 'photos': 15, 'emoji': '🦅', 'color': const Color(0xFF1A1A3A)},
    {'title': 'Academy Squad 2025', 'date': '28 Apr 2025', 'photos': 20, 'emoji': '👥', 'color': const Color(0xFF2A1A2A)},
    {'title': 'Under16 Tournament', 'date': '25 Apr 2025', 'photos': 18, 'emoji': '🏆', 'color': const Color(0xFF1A3A1A)},
    {'title': 'Practice Match Day', 'date': '22 Apr 2025', 'photos': 9, 'emoji': '🏟️', 'color': const Color(0xFF2A2A1A)},
  ];

  final List<Map<String, dynamic>> _achievementsContent = [
    {'title': 'Best Coach Award 2024', 'date': '15 Mar 2025', 'photos': 5, 'emoji': '🏅', 'color': const Color(0xFF2A1A0A)},
    {'title': 'State Championship Win', 'date': '10 Mar 2025', 'photos': 22, 'emoji': '🥇', 'color': const Color(0xFF1A2A0A)},
    {'title': 'BCCI Certification', 'date': '01 Jan 2025', 'photos': 4, 'emoji': '🎓', 'color': const Color(0xFF0A1A2A)},
    {'title': 'Tournament Trophy', 'date': '20 Dec 2024', 'photos': 8, 'emoji': '🏆', 'color': const Color(0xFF1A0A2A)},
  ];

  final List<Map<String, dynamic>> _eventsContent = [
    {'title': 'Annual Sports Day', 'date': '20 May 2025', 'photos': 30, 'emoji': '🎪', 'color': const Color(0xFF2A1A1A)},
    {'title': 'Coaching Workshop', 'date': '18 May 2025', 'photos': 12, 'emoji': '📚', 'color': const Color(0xFF1A1A2A)},
    {'title': 'Inter Academy Match', 'date': '15 May 2025', 'photos': 25, 'emoji': '⚡', 'color': const Color(0xFF1A2A1A)},
    {'title': 'Award Ceremony', 'date': '10 May 2025', 'photos': 16, 'emoji': '🎖️', 'color': const Color(0xFF2A2A1A)},
  ];

  List<Map<String, dynamic>> get _currentContent {
    switch (_tabIndex) {
      case 0: return _trainingContent;
      case 1: return _teamsContent;
      case 2: return _achievementsContent;
      case 3: return _eventsContent;
      default: return _trainingContent;
    }
  }

  final List<Map<String, dynamic>> _recommendedPlayers = [
    {'name': 'Sai Kishore', 'role': 'Spinner', 'emoji': '🎯', 'pts': 210},
    {'name': 'Priya Singh', 'role': 'Batsman', 'emoji': '🏏', 'pts': 195},
    {'name': 'Dev Anand', 'role': 'All Rounder', 'emoji': '⚡', 'pts': 178},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Profile Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar — clickable
                      GestureDetector(
                        onTap: () => _showProfileImageDialog(context),
                        child: Stack(children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                              color: const Color(0xFF1A1A1A),
                            ),
                            child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
                          ),
                          Positioned(
                            top: 0, left: 0,
                            child: Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(color: const Color(0xFF1A6BFF), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF111111), width: 1.5)),
                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1.5)),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('Rahul Sharma', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF1A6BFF), size: 16),
                            ]),
                            const Text('Head Coach', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Row(children: const [
                              Icon(Icons.shield_outlined, color: Colors.white38, size: 12),
                              SizedBox(width: 4),
                              Text('Falcons Cricket Academy', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            ]),
                            const SizedBox(height: 3),
                            Row(children: const [
                              Icon(Icons.access_time, color: Colors.white38, size: 12),
                              SizedBox(width: 4),
                              Text('6+ Years Experience', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ]),
                            const SizedBox(height: 3),
                            Row(children: const [
                              Icon(Icons.location_on_outlined, color: Colors.white38, size: 12),
                              SizedBox(width: 4),
                              Text('Bangalore, Karnataka', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ]),
                            const SizedBox(height: 3),
                            Row(children: const [
                              Icon(Icons.workspace_premium_outlined, color: Colors.white38, size: 12),
                              SizedBox(width: 4),
                              Text('BCCI Level 2 Certified Coach', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: const [
                              Icon(Icons.check_circle, color: Color(0xFF00C853), size: 13),
                              SizedBox(width: 4),
                              Text('Verified Coach', style: TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.w600)),
                            ]),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Column(children: const [
                          Text('Coach Score', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                          Text('92', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
                          Text('Rank', style: TextStyle(color: Colors.white38, fontSize: 9)),
                          Text('#3', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          Text('In Karnataka\nCoaches', style: TextStyle(color: Colors.white38, fontSize: 8), textAlign: TextAlign.center),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── About ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('About', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      SizedBox(height: 6),
                      Text('Building champions on and off the field.\nPassionate about developing young talent and creating winning teams. 🏏', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Stats Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(icon: Icons.people_outline, value: '342', label: 'Players\nTrained'),
                      Container(height: 40, width: 1, color: Colors.white10),
                      _StatItem(icon: Icons.emoji_events_outlined, value: '48', label: 'Tournaments'),
                      Container(height: 40, width: 1, color: Colors.white10),
                      _StatItem(icon: Icons.military_tech_outlined, value: '26', label: 'Awards'),
                      Container(height: 40, width: 1, color: Colors.white10),
                      _StatItem(icon: Icons.calendar_today_outlined, value: '6+', label: 'Years\nExperience'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Recommend Players Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _showRecommendPlayers(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Recommend Players', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tabs ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _PlaybookTab(icon: Icons.directions_run, label: 'Training', isActive: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                  _PlaybookTab(icon: Icons.people_outline, label: 'Teams', isActive: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                  _PlaybookTab(icon: Icons.emoji_events_outlined, label: 'Achievements', isActive: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
                  _PlaybookTab(icon: Icons.campaign_outlined, label: 'Events', isActive: _tabIndex == 3, onTap: () => setState(() => _tabIndex = 3)),
                ]),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(height: 1, color: Colors.white10),
              ),

              const SizedBox(height: 16),

              // ── Content Grid ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _currentContent.length,
                  itemBuilder: (context, i) {
                    final item = _currentContent[i];
                    return GestureDetector(
                      onTap: () => _showVideoPlayer(context, item),
                      child: _ContentCard(item: item),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Add New ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _showUploadDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('Add training photos,\nvideos and more', style: TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.white38),
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

  void _showProfileImageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large profile view
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                color: const Color(0xFF1A1A1A),
              ),
              child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 64))),
            ),
            const SizedBox(height: 12),
            const Text('Rahul Sharma',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const Text('Head Coach',
                style: TextStyle(color: AppColors.primary, fontSize: 13)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Camera opened 📷'),
                          backgroundColor: Color(0xFF00C853)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Column(children: [
                      Icon(Icons.camera_alt,
                          color: AppColors.primary, size: 24),
                      const SizedBox(height: 6),
                      Text('Take Photo',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Gallery opened 🖼️'),
                          backgroundColor: Color(0xFF00C853)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Column(children: [
                      Icon(Icons.photo_library,
                          color: AppColors.primary, size: 24),
                      const SizedBox(height: 6),
                      Text('Gallery',
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  void _showRecommendPlayers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recommend Players',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Select players to recommend to clubs & leagues.',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            ..._recommendedPlayers.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(children: [
                Text(p['emoji'], style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text(p['role'],
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${p['pts']} pts',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${p['name']} recommended! ✅'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Send',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ),
              ]),
            )),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  void _showVideoPlayer(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VideoPlayerScreen(item: item),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Content',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _UploadOption(icon: Icons.camera_alt, label: 'Camera', color: AppColors.primary, onTap: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: _UploadOption(icon: Icons.photo_library, label: 'Gallery', color: AppColors.primary, onTap: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: _UploadOption(icon: Icons.videocam, label: 'Video', color: AppColors.primary, onTap: () => Navigator.pop(context))),
            ]),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }
}

// ── Video Player Screen ───────────────────────────────────────────────

class _VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const _VideoPlayerScreen({required this.item});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item['title'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Video area ──
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background emoji
                    Text(item['emoji'] as String,
                        style: const TextStyle(fontSize: 100)),

                    // Play/Pause overlay
                    GestureDetector(
                      onTap: () => setState(() => _isPlaying = !_isPlaying),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Photo count badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.photo_outlined,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text('${item['photos']} photos',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ]),
                      ),
                    ),

                    // Playing indicator
                    if (_isPlaying)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(children: [
                          Container(
                              width: 4, height: 16,
                              color: AppColors.primary,
                              margin: const EdgeInsets.only(right: 3)),
                          Container(
                              width: 4, height: 24,
                              color: AppColors.primary,
                              margin: const EdgeInsets.only(right: 3)),
                          Container(
                              width: 4, height: 12,
                              color: AppColors.primary,
                              margin: const EdgeInsets.only(right: 3)),
                          Container(
                              width: 4, height: 20,
                              color: AppColors.primary),
                        ]),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: AppColors.primary,
                    trackHeight: 3,
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _progress,
                    onChanged: (v) => setState(() => _progress = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0:00',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text('3:45',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Controls ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _progress = 0),
                    child: const Icon(Icons.skip_previous,
                        color: Colors.white, size: 36),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isPlaying = !_isPlaying),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _progress = 1.0),
                    child: const Icon(Icons.skip_next,
                        color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Info ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(children: [
                  Text(item['emoji'] as String,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text(item['date'] as String,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800)),
      Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 9)),
    ]);
  }
}

class _PlaybookTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PlaybookTab(
      {required this.icon,
        required this.label,
        required this.isActive,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isActive ? AppColors.primary : Colors.white38,
                  size: 13),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color:
                      isActive ? AppColors.primary : Colors.white38,
                      fontSize: 11,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w400)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
              height: 2,
              color: isActive ? AppColors.primary : Colors.transparent),
        ]),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ContentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item['color'] as Color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(children: [
        Positioned(
          top: 10, left: 10,
          child: Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
                color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow,
                color: Colors.white, size: 18),
          ),
        ),
        Center(
            child: Text(item['emoji'] as String,
                style: const TextStyle(fontSize: 48))),
        Positioned(
          bottom: 50, right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              const Icon(Icons.photo_outlined, color: Colors.white, size: 10),
              const SizedBox(width: 3),
              Text('${item['photos']}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(14)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.transparent
                ],
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(item['date'] as String,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.white54, size: 16),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _UploadOption(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ]),
      ),
    );
  }
}