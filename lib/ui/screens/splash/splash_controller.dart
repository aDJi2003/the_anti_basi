import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../core/constants.dart';

/// Splash screen state
enum SplashState {
  loading,
  ready,
  error,
}

/// Splash controller - handles navigation and initialization logic
class SplashController extends Notifier<SplashState> {
  @override
  SplashState build() => SplashState.loading;

  /// Initialize splash screen logic
  Future<void> init(BuildContext context) async {
    try {
      // Show splash for minimum duration
      await Future.delayed(AppConstants.splashDuration);

      state = SplashState.ready;

      // Navigate based on auth state
      if (context.mounted) {
        _navigateToNextScreen(context);
      }
    } catch (e) {
      state = SplashState.error;
      debugPrint('Splash init error: $e');
    }
  }

  /// Navigate based on auth state
  void _navigateToNextScreen(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in -> go to home
      context.go(Routes.home);
    } else {
      // User is not logged in -> go to login
      context.go(Routes.login);
    }
  }
}

/// Provider for splash controller
final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);
