import 'package:flutter/material.dart';
import '../../../../config/app_colors_extension.dart';

/// SignUp screen header with back button, title, and subtitle
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: context.colors.textPrimary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Create Account',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign up to start managing your fridge and reduce food waste.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
