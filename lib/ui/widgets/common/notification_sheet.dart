import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/app_notification.dart';
import '../../screens/notification/notification_controller.dart';

/// Show notification bottom sheet
Future<void> showNotificationSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const NotificationSheet(),
  );
}

/// Notification bottom sheet
class NotificationSheet extends ConsumerWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              _NotificationHeader(
                unreadCount: state.unreadCount,
                onMarkAllRead: state.hasUnread ? controller.markAllAsRead : null,
                onClearAll: state.notifications.isNotEmpty
                    ? () => _showClearDialog(context, controller)
                    : null,
              ),

              const Divider(height: 1, color: AppColors.gray100),

              // Content
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : state.notifications.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.notifications.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 20,
                              color: AppColors.gray100,
                            ),
                            itemBuilder: (context, index) {
                              final notification = state.notifications[index];
                              return _NotificationTile(
                                notification: notification,
                                onTap: () {
                                  controller.markAsRead(notification.id);
                                  // Handle navigation if needed
                                  if (notification.actionRoute != null) {
                                    Navigator.pop(context);
                                    // Navigate to action route
                                  }
                                },
                                onDelete: () =>
                                    controller.deleteNotification(notification.id),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, NotificationController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Notifications'),
        content: const Text('What would you like to clear?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearRead();
              Navigator.pop(context);
            },
            child: const Text('Clear Read'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Header with title and actions
class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({
    required this.unreadCount,
    this.onMarkAllRead,
    this.onClearAll,
  });

  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 12),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Mark all read button
          if (onMarkAllRead != null)
            TextButton.icon(
              onPressed: onMarkAllRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Read all'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),

          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.mediumGrey),
            onSelected: (value) {
              if (value == 'clear' && onClearAll != null) {
                onClearAll!();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Clear notifications'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single notification tile
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: notification.isRead
              ? Colors.transparent
              : AppColors.primary.withAlpha(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.type.lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.type.icon,
                  color: notification.type.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ),
                        // Unread indicator
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Time and type tag
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: notification.type.lightColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.type.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: notification.type.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.gray400,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! We\'ll notify you\nwhen something needs your attention.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
