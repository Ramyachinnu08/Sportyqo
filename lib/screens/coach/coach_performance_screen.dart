import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/sportyqo_api.dart';
import '../shared/app_toast.dart';
import '../shared/avatar_picker.dart';

/// My Players (design p.8): squad-building card with Total / Active /
/// Inactive counts, Add Player by SportyQo ID, All / Active / Inactive
/// tabs, photo player rows and the Recommend Players card. Players come
/// from the coach's leagues (GET /players) with a community fallback.
class CoachPerformanceScreen extends StatefulWidget {
  const CoachPerformanceScreen({super.key});

  @override
  State<CoachPerformanceScreen> createState() =>
      _CoachPerformanceScreenState();
}

class _CoachPerformanceScreenState extends State<CoachPerformanceScreen> {
  int _tabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _players = [];
  bool _loading = true;

  static const _monthsShort = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      // Players in this coach's leagues first…
      var data =
          (await SportyQoApi.searchPlayers()).cast<Map<String, dynamic>>();
      // …falling back to the community leaderboard when the coach's
      // leagues have no members yet, so the section is never empty.
      if (data.isEmpty) {
        data = (await SportyQoApi.discoverPlayers())
            .cast<Map<String, dynamic>>();
      }
      if (!mounted) return;
      setState(() {
        _players = data.map((r) {
          final dt =
              DateTime.tryParse(r['joinedAt'] as String? ?? '')?.toLocal();
          return {
            'id': r['id'],
            'name': r['fullName'] ?? '',
            'sqid': r['playerId'] ?? r['playerCode'] ?? '',
            'role': r['teamName'] ??
                ((r['academy'] as String?)?.isNotEmpty == true
                    ? r['academy']
                    : 'No team yet'),
            'subRole': r['position'] ?? (r['sport'] ?? ''),
            'qoScore': (r['qoScore'] as num?)?.toInt() ?? 0,
            'added': dt == null
                ? ''
                : '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}',
            'active': r['onTeam'] == true,
            'emoji': r['sportEmoji'] ?? '🏅',
            'avatarUrl': r['avatarUrl'],
            'recommended': r['isRecommended'] == true,
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }


  final TextEditingController _addPlayerController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _addPlayerController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _tabIndex == 0
        ? _players
        : _tabIndex == 1
            ? _players.where((p) => p['active'] == true).toList()
            : _players.where((p) => p['active'] == false).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p['name'].toString().toLowerCase().contains(q) ||
              p['sqid'].toString().toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  int get _activeCount => _players.where((p) => p['active'] == true).length;

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
                onRefresh: _loadPlayers,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    _header(),
                    const SizedBox(height: 16),
                    _squadCard(),
                    const SizedBox(height: 14),
                    _addBySqidCard(),
                    const SizedBox(height: 16),
                    _tabsRow(),
                    const SizedBox(height: 12),
                    if (_filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No players found for\n"$_searchQuery"'
                                : 'No players in this category yet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      for (final p in _filtered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _playerRow(p),
                        ),
                    const SizedBox(height: 8),
                    _recommendCard(),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header: "My Players" + Add Player button ──
  Widget _header() => Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('My Players',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Manage players under you and track their journey.',
                style: TextStyle(color: Colors.white54, fontSize: 11.5)),
          ]),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddPlayer(context),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text('Add Player',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]);

  // ── Build your squad card with counts ──
  Widget _squadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.12),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: const Icon(Icons.person_add_alt_outlined,
              color: AppColors.primaryLight, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Build your squad',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 3),
            Text('Add players using their SportyQo ID\nand manage their progress.',
                style: TextStyle(
                    color: Colors.white38, fontSize: 10.5, height: 1.4)),
          ]),
        ),
        Container(width: 1, height: 52, color: Colors.white10),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Players',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
          Text('${_players.length}',
              style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Active',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text('$_activeCount',
                  style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Inactive',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text('${_players.length - _activeCount}',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ]),
          ]),
        ]),
      ]),
    );
  }

  // ── Add Player by SportyQo ID ──
  Widget _addBySqidCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add Player by SportyQo ID',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Enter SportyQo ID or name',
                hintStyle:
                    const TextStyle(color: Colors.white30, fontSize: 12.5),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white38, size: 18),
                filled: true,
                fillColor: const Color(0xFF1B1B38),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _showAddPlayer(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Player',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }

  // ── All / Active / Inactive tabs ──
  Widget _tabsRow() {
    Widget tab(int i, String label, Color? dot) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _tabIndex == i
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people_outline,
                    size: 15,
                    color: _tabIndex == i
                        ? AppColors.primaryLight
                        : Colors.white38),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: _tabIndex == i
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 12,
                        fontWeight: _tabIndex == i
                            ? FontWeight.w700
                            : FontWeight.w500)),
                if (dot != null) ...[
                  const SizedBox(width: 5),
                  Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: dot, shape: BoxShape.circle)),
                ],
              ]),
            ),
          ),
        );
    return Row(children: [
      tab(0, 'All Players (${_players.length})', null),
      tab(1, 'Active ($_activeCount)', const Color(0xFF00C853)),
      tab(2, 'Inactive (${_players.length - _activeCount})', Colors.amber),
    ]);
  }

  // ── Player row (photo, name, SQID, role chip, added date) ──
  Widget _playerRow(Map<String, dynamic> p) {
    return GestureDetector(
      onTap: () => _showPlayerDetail(context, p),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF14142B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(children: [
          Stack(children: [
            AvatarCircle(
              avatarUrl: p['avatarUrl'] as String?,
              name: p['name'] as String? ?? 'P',
              size: 44,
              borderWidth: 1.5,
            ),
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: p['active'] == true
                      ? const Color(0xFF00C853)
                      : Colors.amber,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFF14142B), width: 2),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['name'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700)),
              Text('SQID: ${p['sqid']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.primaryLight, fontSize: 11)),
              Text('⚡ ${p['qoScore']} Qo',
                  style: const TextStyle(
                      color: Colors.amber, fontSize: 10.5)),
            ]),
          ),
          Expanded(
            flex: 4,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['role'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11.5)),
              if ((p['subRole'] as String?)?.isNotEmpty == true)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(p['subRole'] as String,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 10)),
                ),
            ]),
          ),
          if ((p['added'] as String?)?.isNotEmpty == true)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Added on',
                  style: TextStyle(color: Colors.white30, fontSize: 9.5)),
              Text(p['added'] as String,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 10.5)),
            ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
        ]),
      ),
    );
  }

  // ── Recommend Players card ──
  Widget _recommendCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: const Icon(Icons.recommend_outlined,
              color: AppColors.primaryLight, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Recommend Players',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 3),
            Text('Recommend talented players\nto clubs and leagues.',
                style: TextStyle(
                    color: Colors.white38, fontSize: 11, height: 1.4)),
          ]),
        ),
        OutlinedButton(
          onPressed: () => _showRecommendNow(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Text('Recommend Now',
                style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward,
                color: AppColors.primaryLight, size: 13),
          ]),
        ),
      ]),
    );
  }

  void _showPlayerDetail(
      BuildContext context, Map<String, dynamic> player) {
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
          children: [
            // Avatar
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 2),
              ),
              child: Center(
                  child: Text(player['emoji'] as String,
                      style: const TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 12),
            Text(player['name'] as String,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            Text(player['sqid'] as String,
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 13)),
            const SizedBox(height: 16),

            // Stats
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(label: 'Role', value: player['role']),
                  Container(width: 1, height: 30, color: Colors.white10),
                  _MiniStat(label: 'Sub Role', value: player['subRole']),
                  Container(width: 1, height: 30, color: Colors.white10),
                  _MiniStat(
                      label: 'Qo Score', value: '${player['qoScore']}'),
                  Container(width: 1, height: 30, color: Colors.white10),
                  _MiniStat(
                      label: 'Status',
                      value: player['active'] as bool
                          ? '🟢 Active'
                          : '🟠 Inactive'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final id = player['id'] as String?;
                    if (id == null) return;
                    try {
                      await SportyQoApi.recommendPlayer(id);
                      if (!mounted) return;
                      setState(() => player['recommended'] = true);
                      AppToast.success(this.context,
                          "${player['name']} recommended! ✅");
                    } on ApiException catch (e) {
                      if (!mounted) return;
                      AppToast.error(this.context, e.message);
                    } catch (_) {
                      if (!mounted) return;
                      AppToast.error(
                          this.context, 'Could not send — try again.');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Recommend',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Text('Close',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Player',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'Enter the player\'s SportyQo ID to add them to your squad.',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _addPlayerController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. SQID: 784520',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.person_add_outlined,
                    color: Colors.white38),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final id = _addPlayerController.text.trim();
                  Navigator.pop(context);
                  _addPlayerController.clear();
                  if (id.isNotEmpty) {
                    AppToast.info(
                        context,
                        'Players join with your league code — share it from the league screen. They will appear here once they join.',
                        duration: const Duration(seconds: 4));
                  } else {
                    AppToast.error(context, 'Please enter a SportyQo ID');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Player',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Recommend Now": lists the coach's top players (by Qo score) with a
  /// real Send action — POST /players/:id/recommend records it and
  /// notifies the player. Rows flip to "Sent ✓" once recommended.
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
      Text(label,
          style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ]);
  }
}
