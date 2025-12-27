import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors_extension.dart';
import 'signup_controller.dart';
import 'widgets/signup_form.dart';
import 'widgets/signup_header.dart';

/// SignUp screen - User registration
/// UI only, logic handled by SignUpController
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpControllerProvider);
    final controller = ref.read(signUpControllerProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.background,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Header (back button, title, subtitle)
                      SignUpHeader(
                        onBack: () => controller.navigateToLogin(context),
                      ),
                      const SizedBox(height: 32),

                      // SignUp form
                      SignUpForm(
                        isLoading: state.isLoading,
                        profileImagePath: state.profileImagePath,
                        onSignUp: (name, email, password) => controller.signUp(
                          name: name,
                          email: email,
                          password: password,
                          context: context,
                        ),
                        onPickImage: () => controller.pickProfileImage(context),
                        onTakePhoto: () => controller.takePhoto(context),
                        onRemoveImage: controller.removeProfileImage,
                        onLogin: () => controller.navigateToLogin(context),
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
