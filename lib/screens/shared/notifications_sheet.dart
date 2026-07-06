import 'package:flutter/material.dart';
import '../../services/sportyqo_api.dart';

/// Opens the notifications bottom sheet (real data from GET /notifications)
/// and marks everything read. Used by the Home and Dugout headers.
Future<void> showNotificationsSheet(BuildContext context) async {
  List<Map<String, dynamic>> items = const [];
  try {
    items = (await SportyQoApi.notifications()).cast<Map<String, dynamic>>();
  } catch (_) {}
  SportyQoApi.markNotificationsRead().catchError((_) {});
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF14142B),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Notifications',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('No notifications yet.',
                        style: TextStyle(color: Colors.white38, fontSize: 13)))
                : ListView.separated(
                    controller: controller,
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white10, height: 18),
                    itemBuilder: (_, i) {
                      final n = items[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['emoji'] as String? ?? '🔔',
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['title'] as String? ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700)),
                                if ((n['body'] as String?)?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(n['body'] as String,
                                        style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12.5,
                                            height: 1.35)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ]),
      ),
    ),
  );
}
