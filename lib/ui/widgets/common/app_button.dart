import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

/// Button variants
enum AppButtonVariant {
  filled,
  outlined,
  text,
}

/// Reusable button component
/// Follows Material Design 3 guidelines with custom styling
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final IconPosition iconPosition;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final height = switch (size) {
      AppButtonSize.small => 40.0,
      AppButtonSize.medium => 52.0,
      AppButtonSize.large => 56.0,
    };

    final fontSize = switch (size) {
      AppButtonSize.small => 14.0,
      AppButtonSize.medium => 16.0,
      AppButtonSize.large => 16.0,
    };

    final horizontalPadding = switch (size) {
      AppButtonSize.small => 16.0,
      AppButtonSize.medium => 24.0,
      AppButtonSize.large => 32.0,
    };

    final buttonStyle = switch (variant) {
      AppButtonVariant.filled => FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.gray200,
          disabledForegroundColor: AppColors.gray400,
          minimumSize: Size(isExpanded ? double.infinity : 0, height),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      AppButtonVariant.outlined => OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.gray400,
          minimumSize: Size(isExpanded ? double.infinity : 0, height),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      AppButtonVariant.text => TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.gray400,
          minimumSize: Size(isExpanded ? double.infinity : 0, height),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
    };

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.filled
                  ? AppColors.white
                  : AppColors.primary,
            ),
          )
        : _buildContent(fontSize);

    return switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
    };
  }

  Widget _buildContent(double fontSize) {
    if (icon == null) {
      return Text(text);
    }

    final iconWidget = Icon(icon, size: fontSize + 2);
    final textWidget = Text(text);
    const spacing = SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, spacing, textWidget]
          : [textWidget, spacing, iconWidget],
    );
  }
}

enum IconPosition { left, right }

enum AppButtonSize { small, medium, large }
