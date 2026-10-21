import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/app_providers.dart';
import 'widgets/profile_header.dart';

// ─────────────────────────────────────────────────
// Model data aktivitas harian
// ─────────────────────────────────────────────────
class _ActivityOption {
  final String title;
  final String subtitle;
  final double multiplier;

  const _ActivityOption({
    required this.title,
    required this.subtitle,
    required this.multiplier,
  });
}

const _activities = [
  _ActivityOption(
    title: 'Jarang Bergerak',
    subtitle: 'Pekerjaan meja, hampir tidak pernah olahraga',
    multiplier: 1.2,
  ),
  _ActivityOption(
    title: 'Aktivitas Ringan',
    subtitle: 'Olahraga santai 1–3 kali seminggu',
    multiplier: 1.375,
  ),
  _ActivityOption(
    title: 'Aktivitas Sedang',
    subtitle: 'Olahraga rutin 3–5 kali seminggu',
    multiplier: 1.55,
  ),
  _ActivityOption(
    title: 'Sangat Aktif',
    subtitle: 'Olahraga berat atau atlet 6–7 kali seminggu',
    multiplier: 1.725,
  ),
];

// ─────────────────────────────────────────────────
// Halaman Lengkapi Profil — StatefulWidget
// ─────────────────────────────────────────────────
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  // Form state
  final _nameController = TextEditingController();
  String _gender = 'Perempuan'; // 'Laki-laki' atau 'Perempuan'
  int _age = 24;
  int _height = 165; // cm
  int _weight = 58; // kg
  int _activityIndex = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Isi formulir dengan profil yang sudah tersimpan (kalau ada).
    final p = ref.read(profileProvider).value;
    if (p != null) {
      _nameController.text = p.fullName ?? '';
      if (p.gender != null) _gender = p.gender!;
      if (p.age != null) _age = p.age!;
      if (p.heightCm != null) _height = p.heightCm!.round();
      if (p.weightKg != null) _weight = p.weightKg!.round();
      if (p.activityLevel != null) {
        _activityIndex = p.activityLevel!.clamp(0, _activities.length - 1);
      }
    }
  }

  // ── Kalkulasi BMI ──────────────────────────────
  double get _bmi {
    final h = _height / 100.0;
    return _weight / (h * h);
  }

  // ── Kalkulasi BMR (Mifflin-St Jeor) ──────────
  double get _bmr {
    if (_gender == 'Laki-laki') {
      return 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      return 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }
  }

  // ── TDEE = BMR × Activity Multiplier ─────────
  double get _tdee => _bmr * _activities[_activityIndex].multiplier;

  // ── Kategori BMI ──────────────────────────────
  String get _bmiCategory {
    if (_bmi < 18.5) return 'Kurang';
    if (_bmi < 25.0) return 'Ideal / Normal';
    if (_bmi < 30.0) return 'Berlebih';
    return 'Obesitas';
  }

  Color get _bmiColor {
    if (_bmi < 18.5) return AppColors.bmiUnderweight;
    if (_bmi < 25.0) return AppColors.bmiNormal;
    if (_bmi < 30.0) return AppColors.bmiOverweight;
    return AppColors.bmiObese;
  }

  // ── Target kalori harian: TDEE disesuaikan dengan kategori BMI ──
  // Kurang: +300 (naik berat), Ideal: TDEE, Berlebih: −300, Obesitas: −500.
  // Tidak pernah di bawah BMR.
  int get _targetKkal {
    final double adjusted;
    if (_bmi < 18.5) {
      adjusted = _tdee + 300;
    } else if (_bmi < 25.0) {
      adjusted = _tdee;
    } else if (_bmi < 30.0) {
      adjusted = _tdee - 300;
    } else {
      adjusted = _tdee - 500;
    }
    return max(adjusted, _bmr).round();
  }

  String get _targetNote {
    if (_bmi < 18.5) return 'Surplus 300 kkal untuk menambah berat badan';
    if (_bmi < 25.0) return 'Sama dengan kebutuhan harian (menjaga berat badan)';
    if (_bmi < 30.0) return 'Defisit 300 kkal untuk menurunkan berat badan';
    return 'Defisit 500 kkal untuk menurunkan berat badan';
  }

  Future<void> _save() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).saveProfile(
            userId: uid,
            fullName: _nameController.text.trim(),
            gender: _gender,
            age: _age,
            weightKg: _weight.toDouble(),
            heightCm: _height.toDouble(),
            targetKkal: _targetKkal,
            activityLevel: _activityIndex,
          );
      ref.invalidate(profileProvider);
      messenger.showSnackBar(SnackBar(
        content: Text(
            'Profil tersimpan. Target kalori harian: ${_formatNumber(_targetKkal)} kkal'),
      ));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Gagal menyimpan profil. Periksa koneksi lalu coba lagi.'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Posisi marker pada progress bar (0.0–1.0)
  // BMI 10–40 dijadikan skala
  double get _bmiMarkerPosition {
    const min = 10.0;
    const max = 40.0;
    return ((_bmi - min) / (max - min)).clamp(0.02, 0.98);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _nameController.text = '';
      _gender = 'Laki-laki';
      _age = 25;
      _height = 170;
      _weight = 65;
      _activityIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 36,
          ),
          children: [
            // 1. Header Logo & Judul
            const ProfileHeader(),
            const SizedBox(height: 20),

            // 2. Nama Lengkap (inline, tanpa card)
            _buildNameField(),
            const SizedBox(height: 14),

            // 3. Jenis Kelamin
            _buildGenderSelector(),
            const SizedBox(height: 14),

            // 4. Metrik Fisik (Umur, Tinggi, Berat dalam satu card)
            _buildPhysicalMetrics(),
            const SizedBox(height: 14),

            // 5. Aktivitas Harian
            _buildActivitySection(),
            const SizedBox(height: 20),

            // 6. Hasil Analisis BMI (real-time)
            _buildBmiResultCard(),
            const SizedBox(height: 20),

            // 7. Tombol Simpan Profil
            AppButton(
              label: 'Simpan Profil',
              icon: Icons.check_circle_outline_rounded,
              iconLeading: true,
              backgroundColor: AppColors.profilePrimary,
              borderRadius: 14,
              height: 50,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 12),

            // 8. Tombol Reset
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
              onPressed: _reset,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Nama Lengkap
  // ─────────────────────────────────────────────
  Widget _buildNameField() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Lengkap',
                style: AppTextStyles.label.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Opsional',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMutedSlate,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              fillColor: AppColors.inputNeutral,
              filled: true,
              hintText: 'Masukkan nama lengkap',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.profilePrimary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Jenis Kelamin
  // ─────────────────────────────────────────────
  Widget _buildGenderSelector() {
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
          Text(
            'Jenis Kelamin',
            style: AppTextStyles.label.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _GenderButton(
                label: 'Laki-laki',
                icon: Icons.male_rounded,
                selected: _gender == 'Laki-laki',
                onTap: () => setState(() => _gender = 'Laki-laki'),
              ),
              const SizedBox(width: 12),
              _GenderButton(
                label: 'Perempuan',
                icon: Icons.female_rounded,
                selected: _gender == 'Perempuan',
                onTap: () => setState(() => _gender = 'Perempuan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Metrik Fisik (3-in-1 card)
  // ─────────────────────────────────────────────
  Widget _buildPhysicalMetrics() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metrik Fisik',
                style: AppTextStyles.label.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Ketik angka langsung',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMutedSlate,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricColumn(
                label: 'Umur',
                value: _age,
                unit: 'th',
                onChanged: (v) => setState(() => _age = v),
                min: 1,
                max: 120,
              ),
              _buildVerticalDivider(),
              _MetricColumn(
                label: 'Tinggi',
                value: _height,
                unit: 'cm',
                onChanged: (v) => setState(() => _height = v),
                min: 50,
                max: 250,
              ),
              _buildVerticalDivider(),
              _MetricColumn(
                label: 'Berat',
                value: _weight,
                unit: 'kg',
                onChanged: (v) => setState(() => _weight = v),
                min: 1,
                max: 300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 64,
      color: AppColors.cardBorder,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Aktivitas Harian
  // ─────────────────────────────────────────────
  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Harian',
          style: AppTextStyles.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Memengaruhi kalkulasi Total Daily Energy (TDEE)',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.profilePrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_activities.length, (i) {
          final act = _activities[i];
          final selected = _activityIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ActivityTile(
              title: act.title,
              subtitle: act.subtitle,
              selected: selected,
              onTap: () => setState(() => _activityIndex = i),
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Hasil Analisis BMI (real-time)
  // ─────────────────────────────────────────────
  Widget _buildBmiResultCard() {
    final bmiStr = _bmi.toStringAsFixed(1);
    // Format dengan titik ribuan
    final tdeeFormatted = _formatNumber(_tdee.round());

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
                'ANALISIS BMI TERKINI',
                style: AppTextStyles.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralBadgeText,
                  letterSpacing: 0.3,
                ),
              ),
              _BmiStatusBadge(category: _bmiCategory, color: _bmiColor),
            ],
          ),
          const SizedBox(height: 14),

          // Skor BMI & Rentang Normal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        bmiStr,
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'kg/m²',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Indeks Massa Tubuh Anda',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSlate,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rentang Normal',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textSlate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '18.5 – 24.9',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BMI Progress Bar dengan marker dinamis
          _BmiProgressBar(markerPosition: _bmiMarkerPosition),
          const SizedBox(height: 8),

          // Label Kategori bawah progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bmiLabel('Kurang', AppColors.bmiUnderweight),
              _bmiLabel('Ideal', AppColors.bmiNormal),
              _bmiLabel('Berlebih', AppColors.bmiOverweight),
              _bmiLabel('Obesitas', AppColors.bmiObese),
            ],
          ),
          const SizedBox(height: 16),

          // Kotak Estimasi Kalori
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputNeutral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Ikon api oranye
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimasi Kebutuhan Kalori',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSlate,
                        ),
                      ),
                      Text(
                        'TDEE Harian',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSlate,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '~$tdeeFormatted',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: ' kkal',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Kotak Target Kalori Harian (menentukan label Diet / Non-Diet resep)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: Color(0xFF059669), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Kalori Harian',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSlate,
                        ),
                      ),
                      Text(
                        _targetNote,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSlate,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '~${_formatNumber(_targetKkal)}',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: ' kkal',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bmiLabel(String text, Color color) {
    final isActive = _bmiCategory == text ||
        (text == 'Ideal' && _bmiCategory == 'Ideal / Normal');
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        color: isActive ? color : AppColors.textSlate,
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final result = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return result.toString();
  }
}

