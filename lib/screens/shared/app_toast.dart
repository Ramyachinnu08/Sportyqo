import 'dart:async';
import 'package:flutter/material.dart';

/// Lightweight overlay toast used across the app for success / error / info
/// feedback. Unlike SnackBars it does not require a Scaffold, works from
/// bottom sheets and dialogs, and never blocks the bottom navigation bar.
///
/// Usage:
///   AppToast.error(context, 'Could not save your profile.');
///   AppToast.success(context, 'Profile photo updated');
///   AppToast.info(context, 'Uploading photo…');       // sticky until replaced
///   AppToast.dismiss();                                // hide programmatically
class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void success(BuildContext context, String message,
          {Duration duration = const Duration(seconds: 2)}) =>
      show(context, message,
          icon: Icons.check_circle_rounded,
          background: const Color(0xFF1E8E5A),
          duration: duration);

  static void error(BuildContext context, String message,
          {Duration duration = const Duration(seconds: 4)}) =>
      show(context, message,
          icon: Icons.error_rounded,
          background: const Color(0xFFD64545),
          duration: duration);

  /// Neutral toast (e.g. progress messages). Pass a long [duration] and call
  /// a later toast (or [dismiss]) to replace it.
  static void info(BuildContext context, String message,
          {Duration duration = const Duration(seconds: 3)}) =>
      show(context, message,
          icon: Icons.info_rounded,
          background: const Color(0xFF3A3A5C),
          duration: duration);

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.info_rounded,
    Color background = const Color(0xFF3A3A5C),
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss(); // one toast at a time — new messages replace the current one

    _entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        icon: icon,
        background: background,
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color background;

  const _ToastView({
    required this.message,
    required this.icon,
    required this.background,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomInset + 90, // clears the bottom navigation bar
      child: IgnorePointer(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, 0.25), end: Offset.zero)
                .animate(
                    CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.background,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black45,
                        blurRadius: 16,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
