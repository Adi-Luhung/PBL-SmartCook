import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/bmi_result_card.dart';
import 'widgets/full_name_card.dart';
import 'widgets/gender_selector.dart';
import 'widgets/profile_header.dart';
import 'widgets/stepper_card.dart';

/// Halaman Profil SmartCook — tampilan statis sesuai screenshot Figma.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: 36,
          ),
          children: [
            // 1. Header Logo & Judul
            const ProfileHeader(),
            const SizedBox(height: 20),

            // 2. Card Nama Lengkap
            const FullNameCard(),
            const SizedBox(height: 14),

            // 3. Card Jenis Kelamin
            const GenderSelector(),
            const SizedBox(height: 14),

            // 4. Card Umur
            const StepperCard(
              label: 'Umur',
              value: '24',
              unit: 'Tahun',
              isLargeValue: false,
            ),
            const SizedBox(height: 14),

            // 5. Card Tinggi Badan
            const StepperCard(
              label: 'Tinggi Badan',
              icon: Icon(
                Icons.height_rounded,
                size: 18,
                color: AppColors.textSlate,
              ),
              value: '165',
              unit: 'cm',
              isLargeValue: true,
            ),
            const SizedBox(height: 14),

            // 6. Card Berat Badan
            StepperCard(
              label: 'Berat Badan',
              icon: Transform.rotate(
                angle: -0.785398,
                child: const Icon(
                  Icons.swap_vert_rounded,
                  size: 18,
                  color: AppColors.textSlate,
                ),
              ),
              value: '58',
              unit: 'kg',
              isLargeValue: true,
            ),
            const SizedBox(height: 16),

            // 7. Tombol Simpan Profil
            AppButton(
              label: 'Simpan Profil',
              icon: Icons.check_circle_outline_rounded,
              iconLeading: true,
              backgroundColor: AppColors.profilePrimary,
              borderRadius: 14,
              height: 50,
              onPressed: () {},
            ),
            const SizedBox(height: 16),

            // 8. Card HASIL ANALISIS BMI
            const BmiResultCard(),
            const SizedBox(height: 14),

            // 9. Tombol Reset
            AppButton(
              label: 'Reset',
              variant: AppButtonVariant.outline,
              backgroundColor: AppColors.surface,
              textColor: AppColors.textDark,
              borderSide: const BorderSide(color: AppColors.outlineBorder),
              borderRadius: 14,
              height: 48,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
