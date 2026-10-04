import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/widgets/app_badge.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_text_field.dart';
import 'core/widgets/ingredient_chip.dart';
import 'core/widgets/recipe_card.dart';

class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  int _navIndex = 0;
  bool _bookmarked = false;
  final Set<String> _selected = {'Telur Ayam', 'Tahu Putih'};

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System')),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tombol', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          AppButton(label: 'Masuk', onPressed: () {}),
          const SizedBox(height: 8),
          AppButton(
            label: 'Daftar Sekarang',
            variant: AppButtonVariant.outline,
            onPressed: () {},
          ),
          const SizedBox(height: 24),
          Text('Input Field', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          const AppTextField(
            label: 'Email',
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline,
          ),
          const SizedBox(height: 12),
          const AppTextField(
            label: 'Kata Sandi',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          Text('Badge', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              DietBadge(isDiet: true),
              DietBadge(isDiet: false),
              AppBadge(
                label: '95% Cocok',
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Recipe Card', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          RecipeCard(
            title: 'Tahu Telur Bumbu Kecap Pedas',
            subtitle: 'Cocok: Tahu, Telur, Bawang, Cabai',
            durationMinutes: 15,
            matchPercent: 95,
            isDiet: false,
            bookmarked: _bookmarked,
            onBookmarkTap: () => setState(() => _bookmarked = !_bookmarked),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Text('Ingredient Chip & List', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selected
                .map((name) => SelectedIngredientChip(
                      label: name,
                      onRemove: () => _toggle(name),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          IngredientListItem(
            icon: Icons.egg_outlined,
            label: 'Telur Ayam',
            selected: _selected.contains('Telur Ayam'),
            onTap: () => _toggle('Telur Ayam'),
          ),
          const SizedBox(height: 8),
          IngredientListItem(
            icon: Icons.set_meal_outlined,
            label: 'Tempe',
            selected: _selected.contains('Tempe'),
            onTap: () => _toggle('Tempe'),
          ),
        ],
      ),
    );
  }
}
