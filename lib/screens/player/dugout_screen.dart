import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';
import '../shared/chat_screens.dart';

class DugoutScreen extends StatefulWidget {
  const DugoutScreen({super.key});

  @override
  State<DugoutScreen> createState() => _DugoutScreenState();
}

class _DugoutScreenState extends State<DugoutScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _sortBy = 'High to Low';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Cricket',
    'Football',
    'Basketball',
    'Badminton',
    'Athletics',
  ];

  List<Map<String, dynamic>> _players = [];
  bool _loading = true;
  String? _error;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Text changes hit the backend search (GET /players/discover?q=) after a
  /// short debounce, so results are not limited to the first page loaded.
  void _onSearchChanged(String v) {
    setState(() => _searchQuery = v);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _load);
  }

  static ({Color c1, Color c2, String emoji}) _sportStyle(String? sport) {
    switch (sport) {
      case 'Cricket':
        return (c1: const Color(0xFF1A3A2A), c2: const Color(0xFF0A1A12), emoji: '🏏');
      case 'Football':
        return (c1: const Color(0xFF1A2A3A), c2: const Color(0xFF0A1020), emoji: '⚽');
      case 'Basketball':
        return (c1: const Color(0xFF2A2A1A), c2: const Color(0xFF141408), emoji: '🏀');
      case 'Badminton':
        return (c1: const Color(0xFF1A1A2A), c2: const Color(0xFF0A0A14), emoji: '🏸');
      case 'Volleyball':
        return (c1: const Color(0xFF2A1A2A), c2: const Color(0xFF140A14), emoji: '🏐');
      case 'Tennis':
        return (c1: const Color(0xFF1A2A1A), c2: const Color(0xFF0A140A), emoji: '🎾');
      case 'Hockey':
        return (c1: const Color(0xFF2A1A1A), c2: const Color(0xFF140A0A), emoji: '🏑');
      case 'Kabaddi':
        return (c1: const Color(0xFF2A231A), c2: const Color(0xFF14100A), emoji: '🤼');
      default:
        return (c1: const Color(0xFF1A1A2A), c2: const Color(0xFF0A0A14), emoji: '🏅');
    }
  }

  static String _fmtCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SportyQoApi.discoverPlayers(
        sport: _selectedFilter,
        q: _searchQuery.trim(),
      );
      if (!mounted) return;
      setState(() {
        _players = data.cast<Map<String, dynamic>>().map((r) {
          final sport = r['sport'] as String?;
          final st = _sportStyle(sport);
          final matches = (r['matchesPlayed'] as num?)?.toInt() ?? 0;
          return {
            'id': r['id'],
            'name': r['fullName'] ?? '',
            'qoScore': (r['qoScore'] as num?)?.toInt() ?? 0,
            'sport': sport ?? 'Sport',
            'age': r['playerCode'] ?? '',
            'achievement':
                '$matches ${matches == 1 ? 'match' : 'matches'} played',
            'academy': (r['academy'] as String?)?.isNotEmpty == true
                ? r['academy'] as String
                : (r['location'] as String? ?? ''),
            'color1': st.c1,
            'color2': st.c2,
            'emoji': (r['sportEmoji'] as String?) ?? st.emoji,
            'avatarUrl': r['avatarUrl'] as String?,
            'filter': sport ?? 'All',
            'verified': r['verified'] == true,
            'isFollowing': r['isFollowing'] == true,
            'followers': _fmtCount((r['followers'] as num?)?.toInt() ?? 0),
            'matches': matches,
          };
        }).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.code == 'NETWORK'
            ? 'Could not reach the SportyQo server.\nCheck your connection and try again.'
            : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong while loading players.';
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _selectedFilter == 'All'
        ? _players
        : _players.where((p) => p['filter'] == _selectedFilter).toList();
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
      p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['sport'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['academy'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_sortBy == 'High to Low') {
      list.sort((a, b) => (b['qoScore'] as int).compareTo(a['qoScore'] as int));
    } else {
      list.sort((a, b) => (a['qoScore'] as int).compareTo(b['qoScore'] as int));
    }
    return list;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Filter & Sort',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setModalState(() {});
                    setState(() {
                      _selectedFilter = 'All';
                      _sortBy = 'High to Low';
                    });
                    _load();
                  },
                  child: const Text('Reset',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 20),
              const Text('Sort by Qo Score',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                _FilterChip(
                  label: 'High to Low',
                  isSelected: _sortBy == 'High to Low',
                  onTap: () {
                    setModalState(() {});
                    setState(() => _sortBy = 'High to Low');
                  },
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'Low to High',
                  isSelected: _sortBy == 'Low to High',
                  onTap: () {
                    setModalState(() {});
                    setState(() => _sortBy = 'Low to High');
                  },
                ),
              ]),
              const SizedBox(height: 20),
              const Text('Sport',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _filters.map((f) {
                  return _FilterChip(
                    label: f,
                    isSelected: _selectedFilter == f,
                    onTap: () {
                      setModalState(() {});
                      setState(() => _selectedFilter = f);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _load();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F2A),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search player, team or coach',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _load();
                      },
                      child: const Icon(Icons.close, color: Colors.white38, size: 18),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter Tabs ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = _filters[index];
                  final isActive = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = f);
                      _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive ? null : Border.all(color: Colors.white24),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              color: isActive ? Colors.white : Colors.white60,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ── Sort row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white38, size: 16),
                  const SizedBox(width: 6),
                  const Text('Sorted by Qo Score ',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _sortBy = _sortBy == 'High to Low' ? 'Low to High' : 'High to Low';
                      });
                    },
                    child: Row(children: [
                      Text(_sortBy,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primary, size: 14),
                    ]),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(children: const [
                        Text('Filter', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.tune, color: Colors.white70, size: 14),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Player List ──
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                color: Colors.white38, size: 40),
                            const SizedBox(height: 12),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                            const SizedBox(height: 14),
                            OutlinedButton(
                              onPressed: _load,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: const Text('Retry',
                                  style: TextStyle(
                                      color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                        _searchQuery.isEmpty
                            ? 'No players yet'
                            : 'No players found for "$_searchQuery"',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 14)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'All';
                        });
                        _load();
                      },
                      child: const Text('Clear search',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = _filtered[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _PlayerProfileScreen(player: p),
                      ),
                    ),
                    child: _PlayerCard(player: p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip Widget ────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white24),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

