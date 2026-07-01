import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PlaybookScreen extends StatefulWidget {
  const PlaybookScreen({super.key});

  @override
  State<PlaybookScreen> createState() => _PlaybookScreenState();
}

class _PlaybookScreenState extends State<PlaybookScreen> {
  int _tabIndex = 0;
  bool _isFollowing = false;

  final List<Map<String, dynamic>> _playingVideos = [
    {'title': 'Century vs DSO Academy', 'subtitle': '125 Runs', 'date': '12 May 2025', 'emoji': '🏏', 'color': const Color(0xFF1A3A2A), 'duration': '2:34'},
    {'title': 'Match Winning Knock', 'subtitle': '78 Runs', 'date': '5 May 2025', 'emoji': '🏏', 'color': const Color(0xFF1A2A3A), 'duration': '1:45'},
    {'title': 'Bowling Spell', 'subtitle': '4/18', 'date': '28 Apr 2025', 'emoji': '🎯', 'color': const Color(0xFF2A1A1A), 'duration': '3:12'},
    {'title': 'Brilliant Catch', 'subtitle': 'vs Mumbai Colts', 'date': '20 Apr 2025', 'emoji': '🧤', 'color': const Color(0xFF1A1A2A), 'duration': '0:45'},
  ];

  final List<Map<String, dynamic>> _certificatesVideos = [
    {'title': 'BCCI Level 2 Certificate', 'subtitle': 'Certified', 'date': '10 Jan 2025', 'emoji': '🎓', 'color': const Color(0xFF1A2A3A), 'duration': '1:20'},
    {'title': 'Sports Excellence Award', 'subtitle': 'State Level', 'date': '15 Dec 2024', 'emoji': '🏅', 'color': const Color(0xFF2A1A1A), 'duration': '2:10'},
    {'title': 'District Championship', 'subtitle': 'Gold Medal', 'date': '20 Nov 2024', 'emoji': '🥇', 'color': const Color(0xFF1A1A2A), 'duration': '1:55'},
    {'title': 'Academy Certificate', 'subtitle': 'Falcons FC', 'date': '01 Oct 2024', 'emoji': '📜', 'color': const Color(0xFF2A2A1A), 'duration': '0:58'},
  ];

  final List<Map<String, dynamic>> _teamVideos = [
    {'title': 'Falcons FC Team', 'subtitle': 'U16 Division', 'date': '2024-25', 'emoji': '🦅', 'color': const Color(0xFF1A1A2A), 'duration': '3:45'},
    {'title': 'Alpha Warriors', 'subtitle': 'U16 Division', 'date': '2023-24', 'emoji': '⚔️', 'color': const Color(0xFF2A1A2A), 'duration': '2:30'},
    {'title': 'Team Practice', 'subtitle': 'Morning Session', 'date': '15 May 2025', 'emoji': '👥', 'color': const Color(0xFF1A2A1A), 'duration': '4:12'},
    {'title': 'Match Day Prep', 'subtitle': 'vs Royal Strikers', 'date': '10 May 2025', 'emoji': '⚽', 'color': const Color(0xFF2A2A1A), 'duration': '1:30'},
  ];

  final List<Map<String, dynamic>> _trophiesVideos = [
    {'title': 'Best Batsman Trophy', 'subtitle': 'DSO Academy', 'date': '12 May 2025', 'emoji': '🏆', 'color': const Color(0xFF2A1A2A), 'duration': '1:15'},
    {'title': 'MVP Award', 'subtitle': 'Inter School', 'date': '5 May 2025', 'emoji': '🥇', 'color': const Color(0xFF1A2A2A), 'duration': '0:55'},
    {'title': 'Tournament Winners', 'subtitle': 'U16 League', 'date': '28 Apr 2025', 'emoji': '🎖️', 'color': const Color(0xFF2A1A1A), 'duration': '2:20'},
    {'title': 'Player of the Year', 'subtitle': '2024 Season', 'date': '01 Jan 2025', 'emoji': '⭐', 'color': const Color(0xFF1A1A3A), 'duration': '3:00'},
  ];

