import 'package:flutter/material.dart';

/// Palet warna SmartCook — hasil estimasi visual dari mockup Figma.
/// Buka Inspector di Figma untuk nilai hex persis, lalu update konstanta
/// di sini supaya 1:1 dengan desain aslinya.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0E6E4E);
  static const Color primaryDark = Color(0xFF0A5A40);
  static const Color primaryLight = Color(0xFFE3F5EA);

  // Neutral / teks
  static const Color textPrimary = Color(0xFF1F2A37);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Permukaan
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Colors.white;
  static const Color inputFill = Color(0xFFF1F2FA);
  static const Color border = Color(0xFFE5E7EB);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Badge netral (Non-Diet, dsb.)
  static const Color neutralBadgeBg = Color(0xFFF3F4F6);
  static const Color neutralBadgeText = Color(0xFF4B5563);
}
