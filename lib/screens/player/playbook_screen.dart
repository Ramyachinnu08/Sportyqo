import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/sportyqo_api.dart';
import '../shared/app_toast.dart';
import '../shared/avatar_picker.dart';
import '../shared/notifications_sheet.dart';
import 'profile_screen.dart';

/// Playbook (design p.7): the player's own highlight page. Profile block
/// with Qo Score + rank, About, social stats, Playing / Certificates /
/// Team / Trophies tabs and an "Add New" uploader. Data: GET /me,
/// GET /players/:id/profile, /performance, /playbook, /teams/:id/roster.
class PlaybookScreen extends StatefulWidget {
  const PlaybookScreen({super.key});

  @override
  State<PlaybookScreen> createState() => _PlaybookScreenState();
}

class _PlaybookScreenState extends State<PlaybookScreen> {
  bool _loading = true;
  int _tab = 0;

  Map<String, dynamic>? _me;
  int _followers = 0;
  int _following = 0;
  int _leagues = 0;
  int _matches = 0;
  Map<String, dynamic>? _ranking;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _roster = [];
  String? _teamName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        SportyQoApi.me(),
        SportyQoApi.playerProfile(),
        SportyQoApi.playerPerformance(),
        SportyQoApi.playbook(),
        SportyQoApi.myLeagues(),
        SportyQoApi.playerHome(),
      ]);
      if (!mounted) return;
      final me = results[0] as Map<String, dynamic>;
      final profile = results[1] as Map<String, dynamic>;
      final perf = results[2] as Map<String, dynamic>;
      final items =
          (results[3] as List<dynamic>).cast<Map<String, dynamic>>();
      final leagues = results[4] as List<dynamic>;
      final home = results[5] as Map<String, dynamic>;

      final journey = (perf['qoJourney'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      setState(() {
        _me = me;
        _followers = (profile['followers'] as num?)?.toInt() ?? 0;
        _following = (profile['following'] as num?)?.toInt() ?? 0;
        _ranking = perf['ranking'] as Map<String, dynamic>?;
        _items = items;
        _leagues = leagues.length;
        _matches = journey.fold<int>(
            0, (sum, j) => sum + ((j['matchesPlayed'] as num?)?.toInt() ?? 0));
        _loading = false;
      });

      // Squad for the Team tab (active team from the home payload).
      final team = ((home['activeLeague'] as Map<String, dynamic>?)?['team'])
          as Map<String, dynamic>?;
      if (team != null) {
        final r = await SportyQoApi.teamRoster(team['id'] as String)
            as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _teamName = (r['team'] as Map<String, dynamic>?)?['name'];
          _roster = (r['roster'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: const Color(0xFF16162E),
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    _header(),
                    const SizedBox(height: 16),
                    _profileBlock(),
                    const SizedBox(height: 14),
                    _aboutCard(),
                    const SizedBox(height: 14),
                    _statsRow(),
                    const SizedBox(height: 16),
                    _tabs(),
                    const SizedBox(height: 14),
                    ..._tabContent(),
                    const SizedBox(height: 16),
                    _addNewCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _header() => Row(children: [
        const Expanded(
          child: Text('Playbook',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ),
        GestureDetector(
          onTap: () => showNotificationsSheet(context),
          child: const Icon(Icons.notifications_none_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: const Icon(Icons.settings_outlined,
              color: Colors.white, size: 22),
        ),
      ]);

  // ── Profile block: avatar+camera, identity rows, Qo Score card ──
  Widget _profileBlock() {
    final me = _me ?? const {};
    final name = me['fullName'] as String? ?? 'Player';
    final sport = (me['sport'] as Map<String, dynamic>?)?['name'] as String?;
    final dob = me['dob'] as String?;
    final dobStr = () {
      final d = DateTime.tryParse(dob ?? '');
      if (d == null) return null;
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    }();

    Widget infoRow(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            Icon(icon, size: 13, color: Colors.white54),
            const SizedBox(width: 6),
            Flexible(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ]),
        );

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        AvatarCircle(
          avatarUrl: me['avatarUrl'] as String?,
          name: name,
          size: 92,
          borderColor: AppColors.primary,
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: _changePhoto,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B38),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
      ]),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ),
            if (me['isVerified'] == true) ...[
              const SizedBox(width: 5),
              const Icon(Icons.verified,
                  color: AppColors.primaryLight, size: 15),
            ],
          ]),
          if (sport != null)
            Text(sport,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12.5)),
          const SizedBox(height: 4),
          if (dobStr != null) infoRow(Icons.calendar_today_outlined, dobStr),
          if ((me['location'] as String?)?.isNotEmpty == true)
            infoRow(Icons.location_on_outlined, me['location'] as String),
          if ((me['schoolAcademy'] as String?)?.isNotEmpty == true)
            infoRow(Icons.school_outlined, me['schoolAcademy'] as String),
        ]),
      ),
      const SizedBox(width: 8),
      // Qo Score mini-card with rank
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: Column(children: [
          const Text('Qo Score',
              style: TextStyle(
                  color: AppColors.primaryLight, fontSize: 9.5)),
          Text('${(me['qoScore'] as num?)?.toInt() ?? 0}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          if (_ranking != null) ...[
            const SizedBox(height: 2),
            const Text('Rank',
                style: TextStyle(color: Colors.white38, fontSize: 9)),
            Text('#${_ranking!['position']}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            Text('of ${_ranking!['totalPlayers']}',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 8.5)),
          ],
        ]),
      ),
    ]);
  }

  Widget _aboutCard() {
    final bio = (_me?['bio'] as String?) ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('About',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          bio.isEmpty
              ? 'No bio yet — add one from your Profile.'
              : bio,
          style: TextStyle(
              color: bio.isEmpty ? Colors.white38 : Colors.white70,
              fontSize: 12.5,
              height: 1.5),
        ),
      ]),
    );
  }

  Widget _statsRow() {
    Widget stat(String value, String label) => Expanded(
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        );
    return Row(children: [
      stat('$_followers', 'Followers'),
      stat('$_following', 'Following'),
      stat('$_leagues', 'Leagues'),
      stat('$_matches', 'Matches'),
      ElevatedButton(
        onPressed: () {
          final code = _me?['playerId'] as String?;
          if (code == null) return;
          Clipboard.setData(ClipboardData(
              text:
                  'Check out my SportyQo profile! Player ID: $code'));
          AppToast.success(context, 'Profile link copied! 📋');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('Share',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700)),
      ),
    ]);
  }

  // ── Tabs ──
  static const _tabDefs = [
    (icon: Icons.sports_cricket_outlined, label: 'Playing'),
    (icon: Icons.workspace_premium_outlined, label: 'Certificates'),
    (icon: Icons.groups_outlined, label: 'Team'),
    (icon: Icons.emoji_events_outlined, label: 'Trophies'),
  ];

  Widget _tabs() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabDefs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _tab == i
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(children: [
                      Icon(_tabDefs[i].icon,
                          size: 17,
                          color: _tab == i
                              ? AppColors.primaryLight
                              : Colors.white54),
                      const SizedBox(height: 3),
                      Text(_tabDefs[i].label,
                          style: TextStyle(
                              color: _tab == i
                                  ? AppColors.primaryLight
                                  : Colors.white54,
                              fontSize: 10.5,
                              fontWeight: _tab == i
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      );

  List<Widget> _tabContent() {
    switch (_tab) {
      case 0:
        return _playingGrid();
      case 1:
        return [
          _emptyTab('📜',
              'No certificates yet.\nCertificates you earn will appear here.'),
        ];
      case 2:
        return _teamTab();
      default:
        return [
          _emptyTab('🏆',
              'No trophies yet.\nWin matches and tournaments to collect them.'),
        ];
    }
  }

  Widget _emptyTab(String emoji, String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 34),
        decoration: BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 12.5, height: 1.5)),
        ]),
      );

  // ── Playing: media grid ──
  List<Widget> _playingGrid() {
    final media =
        _items.where((i) => (i['mediaUrl'] as String?) != null).toList();
    if (media.isEmpty) {
      return [
        _emptyTab('🎬',
            'No highlights yet.\nUpload your match videos and photos below.'),
      ];
    }
    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.86,
        ),
        itemCount: media.length,
        itemBuilder: (_, i) => _mediaCard(media[i]),
      ),
    ];
  }

  Widget _mediaCard(Map<String, dynamic> item) {
    final isVideo = (item['kind'] as String?) == 'VIDEO';
    final url = ApiClient.resolveMediaUrl(item['mediaUrl'] as String?);
    final dt =
        DateTime.tryParse(item['createdAt'] as String? ?? '')?.toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr =
        dt == null ? '' : '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    final mine = item['isMine'] == true;

    return GestureDetector(
      onTap: () => _openMedia(item, isVideo, url),
      onLongPress: mine ? () => _confirmDelete(item) : null,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
          color: const Color(0xFF16162E),
        ),
        child: Stack(fit: StackFit.expand, children: [
          if (!isVideo && url != null)
            Image.network(url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox()),
          if (isVideo)
            const Center(
                child: Icon(Icons.play_circle_outline,
                    color: Colors.white70, size: 42)),
          // bottom overlay with title / stat / date
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85)
                  ],
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] as String? ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                    Row(children: [
                      Expanded(
                        child: Text(
                            item['description'] as String? ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10.5)),
                      ),
                      Text(dateStr,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 9.5)),
                    ]),
                  ]),
            ),
          ),
          if (isVideo)
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 18),
            ),
        ]),
      ),
    );
  }

  void _openMedia(Map<String, dynamic> item, bool isVideo, String? url) {
    if (isVideo) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => _VideoPlayerScreen(item: item)));
    } else if (url != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) => GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Center(child: Image.network(url)),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF14142B),
        title: const Text('Delete this item?',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(item['title'] as String? ?? '',
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await SportyQoApi.deletePlaybookItem(item['id'] as String);
      await _load();
      if (!mounted) return;
      AppToast.success(context, 'Deleted');
    } on ApiException catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.message);
    }
  }

  // ── Team tab ──
  List<Widget> _teamTab() {
    if (_roster.isEmpty) {
      return [
        _emptyTab('👥',
            'You are not on a team yet.\nJoin a league and pick a team to see your squad.'),
      ];
    }
    return [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_teamName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_teamName!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          for (var i = 0; i < _roster.length; i++) ...[
            _rosterRow(_roster[i]),
            if (i != _roster.length - 1)
              const Divider(color: Colors.white10, height: 18),
          ],
        ]),
      ),
    ];
  }

  Widget _rosterRow(Map<String, dynamic> r) => Row(children: [
        AvatarCircle(
          avatarUrl: r['avatarUrl'] as String?,
          name: r['fullName'] as String? ?? 'P',
          size: 36,
          borderWidth: 1.5,
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(r['fullName'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              if (r['isCaptain'] == true)
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('©',
                      style: TextStyle(
                          color: AppColors.primaryLight, fontSize: 12)),
                ),
            ]),
            Text(
              [
                if ((r['position'] as String?)?.isNotEmpty == true)
                  r['position'] as String,
                if (r['jerseyNo'] != null) '#${r['jerseyNo']}',
              ].join(' • '),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ]),
        ),
        Text('${(r['qoScore'] as num?)?.toInt() ?? 0} Qo',
            style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ]);

  // ── Add New (design bottom card) ──
  Widget _addNewCard() => GestureDetector(
        onTap: _showUploadSheet,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Add New',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('Add match videos, highlights and performances',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 11.5)),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ]),
        ),
      );

  Future<void> _changePhoto() async {
    final url = await pickAndUploadAvatar(context, ImageSource.gallery,
        accent: AppColors.primary);
    if (url != null && mounted) {
      setState(() => _me = {...?_me, 'avatarUrl': url});
    }
  }

  // Upload sheet: pick photo/video, title + description, live progress.
  void _showUploadSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    XFile? media;
    bool isVideo = false;
    bool uploading = false;
    final progress = ValueNotifier<double>(0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14142B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          Future<void> pick(bool video, ImageSource source) async {
            try {
              final picker = ImagePicker();
              final f = video
                  ? await picker.pickVideo(
                      source: source,
                      maxDuration: const Duration(minutes: 3))
                  : await picker.pickImage(
                      source: source, maxWidth: 1920, imageQuality: 88);
              if (f != null) {
                setSheet(() {
                  media = f;
                  isVideo = video;
                });
              }
            } catch (_) {
              AppToast.error(sheetCtx,
                  'Could not open the camera/gallery. Check the app permissions in Settings.');
            }
          }

          Widget pickBtn(IconData icon, String label, VoidCallback onTap) =>
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: uploading ? null : onTap,
                  icon: Icon(icon, size: 16, color: AppColors.primaryLight),
                  label: Text(label,
                      style: const TextStyle(
                          color: AppColors.primaryLight, fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              );

          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24,
                24 + MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add to Playbook',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  enabled: !uploading,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Title (e.g. Century vs DSO Academy)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  enabled: !uploading,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Highlight (e.g. 125 Runs) — optional'),
                ),
                const SizedBox(height: 12),
                if (media == null)
                  Row(children: [
                    pickBtn(Icons.photo_outlined, 'Photo',
                        () => pick(false, ImageSource.gallery)),
                    const SizedBox(width: 8),
                    pickBtn(Icons.camera_alt_outlined, 'Camera',
                        () => pick(false, ImageSource.camera)),
                    const SizedBox(width: 8),
                    pickBtn(Icons.videocam_outlined, 'Video',
                        () => pick(true, ImageSource.gallery)),
                  ])
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B38),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Icon(isVideo ? Icons.videocam : Icons.photo,
                          size: 16, color: AppColors.primaryLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(media!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ),
                      if (!uploading)
                        GestureDetector(
                          onTap: () => setSheet(() => media = null),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white38),
                        ),
                    ]),
                  ),
                if (uploading) ...[
                  const SizedBox(height: 14),
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder: (_, v, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: v > 0 ? v : null,
                        minHeight: 6,
                        backgroundColor: Colors.white10,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: uploading
                        ? null
                        : () async {
                            final title = titleCtrl.text.trim();
                            if (title.length < 3) {
                              AppToast.error(sheetCtx,
                                  'Give it a title (3+ characters)');
                              return;
                            }
                            if (media == null) {
                              AppToast.error(sheetCtx,
                                  'Attach a photo or video first');
                              return;
                            }
                            setSheet(() => uploading = true);
                            try {
                              await SportyQoApi.uploadPlaybookMedia(
                                filePath: media!.path,
                                title: title,
                                description: descCtrl.text.trim(),
                                kind: isVideo ? 'VIDEO' : 'DRILL',
                                onProgress: (v) => progress.value = v,
                              );
                              if (!sheetCtx.mounted) return;
                              Navigator.pop(sheetCtx);
                              await _load();
                              if (!mounted) return;
                              AppToast.success(
                                  context,
                                  isVideo
                                      ? 'Video uploaded ✅'
                                      : 'Photo uploaded ✅');
                            } on ApiException catch (e) {
                              if (!sheetCtx.mounted) return;
                              setSheet(() => uploading = false);
                              AppToast.error(
                                  sheetCtx,
                                  e.code == 'NETWORK'
                                      ? 'Upload failed — check your connection and try again.'
                                      : e.message);
                            } catch (_) {
                              if (!sheetCtx.mounted) return;
                              setSheet(() => uploading = false);
                              AppToast.error(sheetCtx,
                                  'Upload failed — please try again.');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(uploading ? 'Uploading…' : 'Upload',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                if (!uploading)
                  Center(
                    child: TextButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white38))),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1B1B38),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      );
}

// ── Video Player (unchanged, plays the item's real mediaUrl) ──────────
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
