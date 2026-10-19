import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cook_doc_service.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';

class RatingHasilMasakanPage extends StatefulWidget {
  const RatingHasilMasakanPage({
    super.key,
    required this.title,
    this.isDiet = false,
    this.calories = 380,
    this.portions = 1,
    this.imageAsset,
    this.imageUrl,
    this.onBottomNavTap,
  });

  final String title;
  final bool isDiet;
  final int calories;
  final int portions;
  final String? imageAsset;
  final String? imageUrl;
  final ValueChanged<int>? onBottomNavTap;

  @override
  State<RatingHasilMasakanPage> createState() => _RatingHasilMasakanPageState();
}

class _RatingHasilMasakanPageState extends State<RatingHasilMasakanPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();

  File? _selectedImageFile;
  double _rating = 5.0;

  final List<String> _availableTags = [
    'Rasa Pas',
    'Mudah Dibuat',
    'Porsi Sesuai',
  ];
  final Set<String> _selectedTags = {
    'Rasa Pas',
    'Mudah Dibuat',
    'Porsi Sesuai',
  };

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _notesController.removeListener(_onNotesChanged);
    _notesController.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    setState(() {});
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  String get _ratingDescription {
    if (_rating >= 4.5) return 'Sangat Lezat & Sesuai Ekspektasi';
    if (_rating >= 3.5) return 'Lezat & Memuaskan';
    if (_rating >= 2.5) return 'Cukup Baik & Bisa Dinikmati';
    if (_rating >= 1.5) return 'Kurang Sesuai Selera';
    return 'Perlu Banyak Perbaikan';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (_) {}
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF084E38)),
                  title: const Text(
                    'Ambil Foto dari Kamera',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF084E38)),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onFinish() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final shortDate = '${now.day} ${months[now.month - 1]}';

    CookDocService.instance.addCookDoc(
      CookDocItem(
        name: widget.title,
        time: 'Hari ini, $shortDate',
        photoPath: _selectedImageFile?.path,
        rating: _rating,
        tags: _selectedTags.toList(),
        notes: _notesController.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dokumentasi masak berhasil disimpan ke jurnal dapur!'),
        backgroundColor: Color(0xFF084E38),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFA7F3D0),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF065F46),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selesai Memasak!',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Abadikan kreasi lezatmu ke dalam jurnal dapur.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfoCard() {
    final categoryText = widget.isDiet ? 'Diet Sehat' : 'Non-Diet';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoryText,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
              Text(
                _getFormattedDate(),
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: Color(0xFFEA580C),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.calories} kkal',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.restaurant_rounded,
                size: 15,
                color: Color(0xFF084E38),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.portions} Porsi',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE2EBF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_selectedImageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _selectedImageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            if (_selectedImageFile == null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 34,
                      color: Color(0xFF084E38),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Foto Hasil Masakan',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Ketuk untuk mengambil atau memilih foto',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Ketuk untuk Ganti Foto',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 13,
                      color: Color(0xFF0F172A),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Foto Utama',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
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
              const Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    size: 20,
                    color: Color(0xFFC2410C),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Rating Hasil Masakan',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_rating.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Bagaimana rasa dan tingkat keberhasilan resep ini?',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isFilled = starValue <= _rating.round();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = starValue.toDouble();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: const Color(0xFF9A3412),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  _ratingDescription,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check,
                          size: 13,
                          color: Color(0xFF065F46),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        tag,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF065F46)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 22,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Catatan Dapur Pribadi',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                'Opsional',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              maxLength: 200,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: Color(0xFF0F172A),
                height: 1.45,
              ),
              decoration: const InputDecoration.collapsed(
                hintText:
                    'Brokoli ditambah sedikit wijen sangrai, dressing jeruk nipis pas dan segar...',
                hintStyle: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  height: 1.45,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_notesController.text.length}/200',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _onFinish,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF084E38),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Selesai',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 22,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Resep',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1.2,
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildTopBanner(),
            const SizedBox(height: 16),
            _buildRecipeInfoCard(),
            const SizedBox(height: 16),
            _buildPhotoSection(),
            const SizedBox(height: 16),
            _buildRatingSection(),
            const SizedBox(height: 16),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildFinishButton(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (widget.onBottomNavTap != null) {
            widget.onBottomNavTap!(index);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
