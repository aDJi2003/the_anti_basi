import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';

/// Compact feature list section for login screen
class LoginFeatures extends StatelessWidget {
  const LoginFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CompactFeature(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Quick Scan',
        ),
        _CompactFeature(
          icon: Icons.notifications_active_outlined,
          label: 'Reminders',
        ),
        _CompactFeature(
          icon: Icons.restaurant_outlined,
          label: 'Recipes',
        ),
      ],
    );
  }
}

/// Compact feature item with icon and label
class _CompactFeature extends StatelessWidget {
  const _CompactFeature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 26,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
