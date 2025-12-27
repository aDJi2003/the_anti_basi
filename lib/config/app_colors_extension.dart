import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension on BuildContext to get theme-aware colors
/// Usage: context.colors.background instead of AppColors.background
extension AppColorsExtension on BuildContext {
  _ThemedColors get colors => _ThemedColors(this);
}

class _ThemedColors {
  final BuildContext context;

  _ThemedColors(this.context);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Backgrounds
  Color get background => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get surface => _isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surfaceLight => _isDark ? AppColors.darkSurfaceLight : AppColors.gray50;
  Color get white => _isDark ? AppColors.darkSurface : AppColors.white;
  Color get inputBackground => _isDark ? AppColors.darkSurfaceLight : AppColors.gray100;

  // Text colors
  Color get textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textMuted => _isDark ? AppColors.darkTextMuted : AppColors.textMuted;

  // Borders
  Color get border => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get divider => _isDark ? AppColors.darkDivider : AppColors.divider;

  // Grays (inverted for dark mode)
  Color get gray50 => _isDark ? AppColors.gray900 : AppColors.gray50;
  Color get gray100 => _isDark ? AppColors.gray800 : AppColors.gray100;
  Color get gray200 => _isDark ? AppColors.gray700 : AppColors.gray200;
  Color get gray300 => _isDark ? AppColors.gray600 : AppColors.gray300;
  Color get gray400 => _isDark ? AppColors.gray500 : AppColors.gray400;
  Color get gray500 => _isDark ? AppColors.gray400 : AppColors.gray500;
  Color get gray600 => _isDark ? AppColors.gray300 : AppColors.gray600;
  Color get gray700 => _isDark ? AppColors.gray200 : AppColors.gray700;
  Color get gray800 => _isDark ? AppColors.gray100 : AppColors.gray800;
  Color get gray900 => _isDark ? AppColors.gray50 : AppColors.gray900;

  // Semantic grays
  Color get darkGrey => _isDark ? AppColors.gray200 : AppColors.darkGrey;
  Color get mediumGrey => _isDark ? AppColors.gray400 : AppColors.mediumGrey;
  Color get lightGrey => _isDark ? AppColors.darkSurfaceLight : AppColors.lightGrey;

  // Primary colors stay the same
  Color get primary => AppColors.primary;
  Color get primaryLight => _isDark ? AppColors.primaryDark : AppColors.primaryLight;
  Color get primaryDark => AppColors.primaryDark;

  // Status colors stay the same
  Color get warning => AppColors.warning;
  Color get warningLight => _isDark ? const Color(0xFF422006) : AppColors.warningLight;
  Color get error => AppColors.error;
  Color get errorLight => _isDark ? const Color(0xFF450A0A) : AppColors.errorLight;
  Color get success => AppColors.success;

  // Accent colors stay the same
  Color get accent => AppColors.accent;
  Color get purple => AppColors.purple;
  Color get blue => AppColors.blue;
  Color get orange => AppColors.orange;
  Color get teal => AppColors.teal;
}
