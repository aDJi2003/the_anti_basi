import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scan_controller.dart';
import 'widgets/camera_preview.dart';
import 'widgets/scan_bottom_sheet.dart';
import 'widgets/scan_top_bar.dart';

/// Camera scan screen for capturing food items
/// This screen is outside the MainShell (no bottom nav)
class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview (full screen)
          CameraPreview(isInitialized: state.isCameraInitialized),

          // Top bar (close + flash)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScanTopBar(
              onClose: () => controller.close(context),
              onFlashToggle: controller.toggleFlash,
              isFlashOn: state.isFlashOn,
            ),
          ),

          // Bottom sheet (capture controls)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ScanBottomSheet(
              onCapture: () => controller.captureAndProcess(context),
              onGallery: () => controller.openGallery(context),
              onManualInput: () => controller.openManualInput(context),
              lastImagePath: state.lastImagePath,
            ),
          ),

          // Loading overlay when capturing
          if (state.isCapturing)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
