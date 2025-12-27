import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../widgets/common/notification_button.dart';

/// Home screen header with user greeting and notification bell
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    this.onAvatarTap,
  });

  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar and greeting
          GestureDetector(
            onTap: onAvatarTap,
            child: Row(
              children: [
                _buildAvatar(context),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$userName!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Notification button (shared widget)
          const NotificationButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipOval(
        child: userAvatarUrl != null
            ? Image.network(
                userAvatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => _buildDefaultAvatar(context),
              )
            : _buildDefaultAvatar(context),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkSurfaceLight : AppColors.gray100,
      child: Icon(
        Icons.person,
        color: isDark ? AppColors.darkTextSecondary : AppColors.gray400,
        size: 24,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
