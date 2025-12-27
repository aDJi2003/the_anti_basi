import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import 'local_notification_service.dart';

/// Top-level background handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background handling
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Service to handle Firebase Cloud Messaging
class FCMService {
  FCMService(this._userRepository, this._localNotificationService);

  final UserRepository _userRepository;
  final LocalNotificationService _localNotificationService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  /// Initialize FCM and listeners
  Future<void> initialize(
    void Function(String?)? onNotificationTap,
  ) async {
    if (_isInitialized) return;

    // 1. Request Permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Setup Background Handler (Static/Top-Level)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Initialize Local Notifications (for Foreground display)
      await _localNotificationService.initialize(onNotificationTap);
      await _localNotificationService.createChannel();

      // 4. Setup Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message: ${message.notification?.title}');
        _showForegroundNotification(message);
      });

      // 5. Setup Token Management
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token: $token');
        await _userRepository.saveFCMToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed');
        _userRepository.saveFCMToken(newToken);
      });

      // 6. Handle Interaction (App opened from notification)
      _setupInteractions(onNotificationTap);

      _isInitialized = true;
    }
  }

  /// Show notification when app is in foreground
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      // Pass data payload if available
      final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;

      _localNotificationService.showNotification(
        id: notification.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: payload,
      );
    }
  }

  /// Handle notification taps
  Future<void> _setupInteractions(void Function(String?)? onNotificationTap) async {
    // 1. Terminated State -> Opened App
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App opened from terminated state');
      if (onNotificationTap != null) {
        final payload = initialMessage.data.isNotEmpty 
            ? jsonEncode(initialMessage.data) 
            : null;
        onNotificationTap(payload);
      }
    }

    // 2. Background State -> Opened App
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App opened from background state');
      if (onNotificationTap != null) {
        final payload = message.data.isNotEmpty 
            ? jsonEncode(message.data) 
            : null;
        onNotificationTap(payload);
      }
    });
  }
  
  /// Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

/// Provider for FCM Service
final fcmServiceProvider = Provider<FCMService>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  final localNotif = ref.watch(localNotificationServiceProvider);
  return FCMService(userRepo, localNotif);
});
