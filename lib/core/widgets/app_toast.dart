import 'dart:async';

import 'package:flutter/material.dart';

/// Type de message : change la couleur et l'icône.
enum ToastType { info, success, error }

/// Messages éphémères affichés en HAUT de l'écran (les SnackBars de
/// Material s'affichent en bas).
///
/// Une seule notification à la fois : la nouvelle remplace l'ancienne.
/// Elle disparaît seule après [duration], ou au toucher.
abstract final class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    hide();
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) => _Toast(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (identical(_current, entry)) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  /// Retire immédiatement la notification affichée, s'il y en a une.
  static void hide() {
    final OverlayEntry? entry = _current;
    _current = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  /// Glisse depuis le haut (au-dessus de l'écran) jusqu'à sa place.
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -1.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward());
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (
      Color background,
      Color foreground,
      IconData icon,
    ) = switch (widget.type) {
      ToastType.info => (
        colors.inverseSurface,
        colors.onInverseSurface,
        Icons.info_outline,
      ),
      ToastType.success => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      ToastType.error => (
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline,
      ),
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _offset,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: background,
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _dismiss,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(icon, color: foreground),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(color: foreground),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
