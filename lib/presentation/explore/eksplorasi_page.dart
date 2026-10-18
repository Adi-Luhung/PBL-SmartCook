import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

/// Halaman placeholder untuk Tab Eksplorasi (katalog resep umum tanpa input bahan).
class EksplorasiPage extends StatelessWidget {
  const EksplorasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar konsisten dengan logo SmartCook & Avatar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Smart',
                          style: TextStyle(color: Color(0xFF0F172A)),
                        ),
                        TextSpan(
                          text: 'Cook',
                          style: TextStyle(color: Color(0xFF084E38)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Konten placeholder Eksplorasi Resep
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F7F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.explore_outlined,
                          size: 40,
                          color: Color(0xFF084E38),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Eksplorasi Resep',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Katalog dan eksplorasi seluruh resep masakan tanpa batasan bahan sedang disiapkan untukmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFF475569)),
                            SizedBox(width: 6),
                            Text(
                              'Segera Hadir',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
