import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Chip bahan yang sudah dipilih (mis. "Telur Ayam ×"),
/// dipakai di baris "Bahan Terpilih" pada halaman Input Bahan.
class SelectedIngredientChip extends StatelessWidget {
  const SelectedIngredientChip({super.key, required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

/// Item bahan yang bisa dicentang di grid/list kategori
/// (mis. "Protein & Lauk" → Telur Ayam, Tahu Putih, Tempe).
class IngredientListItem extends StatelessWidget {
  const IngredientListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.primaryDark : AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            if (selected) const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
