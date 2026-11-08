import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

enum AppNotificationType {
  success,
  error,
  info,
}

class AppNotification {
  AppNotification._();

  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppNotificationType type = AppNotificationType.info,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (_activeEntry != null && _activeEntry!.mounted) {
      _activeEntry!.remove();
      _activeEntry = null;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CenterPopupNotificationWidget(
        message: message,
        title: title ?? _defaultTitle(type),
        type: type,
        duration: duration,
        onDismissed: () {
          if (entry.mounted) {
            entry.remove();
          }
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title = 'Berhasil',
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title = 'Perhatian',
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title = 'Informasi',
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.info,
      duration: duration,
    );
  }

  static String _defaultTitle(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return 'Berhasil';
      case AppNotificationType.error:
        return 'Perhatian';
      case AppNotificationType.info:
        return 'Informasi';
    }
  }
}

class _CenterPopupNotificationWidget extends StatefulWidget {
  const _CenterPopupNotificationWidget({
    required this.message,
    required this.type,
    required this.onDismissed,
    this.title,
    this.duration = const Duration(seconds: 5),
  });

  final String message;
  final String? title;
  final AppNotificationType type;
  final VoidCallback onDismissed;
  final Duration duration;

  @override
  State<_CenterPopupNotificationWidget> createState() =>
      _CenterPopupNotificationWidgetState();
}

class _CenterPopupNotificationWidgetState
    extends State<_CenterPopupNotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _cardScaleAnimation;
  late final Animation<double> _circleScaleAnimation;
  late final Animation<double> _checkAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _circleScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.12, 0.58, curve: Curves.easeOutBack),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _animController.forward();

    _timer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    _timer?.cancel();
    if (mounted) {
      _animController.reverse().then((_) {
        widget.onDismissed();
      });
    } else {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color get _buttonColor {
    switch (widget.type) {
      case AppNotificationType.success:
        return const Color(0xFF084E38);
      case AppNotificationType.error:
        return const Color(0xFFDC2626);
      case AppNotificationType.info:
        return const Color(0xFF084E38);
    }
  }

  Color get _titleColor {
    switch (widget.type) {
      case AppNotificationType.success:
        return const Color(0xFF084E38);
      case AppNotificationType.error:
        return const Color(0xFFDC2626);
      case AppNotificationType.info:
        return const Color(0xFF084E38);
    }
  }

  Color get _iconBgColor {
    switch (widget.type) {
      case AppNotificationType.success:
        return const Color(0xFFE8F5E9);
      case AppNotificationType.error:
        return const Color(0xFFFEF2F2);
      case AppNotificationType.info:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case AppNotificationType.success:
        return const Color(0xFF084E38);
      case AppNotificationType.error:
        return const Color(0xFFDC2626);
      case AppNotificationType.info:
        return const Color(0xFF084E38);
    }
  }

  IconData get _iconData {
    switch (widget.type) {
      case AppNotificationType.success:
        return Icons.check_rounded;
      case AppNotificationType.error:
        return Icons.error_outline_rounded;
      case AppNotificationType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == AppNotificationType.success;

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
              Center(
                child: ScaleTransition(
                  scale: _cardScaleAnimation,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 320),
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      isSuccess ? 28 : 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _circleScaleAnimation,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: _iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: isSuccess
                                ? AnimatedBuilder(
                                    animation: _checkAnimation,
                                    builder: (context, _) {
                                      return CustomPaint(
                                        painter: _AnimatedCheckmarkPainter(
                                          progress: _checkAnimation.value,
                                          color: _iconColor,
                                        ),
                                      );
                                    },
                                  )
                                : Icon(
                                    _iconData,
                                    size: 32,
                                    color: _iconColor,
                                  ),
                          ),
                        ),
                        if (widget.title != null &&
                            widget.title!.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            widget.title!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: _titleColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                        if (!isSuccess) ...[
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _dismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Oke',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheckmarkPainter extends CustomPainter {
  _AnimatedCheckmarkPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p1 = Offset(size.width * 0.28, size.height * 0.52);
    final p2 = Offset(size.width * 0.44, size.height * 0.68);
    final p3 = Offset(size.width * 0.73, size.height * 0.36);

    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    final firstSegmentLength = (p2 - p1).distance;
    final secondSegmentLength = (p3 - p2).distance;
    final totalLength = firstSegmentLength + secondSegmentLength;
    final currentLength = totalLength * progress.clamp(0.0, 1.0);

    if (currentLength <= firstSegmentLength) {
      final t = currentLength / firstSegmentLength;
      final currentPoint = Offset.lerp(p1, p2, t)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final remaining = currentLength - firstSegmentLength;
      final t = (remaining / secondSegmentLength).clamp(0.0, 1.0);
      final currentPoint = Offset.lerp(p2, p3, t)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedCheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
