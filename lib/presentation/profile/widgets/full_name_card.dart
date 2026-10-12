import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';

class FullNameCard extends StatelessWidget {
  const FullNameCard({super.key});

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
      child: const AppTextField(
        label: 'Nama Lengkap',
        trailingLabel: 'Opsional',
        initialValue: 'Heisenberg',
        fillColor: AppColors.inputNeutral,
        readOnly: true,
      ),
    );
  }
}
