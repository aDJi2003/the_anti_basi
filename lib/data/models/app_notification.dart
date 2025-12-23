import 'package:flutter/material.dart';

/// Notification type for categorization
enum NotificationType {
  expiringSoon,
  expired,
  lowStock,
  recipe,
  tip,
  system;

  String get displayName {
    return switch (this) {
      NotificationType.expiringSoon => 'Expiring Soon',
      NotificationType.expired => 'Expired',
      NotificationType.lowStock => 'Low Stock',
      NotificationType.recipe => 'Recipe',
      NotificationType.tip => 'Tip',
      NotificationType.system => 'System',
    };
  }

  IconData get icon {
    return switch (this) {
      NotificationType.expiringSoon => Icons.timer_outlined,
      NotificationType.expired => Icons.warning_amber_rounded,
      NotificationType.lowStock => Icons.inventory_2_outlined,
      NotificationType.recipe => Icons.restaurant_outlined,
      NotificationType.tip => Icons.lightbulb_outline,
      NotificationType.system => Icons.info_outline,
    };
  }

  Color get color {
    return switch (this) {
      NotificationType.expiringSoon => const Color(0xFFF59E0B), // Warning yellow
      NotificationType.expired => const Color(0xFFEF4444), // Error red
      NotificationType.lowStock => const Color(0xFF3B82F6), // Blue
      NotificationType.recipe => const Color(0xFF10B981), // Primary green
      NotificationType.tip => const Color(0xFF8B5CF6), // Purple
      NotificationType.system => const Color(0xFF6B7280), // Gray
    };
  }

  Color get lightColor {
    return switch (this) {
      NotificationType.expiringSoon => const Color(0xFFFFFBEB),
      NotificationType.expired => const Color(0xFFFEF2F2),
      NotificationType.lowStock => const Color(0xFFEFF6FF),
      NotificationType.recipe => const Color(0xFFECFDF5),
      NotificationType.tip => const Color(0xFFF5F3FF),
      NotificationType.system => const Color(0xFFF9FAFB),
    };
  }
}

/// App notification model
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
    this.relatedItemId,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;
  final String? relatedItemId;

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? actionRoute,
    String? relatedItemId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      relatedItemId: relatedItemId ?? this.relatedItemId,
    );
  }
}
