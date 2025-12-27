import 'package:flutter/material.dart';
import '../../../../config/app_colors_extension.dart';

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
                color: context.colors.surface,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.textPrimary.withAlpha(26),
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
                      errorBuilder: (ctx, error, stackTrace) =>
                          _buildDefaultAvatar(ctx),
                    )
                  : _buildDefaultAvatar(context),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Name
        Text(
          name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),

        // Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      color: context.colors.inputBackground,
      child: Icon(
        Icons.person_rounded,
        color: context.colors.textMuted,
        size: 48,
      ),
    );
  }
}
