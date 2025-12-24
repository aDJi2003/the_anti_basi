import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import 'login_controller.dart';
import 'widgets/login_features.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

/// Login screen - Entry point for authentication
/// UI only, logic handled by LoginController
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // Header (icon, title, tagline)
                      const LoginHeader(),
                      const SizedBox(height: 32),

                      // Features list
                      const LoginFeatures(),
                      const SizedBox(height: 32),

                      // Spacer to push form to bottom
                      const Spacer(),

                      // Login form
                      LoginForm(
                        isLoading: state.isLoading,
                        isGoogleLoading: state.isGoogleLoading,
                        onLogin: (email, password) =>
                            controller.login(email, password, context),
                        onGoogleSignIn: () =>
                            controller.loginWithGoogle(context),
                        onSignUp: () => controller.navigateToSignUp(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
