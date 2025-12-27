import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_colors_extension.dart';
import '../../screens/notification/notification_controller.dart';
import 'notification_sheet.dart';

/// Shared notification button with badge indicator
/// Badge shows red dot only when there are unread notifications
class NotificationButton extends ConsumerWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final hasUnread = state.hasUnread;

    return Stack(
      children: [
        IconButton(
          onPressed: () => showNotificationSheet(context),
          icon: Icon(
            hasUnread
                ? Icons.notifications_active_outlined
                : Icons.notifications_outlined,
            color: context.colors.darkGrey,
          ),
          style: IconButton.styleFrom(
            backgroundColor: context.colors.lightGrey,
            padding: const EdgeInsets.all(12),
          ),
        ),
        // Badge indicator - only show when has unread
        if (hasUnread)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
