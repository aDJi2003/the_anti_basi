import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Profile avatar with user info
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.onAvatarTap,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Avatar
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray900.withAlpha(26),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Name
        Text(
          name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        // Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.gray100,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.gray400,
        size: 48,
      ),
    );
  }
}
