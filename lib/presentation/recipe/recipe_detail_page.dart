import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';
import '../common/actions.dart';

/// Detail resep: bahan, langkah, bookmark, dan unggah foto hasil masak
/// dari galeri.
class RecipeDetailPage extends ConsumerWidget {
  const RecipeDetailPage({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(recipeDetailProvider(recipeId));
    final saved = (ref.watch(bookmarkProvider).value ?? <int>{}).contains(recipeId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.primary),
            onPressed: () => toggleBookmark(context, ref, recipeId),
          ),
        ],
      ),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gagal memuat resep.', style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Coba Lagi',
                    fullWidth: false,
                    onPressed: () =>
                        ref.invalidate(recipeDetailProvider(recipeId)),
                  ),
                ],
              ),
            ),
          ),
          data: (r) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(r.title, style: AppTextStyles.h1),
              if (r.category != null) ...[
                const SizedBox(height: 4),
                Text('Kategori: ${titleCase(r.category!)}',
                    style: AppTextStyles.bodyMuted),
              ],
              if (r.kalori != null) ...[
                const SizedBox(height: 16),
                _NutritionCard(detail: r),
              ],
              const SizedBox(height: 20),
              Text('Bahan (${r.ingredients.length})', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: r.ingredients
                    .map((name) => Chip(
                          label: Text(titleCase(name), style: AppTextStyles.caption),
                          backgroundColor: AppColors.inputFill,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Langkah (${r.steps.length})', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              for (var i = 0; i < r.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryLight,
                        child: Text('${i + 1}',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primaryDark)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(r.steps[i], style: AppTextStyles.body)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Dokumentasikan Masakan',
                icon: Icons.photo_library_outlined,
                iconLeading: true,
                variant: AppButtonVariant.outline,
                onPressed: () =>
                    pickAndUploadCookDoc(context, ref, recipeId: recipeId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Kartu perkiraan gizi. Nilainya total seluruh bahan resep, bukan per porsi,
/// jadi ditampilkan juga kepadatan per 100 g sebagai pembanding antar resep.
class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.detail});

  final RecipeDetail detail;

  static String _n(double v) => v
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  Widget build(BuildContext context) {
    final kalori = detail.kalori!;
    final berat = detail.beratG;
    final per100 = (berat != null && berat > 0) ? kalori / berat * 100 : null;

    Widget tile(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perkiraan Gizi', style: AppTextStyles.label),
          const SizedBox(height: 2),
          Text('Total seluruh bahan resep (bukan per porsi)',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            children: [
              tile(_n(kalori), 'kkal'),
              if (detail.proteinG != null) tile('${_n(detail.proteinG!)} g', 'protein'),
              if (detail.lemakG != null) tile('${_n(detail.lemakG!)} g', 'lemak'),
              if (detail.karboG != null) tile('${_n(detail.karboG!)} g', 'karbo'),
            ],
          ),
          if (per100 != null || berat != null) ...[
            const SizedBox(height: 10),
            Text(
              [
                if (per100 != null) '≈ ${_n(per100)} kkal per 100 g',
                if (berat != null) 'berat bahan ≈ ${_n(berat)} g',
              ].join(' • '),
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