// ── Player Card ───────────────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final p = player;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [p['color1'] as Color, p['color2'] as Color],
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [(p['color1'] as Color).withOpacity(0.8), p['color2'] as Color],
              ),
            ),
            child: ApiClient.resolveMediaUrl(p['avatarUrl'] as String?) == null
                ? Center(
                    child: Text(p['emoji'] as String,
                        style: const TextStyle(fontSize: 52)),
                  )
                : ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16)),
                    child: Image.network(
                      ApiClient.resolveMediaUrl(p['avatarUrl'] as String?)!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(p['emoji'] as String,
                            style: const TextStyle(fontSize: 52)),
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Row(children: [
                          Text('${p['qoScore']}',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                          const SizedBox(width: 4),
                          const Text('Qo Score',
                              style: TextStyle(color: Colors.white60, fontSize: 10)),
                        ]),
                      ),
                    ],
                  ),
                  Row(children: [
                    Expanded(
                      child: Text(p['name'] as String,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    if (p['verified'] as bool)
                      const Icon(Icons.verified, color: AppColors.primary, size: 14),
                  ]),
                  Text('${p['sport']} • ${p['age']}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Row(children: [
                    const Text('🏆', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(p['achievement'] as String,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                  Text(p['academy'] as String,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Player Profile Screen ─────────────────────────────────────────────

class _PlayerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> player;
  const _PlayerProfileScreen({required this.player});

  @override
  State<_PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<_PlayerProfileScreen> {
  late bool _isFollowing = widget.player['isFollowing'] == true;
  bool _followBusy = false;
  bool _openingChat = false;

  Future<void> _toggleFollow() async {
    if (_followBusy) return;
    final target = widget.player['id'] as String?;
    if (target == null) return;
    final next = !_isFollowing;
    setState(() {
      _isFollowing = next; // optimistic
      _followBusy = true;
    });
    try {
      if (next) {
        await SportyQoApi.followPlayer(target);
      } else {
        await SportyQoApi.unfollowPlayer(target);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isFollowing = !next); // revert
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.redAccent,
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFollowing = !next);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not update follow. Check your connection.'),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  Future<void> _openChat() async {
    if (_openingChat) return;
    final target = widget.player['id'] as String?;
    if (target == null) return;
    setState(() => _openingChat = true);
    try {
      final threadId = await SportyQoApi.directThread(target);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatThreadScreen(
            threadId: threadId,
            title: widget.player['name'] as String? ?? 'Chat',
            icon: widget.player['emoji'] as String? ?? '💬',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'FORBIDDEN'
            ? 'You can only message players who share a league with you.'
            : e.message),
        backgroundColor: Colors.redAccent,
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open the chat. Check your connection.'),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Share.share(
                        'Check out ${widget.player['name']} (Qo Score ${widget.player['qoScore']}) on SportyQo!'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              ApiClient.resolveMediaUrl(p['avatarUrl'] as String?) == null
                  ? Text(p['emoji'] as String,
                      style: const TextStyle(fontSize: 72))
                  : ClipOval(
                      child: Image.network(
                        ApiClient.resolveMediaUrl(
                            p['avatarUrl'] as String?)!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                            p['emoji'] as String,
                            style: const TextStyle(fontSize: 72)),
                      ),
                    ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p['name'] as String,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  if (p['verified'] as bool)
                    const Icon(Icons.verified, color: AppColors.primary, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text('${p['sport']} • ${p['age']}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Text('Qo Score: ${p['qoScore']}',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCol(label: 'Followers', value: p['followers'] as String),
                      Container(height: 40, width: 1, color: Colors.white10),
                      _StatCol(label: 'Matches', value: '${p['matches']}'),
                      Container(height: 40, width: 1, color: Colors.white10),
                      _StatCol(label: 'Qo Score', value: '${p['qoScore']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(children: [
                    const Text('🏆', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Achievement',
                              style: TextStyle(color: Colors.white38, fontSize: 12)),
                          Text(p['achievement'] as String,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                      const Icon(Icons.school_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Academy',
                              style: TextStyle(color: Colors.white38, fontSize: 12)),
                          Text(p['academy'] as String,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleFollow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isFollowing ? Colors.white10 : AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          border: _isFollowing ? Border.all(color: Colors.white24) : null,
                        ),
                        child: Center(
                          child: Text(
                            _isFollowing ? 'Following ✓' : 'Follow',
                            style: TextStyle(
                                color: _isFollowing ? Colors.white70 : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _openChat,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: _openingChat
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.message_outlined,
                              color: Colors.white, size: 22),
                    ),
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

class _StatCol extends StatelessWidget {
  final String label, value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}