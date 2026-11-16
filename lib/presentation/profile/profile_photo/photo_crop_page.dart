import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Halaman crop foto profil — mekanisme natural seperti WhatsApp & Instagram:
/// - Foto asli ditampilkan secara proporsional sesuai rasio aslinya (portrait/landscape/persegi).
/// - Tidak ada auto-crop atau resize paksa 1:1 saat gambar pertama kali dimuat.
/// - Lingkaran crop tetap berada di tengah layar sebagai panduan area avatar.
/// - Pengguna bebas menggeser (drag) dan memperbesar/memperkecil (pinch-to-zoom) foto di belakang lingkaran.
/// - Hasil crop disimpan dalam rasio 1:1 persegi berisi area di dalam lingkaran crop.
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
  double _currentCropDiameter = 300.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetTransform() {
    _transformController.value = Matrix4.identity();
  }

  /// Menyimpan area di dalam lingkaran crop ke dalam file 1:1 persegi resolusi tinggi (512x512).
  Future<void> _saveCroppedImage() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Gagal membaca area crop gambar');
      }

      // 1. Hitung pixelRatio agar hasil crop beresolusi tinggi (minimal 512x512 tajam)
      const outputSize = 512.0;
      final pixelRatio =
          (outputSize / _currentCropDiameter * 1.5).clamp(2.0, 4.0);

      final capturedImage = await boundary.toImage(pixelRatio: pixelRatio);
      final capturedW = capturedImage.width.toDouble();
      final capturedH = capturedImage.height.toDouble();

      // 3. Lingkaran crop selalu berada di tengah area editor
      final capturedCenterX = capturedW / 2;
      final capturedCenterY = capturedH / 2;
      final capturedRadius = (_currentCropDiameter * pixelRatio) / 2;

      // Area persegi sumber yang membungkus lingkaran crop di layar
      final srcSquare = Rect.fromCircle(
        center: Offset(capturedCenterX, capturedCenterY),
        radius: capturedRadius,
      );

      // 4. Render area terpilih ke kanvas persegi 1:1 (512x512)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawImageRect(
        capturedImage,
        srcSquare,
        const Rect.fromLTWH(0, 0, outputSize, outputSize),
        Paint()..filterQuality = FilterQuality.high,
      );
      capturedImage.dispose();

      final picture = recorder.endRecording();
      final croppedSquare =
          await picture.toImage(outputSize.round(), outputSize.round());

      // 5. Encode ke byte PNG
      final byteData =
          await croppedSquare.toByteData(format: ui.ImageByteFormat.png);
      croppedSquare.dispose();

      if (byteData == null) throw Exception('Gagal meng-encode gambar');

      // 6. Simpan ke berkas sementara
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D1110),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            _buildTopBar(context),

            // ── Area Editor Foto (Full Original Aspect Ratio + Circular Crop Overlay) ──
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final editorW = constraints.maxWidth;
                  final editorH = constraints.maxHeight;

                  // Diameter lingkaran crop di tengah layar (~85% lebar atau tinggi)
                  _currentCropDiameter =
                      min(editorW * 0.85, editorH * 0.85).clamp(220.0, 360.0);
                  final cropRadius = _currentCropDiameter / 2;
                  final centerOffset = Offset(editorW / 2, editorH / 2);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // ── Layer 1: Foto Asli yang Dapat Digeser & Di-Zoom ──
                      // RepaintBoundary menangkap seluruh area gambar yang telah digeser/di-zoom
                      RepaintBoundary(
                        key: _repaintKey,
                        child: ClipRect(
                          child: ColoredBox(
                            color: Colors.black,
                            child: InteractiveViewer(
                              transformationController: _transformController,
                              minScale: 0.4,
                              maxScale: 6.0,
                              boundaryMargin: EdgeInsets.all(
                                max(editorW, editorH) * 1.5,
                              ),
                              panEnabled: true,
                              scaleEnabled: true,
                              clipBehavior: Clip.none,
                              child: SizedBox(
                                width: editorW,
                                height: editorH,
                                child: Center(
                                  // Menampilkan gambar sesuai rasio aslinya (portrait/landscape/persegi)
                                  // tanpa distorsi dan tanpa crop awal 1:1 otomatis.
                                  child: Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Layer 2: Circular Crop Overlay (WhatsApp & Instagram Style) ──
                      // Ditempatkan di luar RepaintBoundary sehingga overlay tidak ikut tersimpan ke file foto.
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(editorW, editorH),
                          painter: _WhatsAppCropOverlayPainter(
                            circleCenter: centerOffset,
                            circleRadius: cropRadius,
                            overlayColor:
                                Colors.black.withValues(alpha: 0.62),
                            borderColor: Colors.white.withValues(alpha: 0.95),
                            borderWidth: 2.0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Bottom Controls ──
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Colors.white, size: 26),
            tooltip: 'Batal',
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Atur Foto Profil',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Pindahkan & perbesar foto',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white60,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded,
                color: Colors.white70, size: 24),
            tooltip: 'Kembalikan posisi awal',
            onPressed: _saving ? null : _resetTransform,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Teks Petunjuk Interaksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 15,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  'Geser untuk atur posisi • Cubit untuk zoom',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tombol Aksi
          Row(
            children: [
              // Tombol Reset Posisi
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _resetTransform,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
              const SizedBox(width: 12),

              // Tombol Gunakan Foto
              Expanded(
                flex: 3,
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
                  label: Text(_saving ? 'Menyimpan...' : 'Gunakan Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CustomPainter: Panduan Crop Lingkaran Gaya WhatsApp & Instagram
/// - Menghitamkan area di luar lingkaran crop (overlay gelap transparan).
/// - Lingkaran di tengah 100% jernih dan bening untuk membidik area avatar.
/// - Garis putih tegas membingkai batas lingkaran.
/// - Garis kisi halus (Rule of Thirds) di dalam lingkaran membantu presisi pemosisian objek/wajah.
class _WhatsAppCropOverlayPainter extends CustomPainter {
  const _WhatsAppCropOverlayPainter({
    required this.circleCenter,
    required this.circleRadius,
    required this.overlayColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final Offset circleCenter;
  final double circleRadius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Overlay gelap transparan di seluruh layar di luar lingkaran
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = overlayColor);

    // 2. Garis lingkaran pembatas profil (WhatsApp/Instagram style)
    canvas.drawCircle(
      circleCenter,
      circleRadius,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // 3. Garis kisi (Rule of Thirds) halus di dalam area lingkaran
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.clipPath(
      Path()
        ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius)),
    );

    final left = circleCenter.dx - circleRadius;
    final top = circleCenter.dy - circleRadius;
    final diameter = circleRadius * 2;
    final third = diameter / 3;

    canvas.drawLine(Offset(left + third, top),
        Offset(left + third, top + diameter), gridPaint);
    canvas.drawLine(Offset(left + third * 2, top),
        Offset(left + third * 2, top + diameter), gridPaint);
    canvas.drawLine(Offset(left, top + third),
        Offset(left + diameter, top + third), gridPaint);
    canvas.drawLine(Offset(left, top + third * 2),
        Offset(left + diameter, top + third * 2), gridPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppCropOverlayPainter old) =>
      old.circleCenter != circleCenter ||
      old.circleRadius != circleRadius ||
      old.overlayColor != overlayColor ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}
