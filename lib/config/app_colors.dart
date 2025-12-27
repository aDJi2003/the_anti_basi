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

  // Extended Accent Colors
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF3E8FF);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFF0FDFA);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Semantic aliases (Light Mode)
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray500;
  static const Color textMuted = gray400;
  static const Color border = gray200;
  static const Color divider = gray100;

  // Additional colors for specific UI elements
  static const Color darkGrey = Color(0xFF374151); // gray700
  static const Color mediumGrey = Color(0xFF6B7280); // gray500
  static const Color lightGrey = Color(0xFFF3F4F6); // gray100
  static const Color yellow = Color(0xFFFFC107);

  // ============ DARK MODE COLORS ============

  // Dark Mode Backgrounds
  static const Color darkBackground = Color(0xFF0F172A);    // slate-900
  static const Color darkSurface = Color(0xFF1E293B);       // slate-800
  static const Color darkSurfaceLight = Color(0xFF334155);  // slate-700

  // Dark Mode Text
  static const Color darkTextPrimary = Color(0xFFF8FAFC);   // slate-50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // slate-400
  static const Color darkTextMuted = Color(0xFF64748B);     // slate-500

  // Dark Mode Borders
  static const Color darkBorder = Color(0xFF334155);        // slate-700
  static const Color darkDivider = Color(0xFF1E293B);       // slate-800
}