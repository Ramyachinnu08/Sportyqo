import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/sportyqo_api.dart';
import '../shared/app_toast.dart';
import '../shared/avatar_picker.dart';
import '../shared/notifications_sheet.dart';
import 'coach_profile_screen.dart';

/// Coach Playbook (design p.7): the coach's own page — profile block
/// with a Players Trained mini-card, About, stats row, Recommend Players
/// button, Training / Teams / Achievements / Events tabs and Add New.
/// Data: /me, /coach/dashboard, /coach/certifications, /playbook,
/// /leagues/:id/teams and /matches?status=SCHEDULED.
class CoachPlaybookScreen extends StatefulWidget {
  const CoachPlaybookScreen({super.key});

  @override
  State<CoachPlaybookScreen> createState() => _CoachPlaybookScreenState();
}

class _CoachPlaybookScreenState extends State<CoachPlaybookScreen> {
  bool _loading = true;
  int _tab = 0;

  Map<String, dynamic>? _me;
  Map<String, dynamic> _counts = const {};
  List<Map<String, dynamic>> _certs = [];
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _teams = []; // {team fields + leagueName}
  List<Map<String, dynamic>> _events = []; // upcoming matches
  List<Map<String, dynamic>> _recommendedPlayers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        SportyQoApi.me(),
        SportyQoApi.coachDashboard(),
        SportyQoApi.coachCertifications(),
        SportyQoApi.playbook(),
      ]);
      if (!mounted) return;
      final dash = results[1] as Map<String, dynamic>;
      setState(() {
        _me = results[0] as Map<String, dynamic>;
        _counts = dash['counts'] as Map<String, dynamic>? ?? const {};
        _certs = (results[2] as List<dynamic>).cast<Map<String, dynamic>>();
        _items = (results[3] as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });

      // Teams across all owned leagues (for the Teams tab)
      final leagues = (dash['leagues'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      final teams = <Map<String, dynamic>>[];
      for (final l in leagues) {
        try {
          final ts = (await SportyQoApi.leagueTeams(l['id'] as String))
              .cast<Map<String, dynamic>>();
          for (final t in ts) {
            teams.add({...t, 'leagueName': l['name']});
          }
        } catch (_) {}
      }
      if (mounted) setState(() => _teams = teams);

      // Upcoming matches (Events tab)
      try {
        final ms = (await SportyQoApi.matches(status: 'SCHEDULED'))
            .cast<Map<String, dynamic>>();
        if (mounted) setState(() => _events = ms);
      } catch (_) {}

      // Top players for the Recommend sheet (league players first,
      // community leaderboard as fallback so the sheet is never empty).
      try {
        var players = (await SportyQoApi.searchPlayers())
            .cast<Map<String, dynamic>>();
        if (players.isEmpty) {
          players = (await SportyQoApi.discoverPlayers())
              .cast<Map<String, dynamic>>();
        }
        players.sort((a, b) => ((b['qoScore'] as num?) ?? 0)
            .compareTo((a['qoScore'] as num?) ?? 0));
        if (mounted) {
          setState(() {
            _recommendedPlayers = players
                .take(3)
                .map((r) => {
                      'id': r['id'],
                      'name': r['fullName'] ?? '',
                      'role': r['teamName'] ??
                          ((r['academy'] as String?)?.isNotEmpty == true
                              ? r['academy']
                              : (r['sport'] as String? ?? 'Player')),
                      'emoji': r['sportEmoji'] ?? '🏅',
                      'pts': (r['qoScore'] as num?)?.toInt() ?? 0,
                      'recommended': r['isRecommended'] == true,
                    })
                .toList();
          });
        }
      } catch (_) {}
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
                    const SizedBox(height: 14),
                    _recommendButton(),
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
          child: Text('Coach Playbook',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
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
              MaterialPageRoute(builder: (_) => const CoachProfileScreen())),
          child: const Icon(Icons.settings_outlined,
              color: Colors.white, size: 22),
        ),
      ]);

  // ── Profile block ──
  Widget _profileBlock() {
    final me = _me ?? const {};
    final name = me['fullName'] as String? ?? 'Coach';
    final years = (me['yearsExperience'] as num?)?.toInt();
    final firstCert = _certs.isNotEmpty ? _certs.first : null;

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
            onTap: () async {
              final url = await pickAndUploadAvatar(
                  context, ImageSource.gallery,
                  accent: AppColors.primary);
              if (url != null && mounted) {
                setState(() => _me = {...?_me, 'avatarUrl': url});
              }
            },
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
            if (me['isVerifiedCoach'] == true) ...[
              const SizedBox(width: 5),
              const Icon(Icons.verified,
                  color: AppColors.primaryLight, size: 15),
            ],
          ]),
          if ((me['title'] as String?)?.isNotEmpty == true)
            Text(me['title'] as String,
                style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          if ((me['academy'] as String?)?.isNotEmpty == true)
            infoRow(Icons.shield_outlined, me['academy'] as String),
          if (years != null)
            infoRow(Icons.calendar_today_outlined,
                '$years+ Years Experience'),
          if ((me['location'] as String?)?.isNotEmpty == true)
            infoRow(Icons.location_on_outlined, me['location'] as String),
          if (firstCert != null)
            infoRow(Icons.workspace_premium_outlined,
                firstCert['title'] as String? ?? ''),
          if (me['isVerifiedCoach'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('✓ Verified Coach',
                    style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ),
      const SizedBox(width: 8),
      // Players Trained mini-card
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: Column(children: [
          const Text('Players',
              style:
                  TextStyle(color: AppColors.primaryLight, fontSize: 9.5)),
          Text('${(_counts['players'] as num?)?.toInt() ?? 0}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const Text('Trained',
              style:
                  TextStyle(color: AppColors.primaryLight, fontSize: 9.5)),
          const SizedBox(height: 4),
          Text('${(_counts['leagues'] as num?)?.toInt() ?? 0} Leagues',
              style: const TextStyle(color: Colors.white38, fontSize: 9)),
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
          bio.isEmpty ? 'No bio yet — add one from your Profile.' : bio,
          style: TextStyle(
              color: bio.isEmpty ? Colors.white38 : Colors.white70,
              fontSize: 12.5,
              height: 1.5),
        ),
      ]),
    );
  }

  Widget _statsRow() {
    final years = (_me?['yearsExperience'] as num?)?.toInt();
    Widget stat(IconData icon, String value, String label) => Expanded(
          child: Column(children: [
            Icon(icon, size: 17, color: AppColors.primaryLight),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 10)),
          ]),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        stat(Icons.people_outline,
            '${(_counts['players'] as num?)?.toInt() ?? 0}', 'Players\nTrained'),
        stat(Icons.emoji_events_outlined,
            '${(_counts['leagues'] as num?)?.toInt() ?? 0}', 'Leagues'),
        stat(Icons.workspace_premium_outlined, '${_certs.length}',
            'Certificates'),
        stat(Icons.calendar_today_outlined,
            years == null ? '—' : '$years+', 'Years\nExperience'),
      ]),
    );
  }

  Widget _recommendButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showRecommendPlayers(context),
          icon: const Icon(Icons.add_circle_outline,
              color: Colors.white, size: 18),
          label: const Text('Recommend Players',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
        ),
      );

  // ── Tabs ──
  static const _tabDefs = [
    (icon: Icons.directions_run, label: 'Training'),
    (icon: Icons.groups_outlined, label: 'Teams'),
    (icon: Icons.workspace_premium_outlined, label: 'Achievements'),
    (icon: Icons.campaign_outlined, label: 'Events'),
  ];

  Widget _tabs() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(children: [
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
                            fontSize: 10,
                            fontWeight: _tab == i
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ]),
                ),
              ),
            ),
        ]),
      );

  List<Widget> _tabContent() {
    switch (_tab) {
      case 0:
        return _trainingGrid();
      case 1:
        return _teamsTab();
      case 2:
        return _achievementsTab();
      default:
        return _eventsTab();
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

  // ── Training tab: media grid ──
  List<Widget> _trainingGrid() {
    final media =
        _items.where((i) => (i['mediaUrl'] as String?) != null).toList();
    if (media.isEmpty) {
      return [
        _emptyTab('🎬',
            'No training content yet.\nUpload session photos and videos below.'),
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
      onTap: () {
        if (isVideo) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => _VideoPlayerScreen(item: item)));
        } else if (url != null) {
          showDialog(
            context: context,
            barrierColor: Colors.black87,
            builder: (_) => GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                  child: Center(child: Image.network(url))),
            ),
          );
        }
      },
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
                    Text(dateStr,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10)),
                  ]),
            ),
          ),
        ]),
      ),
    );
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

  // ── Teams tab ──
  List<Widget> _teamsTab() {
    if (_teams.isEmpty) {
      return [
        _emptyTab('👥',
            'No teams yet.\nCreate a league to set up your teams.'),
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
        child: Column(children: [
          for (var i = 0; i < _teams.length; i++) ...[
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Text(_teams[i]['icon'] as String? ?? '🛡️',
                        style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_teams[i]['name'] as String? ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700)),
                      Text(_teams[i]['leagueName'] as String? ?? '',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ]),
              ),
              Text(
                  '${(_teams[i]['rosterCount'] as num?)?.toInt() ?? 0} players',
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600)),
            ]),
            if (i != _teams.length - 1)
              const Divider(color: Colors.white10, height: 20),
          ],
        ]),
      ),
    ];
  }

  // ── Achievements tab: real certifications ──
  List<Widget> _achievementsTab() {
    if (_certs.isEmpty) {
      return [
        _emptyTab('🏅',
            'No certifications yet.\nGet certified from the Home tab to build player trust.'),
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
        child: Column(children: [
          for (var i = 0; i < _certs.length; i++) ...[
            Row(children: [
              const Icon(Icons.workspace_premium_outlined,
                  color: AppColors.primaryLight, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_certs[i]['title'] as String? ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700)),
                      if ((_certs[i]['issuer'] as String?)?.isNotEmpty ==
                          true)
                        Text(_certs[i]['issuer'] as String,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                    ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ((_certs[i]['status'] as String?) == 'APPROVED'
                          ? const Color(0xFF00C853)
                          : Colors.amber)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    (_certs[i]['status'] as String? ?? 'PENDING')
                        .toLowerCase(),
                    style: TextStyle(
                        color: (_certs[i]['status'] as String?) ==
                                'APPROVED'
                            ? const Color(0xFF00C853)
                            : Colors.amber,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
            if (i != _certs.length - 1)
              const Divider(color: Colors.white10, height: 20),
          ],
        ]),
      ),
    ];
  }

  // ── Events tab: upcoming matches ──
  List<Widget> _eventsTab() {
    if (_events.isEmpty) {
      return [
        _emptyTab('📅',
            'No upcoming events.\nSchedule matches from your league dashboard.'),
      ];
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(children: [
          for (var i = 0; i < _events.length; i++) ...[
            Builder(builder: (_) {
              final m = _events[i];
              final home =
                  m['homeTeam'] as Map<String, dynamic>? ?? const {};
              final away =
                  m['awayTeam'] as Map<String, dynamic>? ?? const {};
              final dt = DateTime.tryParse(
                      m['scheduledAt'] as String? ?? '')
                  ?.toLocal();
              final dateStr = dt == null
                  ? ''
                  : '${dt.day} ${months[dt.month - 1]} ${dt.year}';
              return Row(children: [
                const Icon(Icons.sports_cricket_outlined,
                    color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${home['name']} vs ${away['name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        Text(
                            [
                              m['leagueName'] as String? ?? '',
                              if (dateStr.isNotEmpty) dateStr,
                              if ((m['venue'] as String?)?.isNotEmpty ==
                                  true)
                                m['venue'] as String,
                            ].where((s) => s.isNotEmpty).join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ]),
                ),
              ]);
            }),
            if (i != _events.length - 1)
              const Divider(color: Colors.white10, height: 20),
          ],
        ]),
      ),
    ];
  }

  Widget _addNewCard() => GestureDetector(
        onTap: () => _showUploadDialog(context),
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
                    Text('Add training photos, videos and more',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 11.5)),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ]),
        ),
      );

  void _showRecommendPlayers(BuildContext context) {
    final sending = <String>{};
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
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
              if (_recommendedPlayers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No players to recommend yet.',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 13)),
                  ),
                ),
              ..._recommendedPlayers.map((p) {
                final id = p['id'] as String?;
                final sent = p['recommended'] == true;
                final busy = id != null && sending.contains(id);
                return Container(
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
                      onTap: (id == null || sent || busy)
                          ? null
                          : () async {
                              setSheetState(() => sending.add(id));
                              try {
                                await SportyQoApi.recommendPlayer(id);
                                if (!sheetContext.mounted) return;
                                setSheetState(() {
                                  sending.remove(id);
                                  p['recommended'] = true;
                                });
                                AppToast.success(sheetContext,
                                    "${p['name']} recommended! ✅");
                              } on ApiException catch (e) {
                                if (!sheetContext.mounted) return;
                                setSheetState(() => sending.remove(id));
                                AppToast.error(sheetContext, e.message);
                              } catch (_) {
                                if (!sheetContext.mounted) return;
                                setSheetState(() => sending.remove(id));
                                AppToast.error(sheetContext,
                                    'Could not send — try again.');
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: sent
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: sent
                              ? Border.all(
                                  color:
                                      AppColors.primary.withOpacity(0.5))
                              : null,
                        ),
                        child: busy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(sent ? 'Sent ✓' : 'Send',
                                style: TextStyle(
                                    color: sent
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                      ),
                    ),
                  ]),
                );
              }),
              const SizedBox(height: 8),
              TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Close',
                      style: TextStyle(color: Colors.white38))),
            ],
          ),
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

  /// Add-content sheet: title, description and kind — plus an optional
  /// photo/video attachment that is uploaded to POST /playbook as
  /// multipart media (previously the coach sheet was text-only, so
  /// coaches could not upload media at all).
  void _showUploadDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String kind = 'DRILL';
    XFile? media;
    bool isVideo = false;
    bool uploading = false;
    final progress = ValueNotifier<double>(0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> pick({required bool video}) async {
            try {
              final picker = ImagePicker();
              final picked = video
                  ? await picker.pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: const Duration(minutes: 3))
                  : await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      imageQuality: 88);
              if (picked != null) {
                setSheetState(() {
                  media = picked;
                  isVideo = video;
                  if (video) kind = 'VIDEO';
                });
              }
            } catch (_) {
              AppToast.error(sheetContext,
                  'Could not open the gallery. Check the app permissions in Settings.');
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24,
                24 + MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add New Content',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  enabled: !uploading,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Title',
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
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final k in ['DRILL', 'STRATEGY', 'VIDEO', 'NOTE'])
                      ChoiceChip(
                        label: Text(k[0] + k.substring(1).toLowerCase()),
                        selected: kind == k,
                        selectedColor: AppColors.primary.withOpacity(0.3),
                        backgroundColor: const Color(0xFF1A1A1A),
                        labelStyle: TextStyle(
                            color: kind == k
                                ? AppColors.primary
                                : Colors.white54,
                            fontSize: 12),
                        onSelected: uploading
                            ? null
                            : (_) => setSheetState(() => kind = k),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Media attachment ──
                if (media == null)
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            uploading ? null : () => pick(video: false),
                        icon: const Icon(Icons.photo_outlined,
                            size: 18, color: AppColors.primary),
                        label: const Text('Add Photo',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.primary.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            uploading ? null : () => pick(video: true),
                        icon: const Icon(Icons.videocam_outlined,
                            size: 18, color: AppColors.primary),
                        label: const Text('Add Video',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.primary.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ])
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Icon(isVideo ? Icons.videocam : Icons.photo,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          media!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12.5),
                        ),
                      ),
                      if (!uploading)
                        GestureDetector(
                          onTap: () => setSheetState(() {
                            media = null;
                            isVideo = false;
                          }),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.white38),
                        ),
                    ]),
                  ),

                if (uploading) ...[
                  const SizedBox(height: 14),
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder: (_, v, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: v > 0 ? v : null,
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          v >= 1.0
                              ? 'Processing…'
                              : 'Uploading… ${(v * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11.5),
                        ),
                      ],
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
                              AppToast.error(sheetContext,
                                  'Give it a title (3+ characters)');
                              return;
                            }
                            // Text-only note — no media attached.
                            if (media == null) {
                              Navigator.pop(sheetContext);
                              try {
                                await SportyQoApi.createPlaybookItem(
                                    title: title,
                                    description: descCtrl.text.trim(),
                                    kind: kind);
                                await _load();
                                if (!context.mounted) return;
                                AppToast.success(
                                    context, 'Content added ✅');
                              } on ApiException catch (e) {
                                if (!context.mounted) return;
                                AppToast.error(context, e.message);
                              } catch (_) {
                                if (!context.mounted) return;
                                AppToast.error(
                                    context, 'Could not save — try again');
                              }
                              return;
                            }
                            // Media upload with progress.
                            setSheetState(() => uploading = true);
                            try {
                              await SportyQoApi.uploadPlaybookMedia(
                                filePath: media!.path,
                                title: title,
                                description: descCtrl.text.trim(),
                                kind: isVideo ? 'VIDEO' : kind,
                                onProgress: (v) => progress.value = v,
                              );
                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                              await _load();
                              if (!context.mounted) return;
                              AppToast.success(
                                  context,
                                  isVideo
                                      ? 'Video uploaded ✅'
                                      : 'Photo uploaded ✅');
                            } on ApiException catch (e) {
                              if (!sheetContext.mounted) return;
                              setSheetState(() => uploading = false);
                              AppToast.error(
                                  sheetContext,
                                  e.code == 'NETWORK'
                                      ? 'Upload failed — check your connection and try again.'
                                      : e.message);
                            } catch (_) {
                              if (!sheetContext.mounted) return;
                              setSheetState(() => uploading = false);
                              AppToast.error(sheetContext,
                                  'Upload failed — please try again.');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                        uploading
                            ? 'Uploading…'
                            : (media == null ? 'Save' : 'Upload'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                if (!uploading)
                  TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Center(
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.white38)))),
              ],
            ),
          );
        },
      ),
    );
  }

}

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
