import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/ingredient_chip.dart';

class _IngredientData {
  const _IngredientData(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _CategoryData {
  const _CategoryData(this.title, this.items);
  final String title;
  final List<_IngredientData> items;
}

const _categories = [
  _CategoryData('Protein & Lauk', [
    _IngredientData(Icons.egg_outlined, 'Telur Ayam'),
    _IngredientData(Icons.set_meal_outlined, 'Tahu Putih'),
    _IngredientData(Icons.set_meal_outlined, 'Tempe'),
    _IngredientData(Icons.lunch_dining_outlined, 'Daging Ayam'),
  ]),
  _CategoryData('Sayuran Segar', [
    _IngredientData(Icons.eco_outlined, 'Kangkung'),
    _IngredientData(Icons.eco_outlined, 'Bayam Hijau'),
  ]),
  _CategoryData('Bumbu Dapur', [
    _IngredientData(Icons.circle_outlined, 'Bawang Merah'),
    _IngredientData(Icons.local_fire_department_outlined, 'Cabai Rawit'),
    _IngredientData(Icons.circle_outlined, 'Bawang Putih'),
  ]),
];

/// Tab Input Bahan — pilih bahan manual, data masih dummy
/// (belum query ke Supabase).
class InputBahanPage extends StatefulWidget {
  const InputBahanPage({super.key});

  @override
  State<InputBahanPage> createState() => _InputBahanPageState();
}

class _InputBahanPageState extends State<InputBahanPage> {
  final Set<String> _selected = {'Telur Ayam', 'Tahu Putih', 'Bawang Merah', 'Cabai Rawit'};

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Kamu Punya Bahan Apa Aja?', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  'Pilih bahan yang ada di kulkasmu, kami temukan resep lezatnya.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ketik nama bahan... (misal: telur, tahu)',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                      const Icon(Icons.add_circle, size: 20, color: AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_selected.isNotEmpty) ...[
                  Row(
                    children: [
                      Text('Bahan Terpilih (${_selected.length})', style: AppTextStyles.label),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(_selected.clear),
                        child: Text(
                          'Hapus Semua',
                          style: AppTextStyles.caption.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selected
                        .map((label) => SelectedIngredientChip(
                              label: label,
                              onRemove: () => _toggle(label),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                ..._categories.map((category) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.title, style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 3.2,
                            children: category.items
                                .map((item) => IngredientListItem(
                                      icon: item.icon,
                                      label: item.label,
                                      selected: _selected.contains(item.label),
                                      onTap: () => _toggle(item.label),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Cari Resep (${_selected.length} Bahan)',
              icon: Icons.restaurant_menu,
              onPressed: _selected.isEmpty ? null : () {},
            ),
          ),
        ],
      ),
    );
  }
}
