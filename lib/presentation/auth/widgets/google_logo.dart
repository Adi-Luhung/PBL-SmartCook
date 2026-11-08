import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final bluePath = Path()
      ..moveTo(23.745, 12.27)
      ..cubicTo(23.745, 11.47, 23.68, 10.7, 23.55, 9.96)
      ..lineTo(12.0, 9.96)
      ..lineTo(12.0, 14.47)
      ..lineTo(18.6, 14.47)
      ..cubicTo(18.31, 15.99, 17.46, 17.27, 16.2, 18.12)
      ..lineTo(16.2, 21.15)
      ..lineTo(20.08, 21.15)
      ..cubicTo(22.35, 19.06, 23.745, 15.98, 23.745, 12.27)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final greenPath = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.95, 22.92, 19.93, 21.09)
      ..lineTo(16.05, 18.06)
      ..cubicTo(14.97, 18.78, 13.6, 19.22, 12.0, 19.22)
      ..cubicTo(8.88, 19.22, 6.23, 17.12, 5.28, 14.29)
      ..lineTo(1.25, 14.29)
      ..lineTo(1.25, 17.42)
      ..cubicTo(3.27, 21.43, 7.33, 24.0, 12.0, 24.0)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(5.28, 14.29)
      ..cubicTo(5.03, 13.57, 4.9, 12.8, 4.9, 12.0)
      ..cubicTo(4.9, 11.2, 5.03, 10.43, 5.28, 9.71)
      ..lineTo(5.28, 6.58)
      ..lineTo(1.25, 6.58)
      ..cubicTo(0.45, 8.16, 0.0, 10.0, 0.0, 12.0)
      ..cubicTo(0.0, 14.0, 0.45, 15.84, 1.25, 17.42)
      ..lineTo(5.28, 14.29)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(12.0, 4.75)
      ..cubicTo(13.77, 4.75, 15.35, 5.36, 16.6, 6.55)
      ..lineTo(20.02, 3.13)
      ..cubicTo(17.95, 1.19, 15.24, 0.0, 12.0, 0.0)
      ..cubicTo(7.33, 0.0, 3.27, 2.57, 1.25, 6.58)
      ..lineTo(5.28, 9.71)
      ..cubicTo(6.23, 6.88, 8.88, 4.75, 12.0, 4.75)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
