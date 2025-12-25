import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Camera preview widget
/// Shows actual camera feed when initialized
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({
    super.key,
    this.isInitialized = false,
    this.cameraController,
    this.errorMessage,
  });

  final bool isInitialized;
  final CameraController? cameraController;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview or placeholder
          if (errorMessage != null)
            _CameraError(message: errorMessage!)
          else if (!isInitialized || cameraController == null)
            const _CameraPlaceholder()
          else
            _buildCameraPreview(context),

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

  /// Build the actual camera preview
  Widget _buildCameraPreview(BuildContext context) {
    final controller = cameraController!;

    if (!controller.value.isInitialized) {
      return const _CameraPlaceholder();
    }

    // Get screen size for full-screen preview
    final screenSize = MediaQuery.of(context).size;
    final previewSize = controller.value.previewSize!;

    // Calculate scale to cover screen (similar to cover fit)
    var scale = screenSize.aspectRatio * previewSize.aspectRatio;

    // Invert scale if it's less than 1 to ensure we cover the screen
    if (scale < 1) scale = 1 / scale;

    return Center(
      child: Transform.scale(
        scale: scale,
        child: CameraPreview(controller),
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
            decoration: const BoxDecoration(
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

/// Error state when camera fails to initialize
class _CameraError extends StatelessWidget {
  const _CameraError({required this.message});

  final String message;

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
            decoration: const BoxDecoration(
              color: AppColors.gray800,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Camera Error',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
