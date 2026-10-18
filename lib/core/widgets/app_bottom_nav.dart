import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _NavItem {
  const _NavItem({
    this.icon,
    this.customIconBuilder,
    required this.label,
  });

  final IconData? icon;
  final Widget Function(Color color, double size)? customIconBuilder;
  final String label;
}

final _items = [
  const _NavItem(icon: Icons.home_outlined, label: 'Beranda'),
  const _NavItem(icon: Icons.explore_outlined, label: 'Eksplorasi'),
  _NavItem(
    customIconBuilder: (color, size) => InboxNavbarIcon(color: color, size: size),
    label: 'Input',
  ),
  const _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
];

/// Bottom nav 4-tab sesuai Figma: Beranda, Eksplorasi, Input, Profil.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == currentIndex;
              final color = active ? AppColors.primary : AppColors.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.customIconBuilder != null)
                        item.customIconBuilder!(color, 24)
                      else
                        Icon(item.icon, color: color, size: 24),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Icon baki / wadah 'Input' (Feather/Lucide style) sesuai dengan mockup Figma SmartCook.
class InboxNavbarIcon extends StatelessWidget {
  const InboxNavbarIcon({
    super.key,
    required this.color,
    this.size = 24,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _InboxNavbarIconPainter(color: color),
      ),
    );
  }
}

class _InboxNavbarIconPainter extends CustomPainter {
  const _InboxNavbarIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Garis luar wadah (trapesium atas + baki bawah)
    final outerPath = Path()
      ..moveTo(5.45, 5.11)
      ..lineTo(2.0, 12.0)
      ..lineTo(2.0, 18.0)
      ..arcToPoint(const Offset(4.0, 20.0),
          radius: const Radius.circular(2.0), clockwise: false)
      ..lineTo(20.0, 20.0)
      ..arcToPoint(const Offset(22.0, 18.0),
          radius: const Radius.circular(2.0), clockwise: false)
      ..lineTo(22.0, 12.0)
      ..lineTo(18.55, 5.11)
      ..arcToPoint(const Offset(16.76, 4.0),
          radius: const Radius.circular(2.0), clockwise: false)
      ..lineTo(7.24, 4.0)
      ..arcToPoint(const Offset(5.45, 5.11),
          radius: const Radius.circular(2.0), clockwise: false)
      ..close();

    // Garis lekukan (notch) depan baki
    final notchPath = Path()
      ..moveTo(2.0, 12.0)
      ..lineTo(8.0, 12.0)
      ..lineTo(10.0, 15.0)
      ..lineTo(14.0, 15.0)
      ..lineTo(16.0, 12.0)
      ..lineTo(22.0, 12.0);

    canvas.drawPath(outerPath, paint);
    canvas.drawPath(notchPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InboxNavbarIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
