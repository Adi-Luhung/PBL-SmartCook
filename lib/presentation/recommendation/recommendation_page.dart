import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/recommendation_card.dart';

/// Tab Rekomendasi — data masih dummy (belum query Content-Based
/// Filtering dari Supabase).
class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final Set<String> _bookmarked = {};

  static const _ingredients = ['Tahu', 'Telur', 'Bawang', 'Cabai'];

  static const _recipes = [
    (
      title: 'Tahu Telur Bumbu Kecap Pedas',
      matchedWith: 'Tahu, Telur, Bawang, Cabai',
      duration: 15,
      match: 95,
      steps: 3,
      isDiet: false,
    ),
    (
      title: 'Orak-Arik Telur Tahu Sehat',
      matchedWith: 'Tahu, Telur, Bawang',
      duration: 10,
      match: 85,
      steps: 2,
      isDiet: true,
    ),
    (
      title: 'Sambal Goreng Tahu Telur',
      matchedWith: 'Tahu, Telur, Cabai',
      duration: 20,
      match: 75,
      steps: 4,
      isDiet: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Rekomendasi untukmu', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text('Berdasarkan ${_ingredients.length} bahan dapurmu', style: AppTextStyles.bodyMuted),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _ingredients
                .map((name) => Chip(
                      label: Text(name, style: AppTextStyles.caption),
                      avatar: const Icon(Icons.check, size: 14, color: AppColors.primary),
                      backgroundColor: AppColors.inputFill,
                      side: BorderSide.none,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          ...List.generate(_recipes.length, (i) {
            final r = _recipes[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RecommendationCard(
                title: r.title,
                matchedWith: r.matchedWith,
                durationMinutes: r.duration,
                matchPercent: r.match,
                stepsCount: r.steps,
                isDiet: r.isDiet,
                bookmarked: _bookmarked.contains(r.title),
                onBookmarkTap: () => setState(() {
                  if (_bookmarked.contains(r.title)) {
                    _bookmarked.remove(r.title);
                  } else {
                    _bookmarked.add(r.title);
                  }
                }),
                onCookTap: () {},
              ),
            );
          }),
        ],
      ),
    );
  }
}
