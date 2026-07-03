import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sportyqo_api.dart';
import '../../services/api_client.dart';

/// List of the user's Dugout chat threads (team chats + direct messages).
/// Backed by GET /dugout.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _threads = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SportyQoApi.dugoutThreads();
      if (!mounted) return;
      setState(() {
        _threads = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your chats. Check your connection.';
        _loading = false;
      });
    }
  }

  static String _relativeTime(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
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
                const Text('Messages',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? _ErrorState(message: _error!, onRetry: _load)
                      : _threads.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                    'No conversations yet.\nMessage a player from the Dugout to start one.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 13,
                                        height: 1.5)),
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _load,
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: _threads.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final t = _threads[i];
                                  final last = t['lastMessage']
                                      as Map<String, dynamic>?;
                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatThreadScreen(
                                            threadId: t['id'] as String,
                                            title: t['title'] as String? ??
                                                'Chat',
                                            icon: t['icon'] as String? ?? '💬',
                                          ),
                                        ),
                                      );
                                      _load(); // refresh previews on return
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F0F2A),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border:
                                            Border.all(color: Colors.white10),
                                      ),
                                      child: Row(children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                              child: Text(
                                                  t['icon'] as String? ?? '💬',
                                                  style: const TextStyle(
                                                      fontSize: 20))),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  t['title'] as String? ??
                                                      'Chat',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14)),
                                              const SizedBox(height: 3),
                                              Text(
                                                last == null
                                                    ? 'No messages yet'
                                                    : '${last['senderName'] ?? ''}: ${last['body'] ?? ''}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                            _relativeTime(
                                                last?['at'] as String?),
                                            style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11)),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One conversation. Backed by GET/POST /dugout/:id/messages.
class ChatThreadScreen extends StatefulWidget {
  final String threadId;
  final String title;
  final String icon;
  const ChatThreadScreen({
    super.key,
    required this.threadId,
    required this.title,
    this.icon = '💬',
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = []; // oldest first
  bool _loading = true;
  bool _sending = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // Light polling keeps the thread fresh without websockets.
    _pollTimer = Timer.periodic(
        const Duration(seconds: 8), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await SportyQoApi.dugoutMessages(widget.threadId);
      if (!mounted) return;
      final msgs = data.cast<Map<String, dynamic>>().reversed.toList();
      setState(() {
        _messages = msgs;
        _loading = false;
      });
      _jumpToBottom();
    } on ApiException catch (e) {
      if (!mounted || silent) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || silent) return;
      setState(() {
        _error = 'Could not load messages. Check your connection.';
        _loading = false;
      });
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final sent =
          await SportyQoApi.sendDugoutMessage(widget.threadId, text);
      if (!mounted) return;
      _msgCtrl.clear();
      setState(() {
        _messages = [..._messages, sent];
      });
      _jumpToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.redAccent,
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Message not sent. Check your connection.'),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  static String _timeLabel(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    return '$h:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                      child: Text(widget.icon,
                          style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            Container(height: 1, color: Colors.white10),

            // Messages
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? _ErrorState(message: _error!, onRetry: _load)
                      : _messages.isEmpty
                          ? const Center(
                              child: Text('Say hi! 👋',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 14)))
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, i) {
                                final m = _messages[i];
                                final mine = m['isMine'] == true ||
                                    m['senderId'] ==
                                        ApiClient.instance.userId;
                                return Align(
                                  alignment: mine
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.75),
                                    decoration: BoxDecoration(
                                      color: mine
                                          ? AppColors.primary
                                          : const Color(0xFF0F0F2A),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                            mine ? 16 : 4),
                                        bottomRight: Radius.circular(
                                            mine ? 4 : 16),
                                      ),
                                      border: mine
                                          ? null
                                          : Border.all(
                                              color: Colors.white10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!mine &&
                                            (m['senderName'] as String?)
                                                    ?.isNotEmpty ==
                                                true)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 2),
                                            child: Text(
                                                m['senderName'] as String,
                                                style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        Text(m['body'] as String? ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.35)),
                                        const SizedBox(height: 3),
                                        Text(
                                            _timeLabel(
                                                m['createdAt'] as String?),
                                            style: TextStyle(
                                                color: mine
                                                    ? Colors.white70
                                                    : Colors.white38,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            // Composer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F2A),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: const TextStyle(
                          color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF0A0A1A),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Colors.white38, size: 40),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
