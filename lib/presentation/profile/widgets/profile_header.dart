import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Logo (Rata kanan)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Smart',
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  TextSpan(
                    text: 'Cook',
                    style: TextStyle(color: AppColors.profilePrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Judul & Subjudul
        Text(
          'Lengkapi Profil Kamu',
          style: AppTextStyles.h1.copyWith(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan data fisik Anda di bawah ini untuk mendapatkan analisis BMI dan estimasi kalori harian yang akurat.',
          style: AppTextStyles.body.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSlate,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