  List<Map<String, dynamic>> get _currentContent {
    switch (_tabIndex) {
      case 0: return _playingVideos;
      case 1: return _certificatesVideos;
      case 2: return _teamVideos;
      case 3: return _trophiesVideos;
      default: return _playingVideos;
    }
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
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: _UploadOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      color: AppColors.primary,
                      onTap: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(
                  child: _UploadOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      color: AppColors.primary,
                      onTap: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(
                  child: _UploadOption(
                      icon: Icons.videocam,
                      label: 'Video',
                      color: AppColors.primary,
                      onTap: () => Navigator.pop(context))),
            ]),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

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
                  child: Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                              color: const Color(0xFF1A1A1A),
                            ),
                            child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A6BFF),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF111111), width: 1.5),
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1.5),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white60, size: 12),
                            ),
                          ),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Text('Aarav Mehta',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Color(0xFF1A6BFF), size: 16),
                              ]),
                              const Text('Head Coach',
                                  style: TextStyle(
                                      color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Row(children: const [
                                Icon(Icons.shield_outlined, color: Colors.white38, size: 12),
                                SizedBox(width: 4),
                                Text('Falcons Cricket Academy',
                                    style: TextStyle(color: Colors.white60, fontSize: 11)),
                              ]),
                              const SizedBox(height: 3),
                              Row(children: const [
                                Icon(Icons.access_time, color: Colors.white38, size: 12),
                                SizedBox(width: 4),
                                Text('6+ Years Experience',
                                    style: TextStyle(color: Colors.white38, fontSize: 11)),
                              ]),
                              const SizedBox(height: 3),
                              Row(children: const [
                                Icon(Icons.location_on_outlined, color: Colors.white38, size: 12),
                                SizedBox(width: 4),
                                Text('Bangalore, Karnataka',
                                    style: TextStyle(color: Colors.white38, fontSize: 11)),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: const [
                                Icon(Icons.check_circle, color: Color(0xFF00C853), size: 13),
                                SizedBox(width: 4),
                                Text('Verified Coach',
                                    style: TextStyle(
                                        color: Color(0xFF00C853),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Column(children: const [
                            Text('Coach Score',
                                style: TextStyle(
                                    color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                            Text('92',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1)),
                            Text('Rank', style: TextStyle(color: Colors.white38, fontSize: 9)),
                            Text('#3',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                            Text('In Karnataka\nCoaches',
                                style: TextStyle(color: Colors.white38, fontSize: 8),
                                textAlign: TextAlign.center),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('About',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                          SizedBox(height: 6),
                          Text(
                              'Building champions on and off the field. Passionate about developing young talent and creating winning teams. 🏏',
                              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(children: [
                      _StatItem(value: '342', label: 'Players\nTrained'),
                      _StatItem(value: '48', label: 'Tournaments'),
                      _StatItem(value: '26', label: 'Awards'),
                      _StatItem(value: '6+', label: 'Years\nExp'),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isFollowing = !_isFollowing),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isFollowing ? Colors.white10 : AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: _isFollowing ? Border.all(color: Colors.white24) : null,
                          ),
                          child: Text(
                            _isFollowing ? 'Following ✓' : 'Follow',
                            style: TextStyle(
                                color: _isFollowing ? Colors.white70 : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tabs ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _PlaybookTab(
                      icon: Icons.directions_run,
                      label: 'Playing',
                      isActive: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0)),
                  _PlaybookTab(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Certificates',
                      isActive: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1)),
                  _PlaybookTab(
                      icon: Icons.people_outline,
                      label: 'Team',
                      isActive: _tabIndex == 2,
                      onTap: () => setState(() => _tabIndex = 2)),
                  _PlaybookTab(
                      icon: Icons.emoji_events_outlined,
                      label: 'Trophies',
                      isActive: _tabIndex == 3,
                      onTap: () => setState(() => _tabIndex = 3)),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _VideoPlayerScreen(item: item),
                        ),
                      ),
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
                        width: 44,
                        height: 44,
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
                          Text('Add New',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('Add match videos, highlights and performances',
                              style: TextStyle(color: Colors.white38, fontSize: 11)),
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
  bool _showControls = true;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                  if (!_isPlaying) {
                    _isPlaying = true;
                    _simulateProgress();
                  }
                });
              },
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                color: const Color(0xFF0A0A0A),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(widget.item['emoji'] as String, style: const TextStyle(fontSize: 80)),
                    Container(color: Colors.black.withOpacity(0.3)),
                    if (_showControls)
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    if (_showControls)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.item['duration'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ]),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(children: [
                        if (_showControls)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(children: [
                              Text(
                                _formatTime(_progress),
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                              const Spacer(),
                              Text(
                                widget.item['duration'] as String,
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ]),
                          ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white24,
                          color: AppColors.primary,
                          minHeight: 3,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item['title'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(widget.item['subtitle'] as String,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const Text(' • ', style: TextStyle(color: Colors.white38)),
                    Text(widget.item['date'] as String,
                        style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ]),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ControlBtn(
                        icon: Icons.replay_10,
                        label: 'Replay',
                        onTap: () => setState(() => _progress = (_progress - 0.1).clamp(0.0, 1.0)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                            if (_isPlaying) _simulateProgress();
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      _ControlBtn(
                        icon: Icons.forward_10,
                        label: 'Forward',
                        onTap: () => setState(() => _progress = (_progress + 0.1).clamp(0.0, 1.0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: _ActionBtn(icon: Icons.thumb_up_outlined, label: 'Like', onTap: () {})),
                    Expanded(child: _ActionBtn(icon: Icons.share_outlined, label: 'Share', onTap: () {})),
                    Expanded(child: _ActionBtn(icon: Icons.download_outlined, label: 'Save', onTap: () {})),
                    Expanded(child: _ActionBtn(icon: Icons.more_horiz, label: 'More', onTap: () {})),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateProgress() async {
    while (_isPlaying && _progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _isPlaying) {
        setState(() => _progress += 0.02);
        if (_progress >= 1.0) {
          setState(() {
            _isPlaying = false;
            _progress = 0.0;
          });
        }
      }
    }
  }

  String _formatTime(double progress) {
    final parts = (widget.item['duration'] as String).split(':');
    final totalSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final currentSeconds = (totalSeconds * progress).round();
    final m = currentSeconds ~/ 60;
    final s = currentSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ]),
    );
  }
}

class _PlaybookTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PlaybookTab(
      {required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? AppColors.primary : Colors.white38, size: 13),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: isActive ? AppColors.primary : Colors.white38,
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 2, color: isActive ? AppColors.primary : Colors.transparent),
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
          top: 10,
          left: 10,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
            child: Text(item['duration'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ),
        Center(child: Text(item['emoji'] as String, style: const TextStyle(fontSize: 48))),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.9), Colors.transparent],
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(item['date'] as String,
                        style: const TextStyle(color: Colors.white54, fontSize: 10)),
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
      {required this.icon, required this.label, required this.color, required this.onTap});

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

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: Colors.white70, size: 26),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
    );
  }
}