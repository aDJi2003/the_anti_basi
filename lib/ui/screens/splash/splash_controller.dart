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
      // Simulate loading (will be replaced with actual init logic)
      await Future.delayed(AppConstants.splashDuration);

      // TODO: Add actual initialization logic here:
      // - Check auth state
      // - Load user preferences
      // - Initialize services

      state = SplashState.ready;

      // Navigate to next screen
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
    // TODO: Check if user is logged in
    // For now, navigate to login
    // In future:
    // - If logged in -> go to home
    // - If not logged in -> go to login

    context.go(Routes.login);
  }
}

/// Provider for splash controller
final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);
