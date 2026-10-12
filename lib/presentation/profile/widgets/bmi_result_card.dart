import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';
import 'bmi_progress_bar.dart';

class BmiResultCard extends StatelessWidget {
  const BmiResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Label & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HASIL ANALISIS BMI',
                style: AppTextStyles.label.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralBadgeText,
                  letterSpacing: 0.3,
                ),
              ),
              AppBadge(
                label: 'Ideal / Normal',
                backgroundColor: AppColors.profilePrimaryLight,
                textColor: AppColors.profilePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                leading: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.profilePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scores Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Kiri: Skor Indeks Anda
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skor Indeks Anda',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSlate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '21.3',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'kg/m²',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Kanan: Rentang Normal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rentang Normal',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '18.5 – 24.9',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Segmented Progress Bar dengan Marker
          const BmiProgressBar(),
          const SizedBox(height: 16),

          // Kotak Estimasi Kalori Harian
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputNeutral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_outlined,
                      size: 16,
                      color: AppColors.textSlate,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Est. Kalori Harian',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '~1.829',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'kkal/hari (TDEE)',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
