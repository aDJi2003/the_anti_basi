import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../widgets/common/common.dart';

/// Login form with email, password fields and submit button
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onLogin,
    this.onSignUp,
    this.isLoading = false,
  });

  final Future<void> Function(String email, String password)? onLogin;
  final VoidCallback? onSignUp;
  final bool isLoading;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin?.call(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          AppTextField(
            label: 'Email address',
            hint: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),

          // Password field
          AppTextField(
            label: 'Password',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _handleLogin(),
            validator: _validatePassword,
          ),
          const SizedBox(height: 24),

          // Login button
          AppButton(
            text: 'Login',
            onPressed: _handleLogin,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 24),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: widget.onSignUp,
                child: Text(
                  'Sign up',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
