import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../widgets/common/common.dart';

/// SignUp form with name, email, password, confirm password, and profile photo
class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    this.onSignUp,
    this.onPickImage,
    this.onTakePhoto,
    this.onRemoveImage,
    this.onLogin,
    this.isLoading = false,
    this.profileImagePath,
  });

  final Future<void> Function(String name, String email, String password)? onSignUp;
  final VoidCallback? onPickImage;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onRemoveImage;
  final VoidCallback? onLogin;
  final bool isLoading;
  final String? profileImagePath;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignUp?.call(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showImagePickerModal() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Choose Profile Photo',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Camera option
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: context.colors.primary,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Use camera to take a new photo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onTakePhoto?.call();
                },
              ),

              // Gallery option
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: context.colors.primary,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Maximum 2 MB',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickImage?.call();
                },
              ),

              // Remove option (if image exists)
              if (widget.profileImagePath != null) ...[
                const Divider(height: 24),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.colors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: context.colors.error,
                    ),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onRemoveImage?.call();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
          // Profile photo picker
          _ProfilePhotoPicker(
            imagePath: widget.profileImagePath,
            onTap: _showImagePickerModal,
          ),
          const SizedBox(height: 28),

          // Name field
          AppTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            validator: _validateName,
          ),
          const SizedBox(height: 20),

          // Email field
          AppTextField(
            label: 'Email',
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
            hint: 'At least 6 characters with a number',
            controller: _passwordController,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),

          // Confirm password field
          AppTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: _confirmPasswordController,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSignUp(),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 28),

          // Sign up button
          AppButton(
            text: 'Sign Up',
            onPressed: _handleSignUp,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 24),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: widget.onLogin,
                child: Text(
                  'Login',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}

/// Profile photo picker widget
class _ProfilePhotoPicker extends StatelessWidget {
  const _ProfilePhotoPicker({
    this.imagePath,
    this.onTap,
  });

  final String? imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              // Avatar container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.surfaceLight,
                  border: Border.all(
                    color: context.colors.border,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withAlpha(20),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: imagePath != null
                    ? ClipOval(
                        child: Image.file(
                          File(imagePath!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: context.colors.textMuted,
                      ),
              ),

              // Edit badge
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary,
                    border: Border.all(
                      color: context.colors.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    imagePath != null ? Icons.edit_rounded : Icons.add_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          imagePath != null ? 'Change profile photo' : 'Add profile photo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}
