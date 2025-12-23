import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Profile screen header with centered title
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.title = 'Profile',
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
