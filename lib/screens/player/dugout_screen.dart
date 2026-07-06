import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/sportyqo_api.dart';
import '../shared/app_toast.dart';
import '../shared/avatar_picker.dart';
import '../shared/chat_screens.dart';
import '../shared/notifications_sheet.dart';

/// Dugout (design p.5): community discovery. Search bar, sport filter
/// chips, "Qo Score • High to Low" sort row, and large photo cards —
/// the card background is the player's real profile photo (gradient
/// fallback when they haven't uploaded one). Data: GET /players/discover.
class DugoutScreen extends StatefulWidget {
  const DugoutScreen({super.key});

  @override
  State<DugoutScreen> createState() => _DugoutScreenState();
}

class _DugoutScreenState extends State<DugoutScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _players = [];
  List<String> _sports = const [];
  String _sportFilter = 'All';
  bool _highToLow = true;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    SportyQoApi.sports().then((s) {
      if (!mounted) return;
      setState(() => _sports = s
          .cast<Map<String, dynamic>>()
          .map((e) => e['name'] as String)
          .toList());
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SportyQoApi.discoverPlayers(
        q: _searchCtrl.text.trim(),
        sport: _sportFilter == 'All' ? null : _sportFilter,
      );
      if (!mounted) return;
      setState(() {
        _players = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load players. Pull to retry.';
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  List<Map<String, dynamic>> get _sorted {
    final list = [..._players]..sort((a, b) {
        final av = ((a['qoScore'] as num?) ?? 0);
        final bv = ((b['qoScore'] as num?) ?? 0);
        return _highToLow ? bv.compareTo(av) : av.compareTo(bv);
      });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              const Expanded(
                child: Text('Dugout',
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
            ]),
          ),
          const SizedBox(height: 14),

          // ── Search ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search player, team or coach',
                hintStyle:
                    const TextStyle(color: Colors.white38, fontSize: 13.5),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: const Color(0xFF16162E),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Sport chips ──
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final s in ['All', ..._sports])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: _sportFilter == s,
                      onSelected: (_) {
                        setState(() => _sportFilter = s);
                        _load();
                      },
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFF16162E),
                      labelStyle: TextStyle(
                          color: _sportFilter == s
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: _sportFilter == s
                                  ? AppColors.primary
                                  : Colors.white12)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Sort row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.military_tech_outlined,
                  size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              const Text('Qo Score',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _highToLow = !_highToLow),
                child: Text(_highToLow ? 'High to Low' : 'Low to High',
                    style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              const Icon(Icons.tune_rounded, size: 18, color: Colors.white54),
            ]),
          ),
          const SizedBox(height: 10),

          // ── Player cards ──
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? _errorState()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFF16162E),
                        onRefresh: _load,
                        child: _sorted.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 120),
                                Center(
                                    child: Text('No players found.',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 13))),
                              ])
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                itemCount: _sorted.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    _PlayerCard(player: _sorted[i]),
                              ),
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _errorState() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _load,
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary)),
            child: const Text('Retry',
                style: TextStyle(color: AppColors.primaryLight)),
          ),
        ]),
      );
}

// ── Photo card (design p.5) ───────────────────────────────────────────
class _PlayerCard extends StatefulWidget {
  final Map<String, dynamic> player;
  const _PlayerCard({required this.player});

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    final photo = ApiClient.resolveMediaUrl(p['avatarUrl'] as String?);
    final matches = (p['matchesPlayed'] as num?)?.toInt() ?? 0;
    final followers = (p['followers'] as num?)?.toInt() ?? 0;
    final academy = (p['academy'] as String?)?.isNotEmpty == true
        ? p['academy'] as String
        : (p['location'] as String? ?? '');

    return GestureDetector(
      onTap: () => _openActions(context),
      child: Container(
        height: 148,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D1D3E), Color(0xFF121226)],
          ),
        ),
        child: Stack(fit: StackFit.expand, children: [
          if (photo != null)
            Image.network(photo,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
          // readability gradient over the photo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.78),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      AvatarCircle(
                        avatarUrl: p['avatarUrl'] as String?,
                        name: p['fullName'] as String? ?? 'P',
                        size: 34,
                        borderColor: AppColors.primary,
                        borderWidth: 1.5,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(p['fullName'] as String? ?? 'Player',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800)),
                      ),
                      if (p['verified'] == true) ...[
                        const SizedBox(width: 5),
                        const Icon(Icons.verified,
                            color: AppColors.primaryLight, size: 15),
                      ],
                    ]),
                    const SizedBox(height: 5),
                    Text(
                      [
                        if ((p['sport'] as String?) != null)
                          p['sport'] as String,
                        if ((p['playerCode'] as String?) != null)
                          p['playerCode'] as String,
                      ].join(' • '),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '🏆 $matches ${matches == 1 ? 'Match' : 'Matches'} • $followers Followers',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11.5),
                    ),
                    if (academy.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(academy,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              // Qo Score badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(p['qoScore'] as num?)?.toInt() ?? 0}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const Text('Qo Score',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 9.5)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // Tap → follow / message actions sheet
  void _openActions(BuildContext context) {
    final p = widget.player;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14142B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final following = p['isFollowing'] == true;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AvatarCircle(
                avatarUrl: p['avatarUrl'] as String?,
                name: p['fullName'] as String? ?? 'P',
                size: 72,
                borderColor: AppColors.primary,
              ),
              const SizedBox(height: 10),
              Text(p['fullName'] as String? ?? 'Player',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              Text(
                [
                  if ((p['sport'] as String?) != null) p['sport'] as String,
                  '${(p['qoScore'] as num?)?.toInt() ?? 0} Qo',
                ].join(' • '),
                style:
                    const TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            setSheetState(() => _busy = true);
                            try {
                              if (following) {
                                await SportyQoApi
                                    .unfollowPlayer(p['id'] as String);
                              } else {
                                await SportyQoApi
                                    .followPlayer(p['id'] as String);
                              }
                              p['isFollowing'] = !following;
                              p['followers'] =
                                  ((p['followers'] as num?) ?? 0).toInt() +
                                      (following ? -1 : 1);
                              if (mounted) setState(() {});
                            } on ApiException catch (e) {
                              if (sheetCtx.mounted) {
                                AppToast.error(sheetCtx, e.message);
                              }
                            } catch (_) {
                              if (sheetCtx.mounted) {
                                AppToast.error(sheetCtx,
                                    'Could not update follow — try again.');
                              }
                            } finally {
                              if (sheetCtx.mounted) {
                                setSheetState(() => _busy = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: following
                          ? Colors.white10
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(following ? 'Following ✓' : 'Follow',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      try {
                        final threadId = await SportyQoApi
                            .directThread(p['id'] as String);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatThreadScreen(
                              threadId: threadId,
                              title: p['fullName'] as String? ?? 'Chat',
                              icon: '💬',
                            ),
                          ),
                        );
                      } on ApiException catch (e) {
                        if (!context.mounted) return;
                        AppToast.error(
                            context,
                            e.code == 'FORBIDDEN'
                                ? 'You can only message players who share a league with you.'
                                : e.message);
                      } catch (_) {
                        if (!context.mounted) return;
                        AppToast.error(
                            context, 'Could not open the chat — try again.');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Message',
                        style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
