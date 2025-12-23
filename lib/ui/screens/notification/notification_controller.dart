import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_notification.dart';

/// State for notifications
class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  final List<AppNotification> notifications;
  final bool isLoading;

  /// Get unread notifications count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Check if there are unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Get unread notifications
  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  /// Get read notifications
  List<AppNotification> get readNotifications =>
      notifications.where((n) => n.isRead).toList();

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notification controller
class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    _loadNotifications();
    return const NotificationState(isLoading: true);
  }

  /// Load notifications (mock data for now)
  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final mockNotifications = [
      AppNotification(
        id: '1',
        title: 'Milk expires today!',
        message: 'Your Fresh Milk will expire today. Use it before it goes bad.',
        type: NotificationType.expiringSoon,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        relatedItemId: '1',
      ),
      AppNotification(
        id: '2',
        title: 'Eggs expiring soon',
        message: 'Organic Eggs will expire in 2 days. Consider using them soon.',
        type: NotificationType.expiringSoon,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        relatedItemId: '2',
      ),
      AppNotification(
        id: '3',
        title: 'Recipe suggestion',
        message: 'Try making Spinach & Cheese Omelet with your expiring ingredients!',
        type: NotificationType.recipe,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
        actionRoute: '/recipes/1',
      ),
      AppNotification(
        id: '4',
        title: 'Low stock alert',
        message: 'You\'re running low on butter. Add it to your shopping list.',
        type: NotificationType.lowStock,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '5',
        title: 'Pro tip',
        message: 'Store herbs in a glass of water in the fridge to keep them fresh longer.',
        type: NotificationType.tip,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    state = state.copyWith(
      notifications: mockNotifications,
      isLoading: false,
    );
  }

  /// Refresh notifications
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadNotifications();
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  /// Delete a notification
  void deleteNotification(String notificationId) {
    final updated = state.notifications
        .where((n) => n.id != notificationId)
        .toList();

    state = state.copyWith(notifications: updated);
  }

  /// Clear all notifications
  void clearAll() {
    state = state.copyWith(notifications: []);
  }

  /// Delete all read notifications
  void clearRead() {
    final updated = state.notifications
        .where((n) => !n.isRead)
        .toList();

    state = state.copyWith(notifications: updated);
  }
}

/// Provider for notification controller
final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
        NotificationController.new);
