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
  static const Color profilePrimary = Color(0xFF0B6B4A);
  static const Color profilePrimaryLight = Color(0xFFD1FAE5);

  // Neutral / teks
  static const Color textPrimary = Color(0xFF1F2A37);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSlate = Color(0xFF64748B);
  static const Color textSlateDark = Color(0xFF334155);
  static const Color textMutedSlate = Color(0xFF94A3B8);

  // Permukaan
  static const Color background = Color(0xFFF8F9FC);
  static const Color profileBackground = Color(0xFFF8FAFB);
  static const Color surface = Colors.white;
  static const Color inputFill = Color(0xFFF1F2FA);
  static const Color inputNeutral = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFE5E7EB);
  static const Color cardBorder = Color(0xFFF1F5F9);
  static const Color outlineBorder = Color(0xFFE2E8F0);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Badge netral (Non-Diet, dsb.)
  static const Color neutralBadgeBg = Color(0xFFF3F4F6);
  static const Color neutralBadgeText = Color(0xFF4B5563);

  // BMI Progress Bar segmen
  static const Color bmiUnderweight = Color(0xFFBAC7E8);
  static const Color bmiNormal = Color(0xFF00B27A);
  static const Color bmiOverweight = Color(0xFF6EE7B7);
  static const Color bmiObese = Color(0xFFFECDD3);
}
