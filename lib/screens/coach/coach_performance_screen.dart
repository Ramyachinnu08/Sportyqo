import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/sportyqo_api.dart';
import '../shared/app_toast.dart';

class CoachPerformanceScreen extends StatefulWidget {
  const CoachPerformanceScreen({super.key});

  @override
  State<CoachPerformanceScreen> createState() =>
      _CoachPerformanceScreenState();
}

class _CoachPerformanceScreenState
    extends State<CoachPerformanceScreen> {
  int _tabIndex = 0;
  final TextEditingController _searchController =
  TextEditingController();
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
            'recommended': r['isRecommended'] == true,
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  final TextEditingController _addPlayerController =
  TextEditingController();

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
      list = list
          .where((p) =>
      p['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          p['sqid']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Page Title ──
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('My Players',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            Text(
                                'Manage players under you and track their journey.',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddPlayer(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(children: const [
                            Icon(Icons.add, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Add Player',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ]),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 14),

                    // ── Build Your Squad Card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_outline,
                              color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Build your squad',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              SizedBox(height: 3),
                              Text(
                                  'Add players using their SportyQo ID\nand manage their progress.',
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Players',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                            Text('${_players.length}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1)),
                            Row(children: [
                              const Text('Active ',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 10)),
                              Text(
                                  '${_players.where((p) => p['active'] == true).length}',
                                  style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              const Text('  Inactive ',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 10)),
                              Text(
                                  '${_players.where((p) => p['active'] == false).length}',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ]),
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: 14),

                    // ── Add Player by SportyQo ID ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add Player by SportyQo ID',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Enter SportyQo ID or name',
                                    hintStyle: const TextStyle(
                                        color: Colors.white24, fontSize: 13),
                                    prefixIcon: const Icon(Icons.search,
                                        color: Colors.white38, size: 18),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(
                                                () => _searchQuery = '');
                                      },
                                      child: const Icon(Icons.close,
                                          color: Colors.white38,
                                          size: 18),
                                    )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showAddPlayer(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Add',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ),
                            ),
                          ]),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${_filtered.length} result${_filtered.length != 1 ? 's' : ''} found',
                              style: const TextStyle(
                                  color: AppColors.primary, fontSize: 11),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(children: const [
                            SizedBox(width: 4),
                            Text('Scan Player QR code',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                            SizedBox(width: 4),
                            Icon(Icons.qr_code,
                                color: Colors.white38, size: 12),
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Tabs ──
                    Row(children: [
                      _PlayerTab(
                        icon: Icons.people_outline,
                        label: 'All (${_players.length})',
                        isActive: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      const SizedBox(width: 16),
                      _PlayerTab(
                        icon: Icons.people_outline,
                        label:
                        'Active (${_players.where((p) => p['active'] == true).length})',
                        isActive: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                        dotColor: const Color(0xFF00C853),
                      ),
                      const SizedBox(width: 16),
                      _PlayerTab(
                        icon: Icons.people_outline,
                        label:
                        'Inactive (${_players.where((p) => p['active'] == false).length})',
                        isActive: _tabIndex == 2,
                        onTap: () => setState(() => _tabIndex = 2),
                        dotColor: Colors.orange,
                      ),
                    ]),

                    const SizedBox(height: 2),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 12),

                    // ── Player List ──
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: Color(0xFF00C853)),
                        ),
                      )
                    else if (_filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(children: [
                            const Text('🔍',
                                style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No players found for\n"$_searchQuery"'
                                  : 'No players in this category',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 14),
                            ),
                          ]),
                        ),
                      )
                    else
                      ..._filtered.map((p) => GestureDetector(
                        onTap: () =>
                            _showPlayerDetail(context, p),
                        child: _PlayerTile(player: p),
                      )),

                    const SizedBox(height: 16),

                    // ── Recommend Players Card ──
                    GestureDetector(
                      onTap: () => _showRecommendNow(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.people_alt_outlined,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Recommend Players',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                SizedBox(height: 3),
                                Text(
                                    'Recommend talented players\nto clubs and leagues.',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11,
                                        height: 1.4)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showRecommendNow(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(children: const [
                                Text('Recommend Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 14),
                              ]),
                            ),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
  void _showRecommendNow(BuildContext context) {
    final sending = <String>{};
    final top = [..._players]
      ..sort((a, b) =>
          (b['qoScore'] as int).compareTo(a['qoScore'] as int));
    final list = top.take(8).toList();

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
              const Text(
                  'Select players to recommend to clubs and leagues.',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 20),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No players to recommend yet.',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 13)),
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: list.map((p) {
                      final id = p['id'] as String?;
                      final sent = p['recommended'] == true;
                      final busy = id != null && sending.contains(id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(children: [
                          Text(p['emoji'] as String,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(p['name'] as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                Text("${p['role']} • ${p['sqid']}",
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
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
                                          "${p['name']} recommended to clubs! ✅");
                                    } on ApiException catch (e) {
                                      if (!sheetContext.mounted) return;
                                      setSheetState(
                                          () => sending.remove(id));
                                      AppToast.error(
                                          sheetContext, e.message);
                                    } catch (_) {
                                      if (!sheetContext.mounted) return;
                                      setSheetState(
                                          () => sending.remove(id));
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
                                        color: AppColors.primary
                                            .withOpacity(0.5))
                                    : null,
                              ),
                              child: busy
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : Text(sent ? 'Sent ✓' : 'Recommend',
                                      style: TextStyle(
                                          color: sent
                                              ? AppColors.primary
                                              : Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11)),
                            ),
                          ),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
              ),
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

class _PlayerTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? dotColor;
  const _PlayerTab(
      {required this.icon,
        required this.label,
        required this.isActive,
        required this.onTap,
        this.dotColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Row(children: [
          Icon(icon,
              color: isActive ? AppColors.primary : Colors.white38,
              size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: isActive ? AppColors.primary : Colors.white38,
                  fontSize: 12,
                  fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w400)),
          if (dotColor != null) ...[
            const SizedBox(width: 4),
            Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                    color: dotColor, shape: BoxShape.circle)),
          ],
        ]),
        const SizedBox(height: 6),
        Container(
            height: 2,
            width: 80,
            color: isActive ? AppColors.primary : Colors.transparent),
      ]),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Center(
                child: Text(player['emoji'] as String,
                    style: const TextStyle(fontSize: 24))),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: player['active'] as bool
                    ? const Color(0xFF00C853)
                    : Colors.orange,
                border: Border.all(
                    color: const Color(0xFF111111), width: 1.5),
              ),
            ),
          ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(player['name'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              Text(player['sqid'] as String,
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 11)),
              Row(children: [
                const Icon(Icons.bolt, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text('Qo ${player['qoScore']}',
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(player['role'] as String,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Text(player['subRole'] as String,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Added on',
                style: TextStyle(color: Colors.white38, fontSize: 10)),
            Text(player['added'] as String,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 10)),
          ],
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      ]),
    );
  }
}