import 'package:flutter/material.dart';

/// App color palette based on design system
class AppColors {
  AppColors._();

  // Primary Colors (Mint Green)
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFFECFDF5);
  static const Color primaryDark = Color(0xFF059669);

  // Accent Colors (Coral/Salmon - for branding elements)
  static const Color accent = Color(0xFFEF4444);
  static const Color accentLight = Color(0xFFFEE2E2);

  // Status Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color success = Color(0xFF10B981);
  static const Color saved = Color(0xFF8B5CF6);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  // Semantic aliases
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray500;
  static const Color textMuted = gray400;
  static const Color border = gray200;
  static const Color divider = gray100;
}
