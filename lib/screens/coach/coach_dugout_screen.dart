import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

class CoachDugoutScreen extends StatefulWidget {
  const CoachDugoutScreen({super.key});

  @override
  State<CoachDugoutScreen> createState() =>
      _CoachDugoutScreenState();
}

class _CoachDugoutScreenState extends State<CoachDugoutScreen> {
  String _selectedTab = 'Players';
  String _searchQuery = '';
  final TextEditingController _searchController =
  TextEditingController();

  // Players in this coach's leagues, from GET /players.
  List<Map<String, dynamic>> _players = [];
  bool _loadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _loadUpdates();
  }

  Future<void> _loadPlayers() async {
    try {
      final data = await SportyQoApi.searchPlayers();
      if (!mounted) return;
      setState(() {
        _players = data.cast<Map<String, dynamic>>().map((r) => {
              'id': r['id'],
              'name': r['fullName'] ?? 'Player',
              'role': r['position'] ?? 'Player',
              'pts': r['qoScore'] ?? 0,
              'emoji': r['sportEmoji'] ?? '🏅',
              'following': r['isFollowing'] == true,
              'followers': '${r['followers'] ?? 0}',
              'team': r['teamName'] ?? 'No team yet',
            }).toList();
        _loadingPlayers = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPlayers = false);
    }
  }

  static String _relTime(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  // Latest message from each dugout thread (real chat activity).
  List<Map<String, dynamic>> _updates = [];
  bool _loadingUpdates = true;

  Future<void> _loadUpdates() async {
    try {
      final threads = await SportyQoApi.dugoutThreads();
      if (!mounted) return;
      setState(() {
        _updates = threads
            .cast<Map<String, dynamic>>()
            .where((t) => t['lastMessage'] != null)
            .map((t) {
          final lm = t['lastMessage'] as Map<String, dynamic>;
          return {
            'name': lm['senderName'] ?? 'Member',
            'time': _relTime(lm['at'] as String?),
            'content': lm['body'] ?? '',
            'thread': t['title'] ?? 'Dugout',
          };
        }).toList();
        _loadingUpdates = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingUpdates = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPlayers {
    if (_searchQuery.isEmpty) return _players;
    return _players
        .where((p) => p['name']
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                    fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search players by name...',
                  hintStyle: const TextStyle(
                      color: AppColors.textGrey, fontSize: 12),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textGrey, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close,
                        color: AppColors.textGrey, size: 18),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                '${_filteredPlayers.length} result${_filteredPlayers.length != 1 ? 's' : ''} for "$_searchQuery"',
                style: const TextStyle(
                    color: Color(0xFF00C853),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),

          const SizedBox(height: 12),

          // Tabs
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _Tab(
                    label: 'Players',
                    isActive: _selectedTab == 'Players',
                    onTap: () =>
                        setState(() => _selectedTab = 'Players')),
                const SizedBox(width: 10),
                _Tab(
                    label: 'Follow Players',
                    isActive: _selectedTab == 'Follow Players',
                    onTap: () =>
                        setState(() => _selectedTab = 'Follow Players')),
                const SizedBox(width: 10),
                _Tab(
                    label: 'Team Updates',
                    isActive: _selectedTab == 'Team Updates',
                    onTap: () =>
                        setState(() => _selectedTab = 'Team Updates')),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _selectedTab == 'Players'
                ? _buildPlayers(isDark)
                : _selectedTab == 'Follow Players'
                ? _buildFollowPlayers(isDark)
                : _buildTeamUpdates(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayers(bool isDark) {
    if (_loadingPlayers) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_players.isEmpty) {
      return const Center(
          child: Text('No players in your leagues yet',
              style: TextStyle(color: Colors.white54, fontSize: 14)));
    }
    if (_filteredPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No players found for\n"$_searchQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPlayers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = _filteredPlayers[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _PlayerProfileScreen(player: p),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text(p['emoji'],
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textDark)),
                      Text(p['role'],
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 12)),
                      Text(p['team'],
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${p['pts']} pts',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        color: Colors.white24, size: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowPlayers(bool isDark) {
    if (_loadingPlayers) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_players.isEmpty) {
      return const Center(
          child: Text('No players in your leagues yet',
              style: TextStyle(color: Colors.white54, fontSize: 14)));
    }
    final displayList = _searchQuery.isEmpty
        ? _players
        : _players
        .where((p) => p['name']
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No players found for\n"$_searchQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: displayList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = displayList[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _PlayerProfileScreen(player: p),
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setLocalState) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text(p['emoji'],
                            style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDark)),
                        Text('${p['followers']} followers',
                            style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setLocalState(
                            () {
                          p['following'] = !p['following'];
                          final id = p['id'] as String?;
                          if (id != null) {
                            (p['following'] as bool)
                                ? SportyQoApi.followPlayer(id)
                                : SportyQoApi.unfollowPlayer(id);
                          }
                        }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: p['following']
                            ? const Color(0xFF00C853)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF00C853)),
                      ),
                      child: Text(
                        p['following'] ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: p['following']
                              ? Colors.white
                              : const Color(0xFF00C853),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamUpdates(bool isDark) {
    if (_loadingUpdates) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_updates.isEmpty) {
      return const Center(
          child: Text('No team updates yet',
              style: TextStyle(color: Colors.white54, fontSize: 14)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _updates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final u = _updates[index];
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                      const Color(0xFF00C853).withOpacity(0.2),
                      child: Text(u['name'][0],
                          style: const TextStyle(
                              color: Color(0xFF00C853),
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(u['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textDark)),
                    ),
                    Text(u['time'],
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12)),
                  ]),
                  const SizedBox(height: 10),
                  Text(u['content'],
                      style: TextStyle(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textDark,
                          height: 1.5)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.forum_outlined,
                        color: Colors.white38, size: 16),
                    const SizedBox(width: 6),
                    Text(u['thread'] ?? '',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ]),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Player Profile Full Screen ────────────────────────────────────────

class _PlayerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> player;
  const _PlayerProfileScreen({required this.player});

  @override
  State<_PlayerProfileScreen> createState() =>
      _PlayerProfileScreenState();
}

class _PlayerProfileScreenState
    extends State<_PlayerProfileScreen> {
  bool _isFollowing = false;
  String _about = '';
  String _location = '—';
  String _matches = '—';
  String _rating = '—';
  String _followers = '0';

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.player['following'] as bool? ?? false;
    _followers = widget.player['followers'] as String? ?? '0';
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final id = widget.player['id'] as String?;
    if (id == null) return;
    try {
      final api = ApiClient.instance;
      final results = await Future.wait([
        api.get('/players/$id/profile'),
        api.get('/players/$id/performance'),
      ]);
      if (!mounted) return;
      final prof = results[0] as Map<String, dynamic>;
      final perf = results[1] as Map<String, dynamic>;
      final recent =
          (perf['recentMatches'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final ratings = recent
          .map((m) => double.tryParse('${m['rating'] ?? ''}'))
          .whereType<double>()
          .toList();
      setState(() {
        _about = (prof['bio'] as String?) ?? '';
        _location = (prof['location'] as String?) ?? '—';
        _followers = '${prof['followers'] ?? _followers}';
        _matches = '${recent.length}';
        _rating = ratings.isEmpty
            ? '—'
            : (ratings.reduce((a, b) => a + b) / ratings.length)
                .toStringAsFixed(1);
      });
    } catch (_) {}
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
    final id = widget.player['id'] as String?;
    if (id != null) {
      _isFollowing
          ? SportyQoApi.followPlayer(id)
          : SportyQoApi.unfollowPlayer(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Player Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Avatar + Name ──
              Center(
                child: Column(children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF00C853), width: 2.5),
                    ),
                    child: Center(
                        child: Text(p['emoji'],
                            style: const TextStyle(fontSize: 52))),
                  ),
                  const SizedBox(height: 12),
                  Text(p['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(p['role'],
                      style: const TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(_location,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ]),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Follow / Message buttons ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleFollow,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isFollowing
                              ? const Color(0xFF00C853)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF00C853)),
                        ),
                        child: Center(
                          child: Text(
                            _isFollowing ? 'Following ✓' : 'Follow',
                            style: TextStyle(
                                color: _isFollowing
                                    ? Colors.white
                                    : const Color(0xFF00C853),
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _MessageScreen(player: p),
                        ),
                      ),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Center(
                          child: Text('Message',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // ── Stats ──
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ProfileStat(
                          label: 'Qo Score', value: '${p['pts']}'),
                      Container(
                          height: 40, width: 1, color: Colors.white10),
                      _ProfileStat(
                          label: 'Matches', value: _matches),
                      Container(
                          height: 40, width: 1, color: Colors.white10),
                      _ProfileStat(
                          label: 'Rating', value: _rating),
                      Container(
                          height: 40, width: 1, color: Colors.white10),
                      _ProfileStat(
                          label: 'Followers', value: _followers),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── About ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_about.isEmpty ? 'No bio added yet.' : _about,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              height: 1.6)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Player Details ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Details',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      const SizedBox(height: 12),
                      _DetailRow(
                          icon: Icons.sports_cricket,
                          label: 'Role',
                          value: p['role']),
                      _DetailRow(
                          icon: Icons.group,
                          label: 'Team',
                          value: p['team']),
                      _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: _location),
                    ],
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

// ── Message Screen ────────────────────────────────────────────────────

class _MessageScreen extends StatefulWidget {
  final Map<String, dynamic> player;
  const _MessageScreen({required this.player});

  @override
  State<_MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<_MessageScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  String? _threadId;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _openThread();
  }

  Future<void> _openThread() async {
    final id = widget.player['id'] as String?;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      _threadId = await SportyQoApi.directThread(id);
      final msgs = await SportyQoApi.dugoutMessages(_threadId!);
      if (!mounted) return;
      setState(() {
        _messages = msgs.reversed
            .toList()
            .cast<Map<String, dynamic>>()
            .map((m) => {
                  'text': m['body'] ?? '',
                  'isMe': m['isMine'] == true,
                  'time': _fmtTime(m['createdAt'] as String?),
                })
            .toList();
        _loading = false;
      });
      _jumpToEnd();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _fmtTime(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  void _jumpToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _threadId == null || _sending) return;
    setState(() {
      _sending = true;
      _messages.add({'text': text, 'isMe': true, 'time': _currentTime()});
    });
    _msgController.clear();
    _jumpToEnd();
    try {
      await SportyQoApi.sendDugoutMessage(_threadId!, text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Message failed to send'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                border: Border(
                    bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF00C853), width: 1.5),
                  ),
                  child: Center(
                      child: Text(p['emoji'],
                          style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      Row(children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('Online',
                            style: TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 11)),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert,
                      color: Colors.white54, size: 22),
                ),
              ]),
            ),

            // ── Messages ──
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isMe = m['isMe'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Text(p['emoji'],
                                    style: const TextStyle(
                                        fontSize: 16))),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width *
                                    0.65,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF00C853)
                                    : const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                  const Radius.circular(16),
                                  topRight:
                                  const Radius.circular(16),
                                  bottomLeft: Radius.circular(
                                      isMe ? 16 : 4),
                                  bottomRight: Radius.circular(
                                      isMe ? 4 : 16),
                                ),
                              ),
                              child: Text(
                                m['text'] as String,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['time'] as String,
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853)
                                  .withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF00C853),
                                  width: 1),
                            ),
                            child: const Icon(Icons.person,
                                color: Color(0xFF00C853), size: 18),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Message Input ──
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                border:
                Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.attach_file,
                        color: Colors.white54, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800)),
      Text(label,
          style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text('$label:',
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(width: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab(
      {required this.label,
        required this.isActive,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
          isActive ? const Color(0xFF00C853) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.darkBorder),
        ),
        child: Text(label,
            style: TextStyle(
                color: isActive ? Colors.white : AppColors.textGrey,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
      ),
    );
  }
}