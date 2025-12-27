import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../core/constants.dart';

/// Login screen header with app icon, name, and tagline
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App icon with rotation effect
        const _AppBrandIcon(),
        const SizedBox(height: 24),

        // App name
        Text(
          AppConstants.appName,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Tagline
        Text(
          'Stop wasting food.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Start managing your fridge smarter.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// App brand icon with coral background and snowflake
class _AppBrandIcon extends StatelessWidget {
  const _AppBrandIcon();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.05, // Slight rotation (~3 degrees)
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.ac_unit_rounded, // Snowflake icon
          size: 40,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}
