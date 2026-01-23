import 'package:flutter/material.dart';

/// App Colors Constants
/// ألوان التطبيق
class AppColors {
  // Primary Colors - الألوان الأساسية
  static const Color primaryGreen = Color(0xFF457C3B); // Lighter fresh green
  static const Color primaryGreenLight = Color(
    0xFF66BB6A,
  ); // Even lighter green
  static const Color primaryGreenDark = Color(
    0xFF388E3C,
  ); // Slightly darker for gradients

  // Secondary Colors - الألوان الثانوية
  static const Color secondaryOrange = Color(0xFFFF6F00); // Orange accent
  static const Color secondaryPink = Color(0xFFE91E63); // Pink for fruits

  // Gradient Colors - ألوان التدرج
  static const Color gradientStart = Color(0xFF66BB6A); // Light green
  static const Color gradientEnd = Color(0xFF4CAF50); // Primary green

  // Text Colors - ألوان النصوص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Background Colors - ألوان الخلفية
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;

  // Status Colors - ألوان الحالات
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
}