// ─────────────────────────────────────────────────
// Sub-widget: Tombol Gender
// ─────────────────────────────────────────────────
class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: selected ? AppColors.profilePrimary : AppColors.inputNeutral,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : AppColors.textSlate,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSlateDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Sub-widget: Kolom Metrik (umur/tinggi/berat)
// ─────────────────────────────────────────────────
class _MetricColumn extends StatefulWidget {
  final String label;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  @override
  State<_MetricColumn> createState() => _MetricColumnState();
}

class _MetricColumnState extends State<_MetricColumn> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _MetricColumn old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _increment() {
    if (widget.value < widget.max) widget.onChanged(widget.value + 1);
  }

  void _decrement() {
    if (widget.value > widget.min) widget.onChanged(widget.value - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            widget.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSlate,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Nilai + unit besar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Editable number
              IntrinsicWidth(
                child: TextField(
                  controller: _ctrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (s) {
                    final v = int.tryParse(s);
                    if (v != null && v >= widget.min && v <= widget.max) {
                      widget.onChanged(v);
                    }
                  },
                ),
              ),
              const SizedBox(width: 2),
              Text(
                widget.unit,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tombol +/−
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SmallStepBtn(icon: Icons.remove, onTap: _decrement),
              const SizedBox(width: 8),
              _SmallStepBtn(icon: Icons.add, onTap: _increment),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.inputNeutral,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Sub-widget: Tile Aktivitas dengan radio
// ─────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.profilePrimary
                : AppColors.outlineBorder,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.profilePrimary
                      : AppColors.textMutedSlate,
                  width: selected ? 0 : 1.5,
                ),
                color: selected ? AppColors.profilePrimary : Colors.transparent,
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.textSlate,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Sub-widget: Badge Status BMI
// ─────────────────────────────────────────────────
class _BmiStatusBadge extends StatelessWidget {
  final String category;
  final Color color;

  const _BmiStatusBadge({required this.category, required this.color});

  Color get _bgColor => color.withValues(alpha: 0.15);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color == AppColors.bmiUnderweight
                  ? const Color(0xFF3B5BDB)
                  : color == AppColors.bmiNormal
                      ? AppColors.profilePrimary
                      : color == AppColors.bmiOverweight
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Sub-widget: BMI Progress Bar dinamis
// ─────────────────────────────────────────────────
class _BmiProgressBar extends StatelessWidget {
  final double markerPosition; // 0.0–1.0

  const _BmiProgressBar({required this.markerPosition});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final markerLeft = totalWidth * markerPosition - 6;

        return SizedBox(
          height: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bar berwarna
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 22,
                          child: Container(color: AppColors.bmiUnderweight),
                        ),
                        Expanded(
                          flex: 31,
                          child: Container(color: AppColors.bmiNormal),
                        ),
                        Expanded(
                          flex: 18,
                          child: Container(color: AppColors.bmiOverweight),
                        ),
                        Expanded(
                          flex: 29,
                          child: Container(color: AppColors.bmiObese),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Marker bulat
              Positioned(
                left: markerLeft,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.textDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
