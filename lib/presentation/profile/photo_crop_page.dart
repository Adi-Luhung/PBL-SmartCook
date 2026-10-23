import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Halaman crop foto profil — gaya Instagram:
/// - Lingkaran tetap di tengah layar.
/// - Gambar bisa di-pan & zoom (geser & perbesar/kecilkan).
/// - "Gunakan Foto" menyimpan area di dalam lingkaran.
class PhotoCropPage extends StatefulWidget {
  const PhotoCropPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<PhotoCropPage> createState() => _PhotoCropPageState();
}

class _PhotoCropPageState extends State<PhotoCropPage> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformController =
      TransformationController();

  bool _saving = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Capture seluruh layar (hanya area gambar), lalu crop bagian lingkaran
  /// di tengah ke dalam file PNG baru.
  Future<void> _saveCroppedImage() async {
    setState(() => _saving = true);
    try {
      // 1. Capture area gambar dari RepaintBoundary.
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      // pixelRatio 3 = resolusi tinggi
      final fullImage = await boundary.toImage(pixelRatio: 3.0);
      final imgW = fullImage.width.toDouble();
      final imgH = fullImage.height.toDouble();

      // 2. Hitung area lingkaran di dalam gambar yang di-capture.
      //    Lingkaran di UI = 85% lebar layar, selalu di tengah.
      //    Di captured image (pixelRatio=3) lebarnya juga 85% dari imgW.
      final cropDiameter = imgW * 0.85;
      final cropRadius = cropDiameter / 2;
      final centerX = imgW / 2;
      final centerY = imgH / 2;

      const outputSize = 512.0;

      // 3. Gambar area lingkaran ke canvas output.
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Clip lingkaran
      canvas.clipPath(
        Path()
          ..addOval(Rect.fromCircle(
            center: const Offset(outputSize / 2, outputSize / 2),
            radius: outputSize / 2,
          )),
      );

      // Ambil bagian gambar yang ada di dalam lingkaran
      canvas.drawImageRect(
        fullImage,
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: cropDiameter,
          height: cropDiameter,
        ),
        const Rect.fromLTWH(0, 0, outputSize, outputSize),
        Paint()..filterQuality = FilterQuality.high,
      );
      fullImage.dispose();

      final picture = recorder.endRecording();
      final croppedImage =
          await picture.toImage(outputSize.round(), outputSize.round());

      // 4. Encode ke PNG.
      final byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      croppedImage.dispose();

      if (byteData == null) throw Exception('Gagal encode gambar');

      // 5. Simpan ke file.
      final tempDir = Directory.systemTemp;
      final fileName =
          'profile_crop_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${tempDir.path}/$fileName');
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) Navigator.of(context).pop(outputFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final circleRadius = screenSize.width * 0.425; // ~85% lebar

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Layer 1: Gambar interaktif (bisa pan & zoom) ──
          Positioned.fill(
            child: RepaintBoundary(
              key: _repaintKey,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 8.0,
                constrained: true,
                child: SizedBox.expand(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 2: Overlay transparan + lingkaran tetap di tengah ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CropOverlayPainter(
                  radius: circleRadius,
                  overlayColor: Colors.black.withOpacity(0.52),
                  borderColor: Colors.white,
                  borderWidth: 2.0,
                ),
              ),
            ),
          ),

          // ── Layer 3: AppBar transparan ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 26),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                    const Spacer(),
                    Text(
                      'Atur Foto Profil',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // ── Layer 4: Hint teks ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 145,
            child: IgnorePointer(
              child: Text(
                'Geser & perbesar foto untuk mengatur posisi',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          // ── Layer 5: Tombol aksi ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  children: [
                    // Tombol Reset
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving
                            ? null
                            : () {
                                _transformController.value =
                                    Matrix4.identity();
                              },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Tombol Gunakan
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveCroppedImage,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 20),
                        label: Text(
                            _saving ? 'Menyimpan...' : 'Gunakan Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter: overlay gelap dengan lubang lingkaran tetap di tengah.
class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({
    required this.radius,
    required this.overlayColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final double radius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Overlay gelap dengan lubang lingkaran di tengah
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);

    // Border lingkaran
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter old) => false;
}
