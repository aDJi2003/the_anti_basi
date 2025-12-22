import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';

/// Login screen state
class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Login controller - handles authentication logic
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  /// Login with email and password
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Implement actual Firebase authentication
      // For now, simulate login delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful login
      state = state.copyWith(isLoading: false);

      // Navigate to home
      if (context.mounted) {
        context.go(Routes.home);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      if (context.mounted) {
        _showErrorSnackBar(context, 'Login failed. Please try again.');
      }
    }
  }

  /// Navigate to sign up screen
  void navigateToSignUp(BuildContext context) {
    // TODO: Implement navigation to sign up screen
    _showErrorSnackBar(context, 'Sign up coming soon!');
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Provider for login controller
final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
