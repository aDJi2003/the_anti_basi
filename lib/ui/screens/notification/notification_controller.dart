import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    Future.microtask(() => _loadNotifications());
    return const NotificationState(isLoading: true);
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('inventory')
          .get();

      final List<AppNotification> generatedNotifications = [];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        if (data['expiryDate'] != null) {
          final Timestamp expiryTs = data['expiryDate'];
          final DateTime expiryDate = expiryTs.toDate();
          final String itemName = data['displayName'] ?? data['name'] ?? 'Item';
          final String itemId = doc.id;

          final difference = expiryDate.difference(now).inDays;

          if (difference <= 3 && difference >= 0) {
            generatedNotifications.add(
              AppNotification(
                id: 'notif_expiry_$itemId',
                title: 'Waspada Bahan Makanan!',
                message: '$itemName akan kedaluwarsa dalam ${difference == 0 ? "hari ini" : "$difference hari"}. Gunakan segera!',
                type: NotificationType.expiringSoon,
                createdAt: DateTime.now(), 
                isRead: false,
                relatedItemId: itemId,
              ),
            );
          } 
          else if (difference < 0) {
             generatedNotifications.add(
              AppNotification(
                id: 'notif_expired_$itemId',
                title: 'Bahan Telah Kedaluwarsa',
                message: '$itemName sudah melewati tanggal kedaluwarsa.',
                type: NotificationType.expiringSoon, 
                createdAt: DateTime.now(),
                isRead: false,
                relatedItemId: itemId,
              ),
            );
          }
        }
      }

      state = state.copyWith(
        notifications: generatedNotifications,
        isLoading: false,
      );

    } catch (e) {
      print("Error fetching notifications: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  void markAsRead(String notificationId) {
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  void deleteNotification(String notificationId) {
    final updated = state.notifications
        .where((n) => n.id != notificationId)
        .toList();

    state = state.copyWith(notifications: updated);
  }

  void clearAll() {
    state = state.copyWith(notifications: []);
  }

  void clearRead() {
    final updated = state.notifications
        .where((n) => !n.isRead)
        .toList();

    state = state.copyWith(notifications: updated);
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
        NotificationController.new);
