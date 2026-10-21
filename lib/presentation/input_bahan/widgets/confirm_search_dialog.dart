import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Modal dialog konfirmasi pencarian resep setelah input bahan
/// Sesuai dengan desain popup SmartCook.
class ConfirmSearchDialog extends StatelessWidget {
  const ConfirmSearchDialog({
    super.key,
    required this.onConfirmSearch,
    this.onAddMore,
  });

  final VoidCallback onConfirmSearch;
  final VoidCallback? onAddMore;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol 'X' di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Icon Wajan Memasak dengan Uap
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F7F0),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: _CookingPanIcon(
                  size: 34,
                  color: Color(0xFF084E38),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Judul
            const Text(
              'Cari Resep Sekarang?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Ada bahan masakan yang mau\nditambahkan sebelum mencari?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            // Tombol 1: Ya, Cari Resep ->
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmSearch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF084E38),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ya, Cari Resep',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol 2: + Tambah Bahan Lagi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAddMore?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF1E293B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18, color: Color(0xFF1E293B)),
                    SizedBox(width: 6),
                    Text(
                      'Tambah Bahan Lagi',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Icon wajan penggorengan dengan kepulan uap di atasnya
/// identik dengan ilustrasi pada desain modal SmartCook.
class _CookingPanIcon extends StatelessWidget {
  const _CookingPanIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CookingPanPainter(color),
      ),
    );
  }
}

class _CookingPanPainter extends CustomPainter {
  _CookingPanPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 3 garis uap di atas wajan
    // Uap kiri
    final steam1 = Path()
      ..moveTo(w * 0.28, h * 0.26)
      ..cubicTo(w * 0.22, h * 0.19, w * 0.34, h * 0.13, w * 0.28, h * 0.06);
    canvas.drawPath(steam1, paint);

    // Uap tengah
    final steam2 = Path()
      ..moveTo(w * 0.44, h * 0.26)
      ..cubicTo(w * 0.38, h * 0.19, w * 0.50, h * 0.13, w * 0.44, h * 0.06);
    canvas.drawPath(steam2, paint);

    // Uap kanan
    final steam3 = Path()
      ..moveTo(w * 0.60, h * 0.26)
      ..cubicTo(w * 0.54, h * 0.19, w * 0.66, h * 0.13, w * 0.60, h * 0.06);
    canvas.drawPath(steam3, paint);

    // Mangkuk / wajan
    final pan = Path()
      ..moveTo(w * 0.10, h * 0.44)
      ..lineTo(w * 0.14, h * 0.60)
      ..quadraticBezierTo(w * 0.18, h * 0.76, w * 0.32, h * 0.76)
      ..lineTo(w * 0.56, h * 0.76)
      ..quadraticBezierTo(w * 0.70, h * 0.76, w * 0.74, h * 0.60)
      ..lineTo(w * 0.78, h * 0.44)
      ..close();
    canvas.drawPath(pan, paint);

    // Gagang wajan mengarah ke kanan atas
    final handle = Path()
      ..moveTo(w * 0.78, h * 0.48)
      ..lineTo(w * 0.96, h * 0.36);
    canvas.drawPath(handle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
