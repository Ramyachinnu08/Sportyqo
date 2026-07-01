import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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

  final List<Map<String, dynamic>> _players = [
    {'name': 'Arjun Sharma', 'sqid': 'SQID: 784512', 'role': 'Batsman', 'subRole': 'Top Order', 'rating': 4.6, 'added': '12 May 2025', 'active': true, 'emoji': '🏏'},
    {'name': 'Rohan Mehta', 'sqid': 'SQID: 784513', 'role': 'Bowler', 'subRole': 'Fast', 'rating': 4.4, 'added': '12 May 2025', 'active': true, 'emoji': '🎯'},
    {'name': 'Vihaan Patel', 'sqid': 'SQID: 784514', 'role': 'All Rounder', 'subRole': 'Spin', 'rating': 4.7, 'added': '11 May 2025', 'active': true, 'emoji': '⚡'},
    {'name': 'Kabir Singh', 'sqid': 'SQID: 784515', 'role': 'Wicket Keeper', 'subRole': 'WK', 'rating': 4.5, 'added': '11 May 2025', 'active': true, 'emoji': '🧤'},
    {'name': 'Aryan Joshi', 'sqid': 'SQID: 784516', 'role': 'Batsman', 'subRole': 'Middle Order', 'rating': 4.3, 'added': '10 May 2025', 'active': true, 'emoji': '🏏'},
    {'name': 'Dev Sharma', 'sqid': 'SQID: 784517', 'role': 'Bowler', 'subRole': 'Spinner', 'rating': 4.6, 'added': '10 May 2025', 'active': true, 'emoji': '🎯'},
    {'name': 'Rahul Verma', 'sqid': 'SQID: 784518', 'role': 'Batsman', 'subRole': 'Opener', 'rating': 3.9, 'added': '08 May 2025', 'active': false, 'emoji': '🏏'},
    {'name': 'Kiran Das', 'sqid': 'SQID: 784519', 'role': 'Bowler', 'subRole': 'Medium Pace', 'rating': 3.7, 'added': '08 May 2025', 'active': false, 'emoji': '🎯'},
  ];

  final TextEditingController _addPlayerController =
  TextEditingController();

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
                                        : GestureDetector(
                                      onTap: () {},
                                      child: const Icon(
                                          Icons.qr_code_scanner,
                                          color: Colors.white38,
                                          size: 20),
                                    ),
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
                    if (_filtered.isEmpty)
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
                      label: 'Rating', value: '⭐ ${player['rating']}'),
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
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('${player['name']} recommended! ✅'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
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
                    setState(() {
                      _players.add({
                        'name': 'New Player',
                        'sqid': id,
                        'role': 'Batsman',
                        'subRole': 'Unknown',
                        'rating': 4.0,
                        'added': 'Just now',
                        'active': true,
                        'emoji': '🏏',
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Player $id added! ✅'),
                        backgroundColor: const Color(0xFF00C853),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a SportyQo ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
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

  void _showRecommendNow(BuildContext context) {
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
            const Text(
                'Select players to recommend to clubs and leagues.',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            ..._players
                .where((p) => p['active'] == true)
                .map((p) => Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      Text('${p['role']} • ${p['sqid']}',
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${p['name']} recommended to clubs! ✅'),
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
                    child: const Text('Recommend',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                  ),
                ),
              ]),
            )),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close',
                    style: TextStyle(color: Colors.white38))),
          ],
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
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text('${player['rating']}',
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