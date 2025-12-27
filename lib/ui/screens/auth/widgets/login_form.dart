import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../widgets/common/common.dart';

/// Login form with email, password fields, social login, and submit button
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onLogin,
    this.onGoogleSignIn,
    this.onSignUp,
    this.isLoading = false,
    this.isGoogleLoading = false,
  });

  final Future<void> Function(String email, String password)? onLogin;
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onSignUp;
  final bool isLoading;
  final bool isGoogleLoading;

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
          // Google Sign-In button
          _GoogleSignInButton(
            onPressed: widget.onGoogleSignIn,
            isLoading: widget.isGoogleLoading,
          ),
          const SizedBox(height: 24),

          // Divider with "or"
          const _OrDivider(),
          const SizedBox(height: 24),

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
                  color: context.colors.textSecondary,
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

/// Google Sign-In button with branded styling
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: context.colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: context.colors.surface,
      ),
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.textMuted,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google logo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomPaint(
                    painter: _GoogleLogoPainter(),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Custom painter for Google logo - Based on @lesliearkorful's implementation
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final length = size.width;
    final verticalOffset = (size.height / 2) - (length / 2);
    final bounds = Offset(0, verticalOffset) & Size.square(length);
    final center = bounds.center;
    final arcThickness = size.width / 4.5;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcThickness;

    void drawArc(double startAngle, double sweepAngle, Color color) {
      final arcPaint = paint..color = color;
      canvas.drawArc(bounds, startAngle, sweepAngle, false, arcPaint);
    }

    // Google brand colors with precise arc positions
    drawArc(3.5, 1.9, const Color(0xFFEA4335)); // Red - top left
    drawArc(2.5, 1.0, const Color(0xFFFBBC05)); // Yellow - left
    drawArc(0.9, 1.6, const Color(0xFF34A853)); // Green - bottom
    drawArc(-0.18, 1.1, const Color(0xFF4285F4)); // Blue - right

    // Blue horizontal bar for the "G" shape
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - (arcThickness / 2),
        bounds.centerRight.dx + (arcThickness / 2) - 4,
        bounds.centerRight.dy + (arcThickness / 2),
      ),
      paint
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill
        ..strokeWidth = 0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Divider with "or" text
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: context.colors.border,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: context.colors.border,
          ),
        ),
      ],
    );
  }
}
