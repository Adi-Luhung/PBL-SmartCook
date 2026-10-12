import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StepperCard extends StatelessWidget {
  final String label;
  final Widget? icon;
  final String value;
  final String? unit;
  final bool isLargeValue;

  const StepperCard({
    super.key,
    required this.label,
    this.icon,
    required this.value,
    this.unit,
    this.isLargeValue = false,
  });

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
          // Baris Atas: Label & Nilai
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (!isLargeValue)
                Text(
                  unit != null ? '$value $unit' : value,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.profilePrimary,
                  ),
                )
              else
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.profilePrimary,
                        ),
                      ),
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris Stepper: [-] [value] [+]
          Row(
            children: [
              // Tombol Minus
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.inputNeutral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.remove,
                    size: 20,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Kotak Angka di Tengah
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.inputNeutral,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      value,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Tombol Plus
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.inputNeutral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: AppColors.textDark,
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
