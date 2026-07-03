import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
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
            'id': raw['id'],
            'isMine': raw['isMine'] == true,
            'kind': kind,
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

  /// Long-press on one of your own uploads → confirm → DELETE /playbook/:id.
  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final id = item['id'] as String?;
    if (id == null) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this upload?',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Text('"${item['title']}" will be removed permanently.',
            style: const TextStyle(color: Colors.white60, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white38))),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      await SportyQoApi.deletePlaybookItem(id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Deleted'), backgroundColor: Color(0xFF00C853)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: Colors.redAccent));
    }
  }

  /// Picks a photo or video, asks for a title, uploads it to POST /playbook
  /// with live progress, then refreshes the grid so the new item appears.
  Future<void> _pickAndUpload(BuildContext sheetContext,
      {required ImageSource source, required bool video}) async {
    Navigator.pop(sheetContext); // close the picker sheet first

    final picker = ImagePicker();
    XFile? file;
    try {
      file = video
          ? await picker.pickVideo(
              source: source, maxDuration: const Duration(minutes: 5))
          : await picker.pickImage(
              source: source, maxWidth: 1920, imageQuality: 88);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Could not open the camera/gallery. Check the app permissions in Settings.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    if (file == null || !mounted) return; // user cancelled

    // Suggest a title from the file name; the user can change it.
    final rawName = file.name.split('.').first.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    final titleCtrl = TextEditingController(
        text: rawName.length >= 3 ? rawName : (video ? 'My video' : 'My photo'));
    final descCtrl = TextEditingController();
    final progress = ValueNotifier<double>(0);
    bool uploading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24,
              24 + MediaQuery.of(dialogContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(video ? Icons.videocam : Icons.photo,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Text(video ? 'Upload video' : 'Upload photo',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                enabled: !uploading,
                maxLength: 140,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title (min 3 characters)',
                  counterText: '',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                enabled: !uploading,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              if (uploading) ...[
                ValueListenableBuilder<double>(
                  valueListenable: progress,
                  builder: (_, v, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: v > 0 ? v : null,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          v >= 1
                              ? 'Processing…'
                              : 'Uploading… ${(v * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: uploading
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          if (title.length < 3) {
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Give it a title (3+ characters)'),
                              backgroundColor: Colors.redAccent,
                            ));
                            return;
                          }
                          setSheetState(() => uploading = true);
                          try {
                            await SportyQoApi.uploadPlaybookMedia(
                              filePath: file!.path,
                              title: title,
                              description: descCtrl.text.trim(),
                              kind: video ? 'VIDEO' : null,
                              onProgress: (v) => progress.value = v,
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            await _load();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(video
                                  ? 'Video uploaded ✅'
                                  : 'Photo uploaded ✅'),
                              backgroundColor: const Color(0xFF00C853),
                            ));
                          } on ApiException catch (e) {
                            if (!dialogContext.mounted) return;
                            setSheetState(() => uploading = false);
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(SnackBar(
                              content: Text(e.code == 'NETWORK'
                                  ? 'Upload failed — check your connection and try again.'
                                  : e.message),
                              backgroundColor: Colors.redAccent,
                            ));
                          } catch (_) {
                            if (!dialogContext.mounted) return;
                            setSheetState(() => uploading = false);
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Upload failed — please try again.'),
                              backgroundColor: Colors.redAccent,
                            ));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(uploading ? 'Uploading…' : 'Upload',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              if (!uploading)
                Center(
                  child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white38))),
                ),
            ],
          ),
        ),
      ),
    );
    progress.dispose();
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
                      onTap: () => _pickAndUpload(context,
                          source: ImageSource.camera, video: false))),
              const SizedBox(width: 12),
              Expanded(
                  child: _UploadOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      color: AppColors.primary,
                      onTap: () => _pickAndUpload(context,
                          source: ImageSource.gallery, video: false))),
              const SizedBox(width: 12),
              Expanded(
                  child: _UploadOption(
                      icon: Icons.videocam,
                      label: 'Video',
                      color: AppColors.primary,
                      onTap: () => _pickAndUpload(context,
                          source: ImageSource.gallery, video: true))),
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
                                Flexible(
                                  child: Text(_meLocation!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11)),
                                ),
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
                    final isVideo =
                        (item['kind'] as String? ?? '') == 'VIDEO';
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isVideo
                              ? _VideoPlayerScreen(item: item)
                              : _ContentDetailScreen(item: item),
                        ),
                      ),
                      onLongPress: item['isMine'] == true
                          ? () => _confirmDelete(item)
                          : null,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Add New',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            Text(
                                'Add match videos, highlights and performances',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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

