import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Camera preview widget
/// For now shows a placeholder, will be replaced with actual camera
class CameraPreview extends StatelessWidget {
  const CameraPreview({
    super.key,
    this.isInitialized = false,
  });

  final bool isInitialized;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual camera preview using camera package
    // For now, show a placeholder
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder image or camera preview
          if (!isInitialized)
            const _CameraPlaceholder()
          else
            // Will be replaced with CameraPreview widget
            const _CameraPlaceholder(),

          // Top gradient overlay for better visibility of buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(128), // 50%
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder when camera is not initialized
class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: AppColors.gray900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray800,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.gray600,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing Camera...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
