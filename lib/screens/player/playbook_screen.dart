import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';

class PlaybookScreen extends StatefulWidget {
  const PlaybookScreen({super.key});

  @override
  State<PlaybookScreen> createState() => _PlaybookScreenState();
}

class _PlaybookScreenState extends State<PlaybookScreen> {
  int _tabIndex = 0;

  String? _meName;
  String? _meSport;
  String? _meAcademy;
  String? _meLocation;
  int? _meQoScore;
  int? _meRank;

  // Content comes from GET /playbook (items shared with the player's
  // teams/leagues by their coach), bucketed by kind per tab.
  final Map<String, List<Map<String, dynamic>>> _byKind = {
    'VIDEO': [],
    'DRILL': [],
    'STRATEGY': [],
    'NOTE': [],
  };
  bool _loading = true;

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  static ({String emoji, Color color}) _kindStyle(String kind) {
    switch (kind) {
      case 'VIDEO':
        return (emoji: '🎬', color: const Color(0xFF1A2A3A));
      case 'DRILL':
        return (emoji: '🏃', color: const Color(0xFF1A3A2A));
      case 'STRATEGY':
        return (emoji: '🧠', color: const Color(0xFF2A1A2A));
      default:
        return (emoji: '📝', color: const Color(0xFF2A2A1A));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final me = await SportyQoApi.me();
      if (!mounted) return;
      setState(() {
        _meName = me['fullName'] as String?;
        _meSport =
            (me['sport'] as Map<String, dynamic>?)?['name'] as String?;
        _meAcademy = me['schoolAcademy'] as String?;
        _meLocation = me['location'] as String?;
        _meQoScore = (me['qoScore'] as num?)?.toInt();
      });
    } catch (_) {}
    try {
      final perf = await SportyQoApi.playerPerformance();
      if (!mounted) return;
      final rank = perf['ranking'] as Map<String, dynamic>?;
      setState(() {
        _meRank = (rank?['position'] as num?)?.toInt();
      });
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final data = await SportyQoApi.playbook();
      if (!mounted) return;
      setState(() {
        for (final k in _byKind.keys) {
          _byKind[k] = [];
        }
        for (final raw in data.cast<Map<String, dynamic>>()) {
          final kind = (raw['kind'] as String? ?? 'NOTE').toUpperCase();
          final st = _kindStyle(kind);
          final dt = DateTime.tryParse(raw['createdAt'] as String? ?? '')
              ?.toLocal();
          final tags = (raw['tags'] as List<dynamic>? ?? [])
              .map((t) => '$t')
              .toList();
          (_byKind[kind] ?? _byKind['NOTE']!).add({
            'title': raw['title'] ?? '',
            'subtitle': (raw['description'] as String?)?.isNotEmpty == true
                ? raw['description'] as String
                : tags.join(' • '),
            'date': dt == null
                ? ''
                : '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}',
            'emoji': st.emoji,
            'color': st.color,
            'duration': '',
            'mediaUrl': raw['mediaUrl'],
          });
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _currentContent {
    switch (_tabIndex) {
      case 0: return _byKind['VIDEO']!;
      case 1: return _byKind['DRILL']!;
      case 2: return _byKind['STRATEGY']!;
      case 3: return _byKind['NOTE']!;
      default: return _byKind['VIDEO']!;
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

              // ── My Profile Card (live from /me + /performance) ──
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
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                          color: const Color(0xFF1A1A1A),
                        ),
                        child: const Center(
                            child:
                                Text('👤', style: TextStyle(fontSize: 36))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_meName ?? 'Player',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            if (_meSport != null)
                              Text(_meSport!,
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            if (_meAcademy != null &&
                                _meAcademy!.isNotEmpty)
                              Row(children: [
                                const Icon(Icons.shield_outlined,
                                    color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(_meAcademy!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11)),
                                ),
                              ]),
                            if (_meLocation != null &&
                                _meLocation!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(children: [
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Text(_meLocation!,
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11)),
                              ]),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Column(children: [
                          const Text('Qo Score',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                          Text('${_meQoScore ?? '—'}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1)),
                          if (_meRank != null) ...[
                            const Text('Rank',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 9)),
                            Text('#$_meRank',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tabs ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  _PlaybookTab(
                      icon: Icons.play_circle_outline,
                      label: 'Videos',
                      isActive: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0)),
                  _PlaybookTab(
                      icon: Icons.directions_run,
                      label: 'Drills',
                      isActive: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1)),
                  _PlaybookTab(
                      icon: Icons.psychology_outlined,
                      label: 'Strategy',
                      isActive: _tabIndex == 2,
                      onTap: () => setState(() => _tabIndex = 2)),
                  _PlaybookTab(
                      icon: Icons.sticky_note_2_outlined,
                      label: 'Notes',
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
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                      )
                    : _currentContent.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                                child: Text(
                                    'Nothing here yet — content shared by your coach will appear here',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 13))),
                          )
                        : GridView.builder(
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