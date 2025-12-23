import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../widgets/common/notification_button.dart';

/// Header for recipe suggestion screen with CTA
class RecipeScreenHeader extends StatelessWidget {
  const RecipeScreenHeader({super.key});

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
          // Notification button (shared widget)
          const NotificationButton(),
        ],
      ),
    );
  }
}
