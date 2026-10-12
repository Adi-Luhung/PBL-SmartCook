import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BmiProgressBar extends StatelessWidget {
  const BmiProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Marker diameter 12, posisikan di segmen hijau (kiri-tengah, ~28% dari lebar total)
        final markerLeft = (totalWidth * 0.28) - 6;

        return SizedBox(
          height: 14,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              // 4 segmen berwarna berurutan dengan ujung rounded
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 8,
                  width: double.infinity,
                  child: Row(
                    children: [
                      // 1. Kurus: biru keunguan pudar
                      Expanded(
                        flex: 22,
                        child: Container(
                          height: 8,
                          color: AppColors.bmiUnderweight,
                        ),
                      ),
                      // 2. Normal: hijau
                      Expanded(
                        flex: 31,
                        child: Container(
                          height: 8,
                          color: AppColors.bmiNormal,
                        ),
                      ),
                      // 3. Normal atas / berlebih: hijau muda
                      Expanded(
                        flex: 18,
                        child: Container(
                          height: 8,
                          color: AppColors.bmiOverweight,
                        ),
                      ),
                      // 4. Obesitas: merah muda
                      Expanded(
                        flex: 29,
                        child: Container(
                          height: 8,
                          color: AppColors.bmiObese,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Marker bulat gelap
              Positioned(
                left: markerLeft,
                top: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.textDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