/// Plays the item's uploaded/shared video from its `mediaUrl`. Items without
/// media (metadata-only VIDEO notes from a coach) get a friendly placeholder
/// instead of the old fake player with simulated progress.
class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _failed = false;
  bool _showControls = true;

  String? get _mediaUrl =>
      ApiClient.resolveMediaUrl(widget.item['mediaUrl'] as String?);

  @override
  void initState() {
    super.initState();
    final url = _mediaUrl;
    if (url != null) {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = c;
      c.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        c.play();
      }).catchError((_) {
        if (mounted) setState(() => _failed = true);
      });
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized && !_failed;
    final title = widget.item['title'] as String? ?? 'Video';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Center(
              child: c == null || _failed
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.item['emoji'] as String? ?? '🎬',
                            style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text(
                            _failed
                                ? 'This video could not be played.\nCheck your connection and try again.'
                                : 'No video attached to this item yet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13)),
                      ],
                    )
                  : !ready
                      ? const CircularProgressIndicator(
                          color: AppColors.primary)
                      : GestureDetector(
                          onTap: () => setState(
                              () => _showControls = !_showControls),
                          child: AspectRatio(
                            aspectRatio: c.value.aspectRatio == 0
                                ? 16 / 9
                                : c.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(c),
                                if (_showControls)
                                  GestureDetector(
                                    onTap: () => setState(() => c
                                            .value.isPlaying
                                        ? c.pause()
                                        : c.play()),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle),
                                      child: Icon(
                                          c.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 38),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
          if (ready)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(children: [
                VideoProgressIndicator(
                  c,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white10,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(c.value.position),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                    Text(_fmt(c.value.duration),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

/// Pinch-to-zoom viewer for uploaded photos.
class _FullscreenImage extends StatelessWidget {
  final String url;
  const _FullscreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text('Could not load image',
                style: TextStyle(color: Colors.white54)),
          ),
        ),
      ),
    );
  }
}

// ── Content Detail Screen (drills / strategies / notes) ──────────────
// Non-video playbook items used to open the fake video player and crash
// with a red error screen; they now get a proper read view.

class _ContentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ContentDetailScreen({required this.item});

  String get _kindLabel {
    switch (item['kind'] as String? ?? '') {
      case 'DRILL':
        return 'Drill';
      case 'STRATEGY':
        return 'Strategy';
      case 'VIDEO':
        return 'Video';
      default:
        return 'Note';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title'] as String? ?? '';
    final description = item['subtitle'] as String? ?? '';
    final date = item['date'] as String? ?? '';
    final emoji = item['emoji'] as String? ?? '📝';
    final color = item['color'] as Color? ?? const Color(0xFF2A2A1A);
    final mediaUrl =
        ApiClient.resolveMediaUrl(item['mediaUrl'] as String?);
    final showImage = _ContentCard.isImageUrl(mediaUrl);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Text(_kindLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: showImage ? 220 : 160,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: showImage
                          ? GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _FullscreenImage(url: mediaUrl!),
                                ),
                              ),
                              child: Image.network(
                                mediaUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                    child: Text(emoji,
                                        style:
                                            const TextStyle(fontSize: 64))),
                              ),
                            )
                          : Center(
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 64))),
                    ),
                    const SizedBox(height: 18),
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Text(_kindLabel,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (date.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.white38, size: 12),
                        const SizedBox(width: 4),
                        Text(date,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ]),
                    const SizedBox(height: 18),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 14),
                    Text(
                      description.isEmpty
                          ? 'No description was added for this item.'
                          : description,
                      style: TextStyle(
                          color: description.isEmpty
                              ? Colors.white38
                              : Colors.white70,
                          fontSize: 14,
                          height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  static bool isImageUrl(String? url) =>
      url != null &&
      RegExp(r'\.(png|jpe?g|webp|gif)(\?|$)', caseSensitive: false)
          .hasMatch(url);

  @override
  Widget build(BuildContext context) {
    final mediaUrl =
        ApiClient.resolveMediaUrl(item['mediaUrl'] as String?);
    final showImage = isImageUrl(mediaUrl);
    return Container(
      decoration: BoxDecoration(
        color: item['color'] as Color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        if (showImage)
          Positioned.fill(
            child: Image.network(
              mediaUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (context, child, p) => p == null
                  ? child
                  : const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white24))),
            ),
          ),
        if ((item['kind'] as String? ?? '') == 'VIDEO')
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 18),
            ),
          ),
        if ((item['duration'] as String? ?? '').isNotEmpty)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(item['duration'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        if (!showImage)
          Center(
              child: Text(item['emoji'] as String,
                  style: const TextStyle(fontSize: 48))),
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
