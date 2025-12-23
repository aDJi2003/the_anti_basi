import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Header for recipe suggestion screen with CTA
class RecipeScreenHeader extends StatelessWidget {
  const RecipeScreenHeader({
    super.key,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Left side - CTA text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What will you',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.mediumGrey,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                Text(
                  'cook today?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Notification button
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.darkGrey,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.lightGrey,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
