import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';

/// Camera scan screen state
class ScanState {
  const ScanState({
    this.isCameraInitialized = false,
    this.isFlashOn = false,
    this.isCapturing = false,
    this.lastImagePath,
    this.errorMessage,
  });

  final bool isCameraInitialized;
  final bool isFlashOn;
  final bool isCapturing;
  final String? lastImagePath;
  final String? errorMessage;

  ScanState copyWith({
    bool? isCameraInitialized,
    bool? isFlashOn,
    bool? isCapturing,
    String? lastImagePath,
    String? errorMessage,
  }) {
    return ScanState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isCapturing: isCapturing ?? this.isCapturing,
      lastImagePath: lastImagePath ?? this.lastImagePath,
      errorMessage: errorMessage,
    );
  }
}

/// Camera scan controller
class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() {
    _initializeCamera();
    return const ScanState();
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      // TODO: Implement actual camera initialization
      // For now, simulate initialization delay
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(isCameraInitialized: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to initialize camera: $e',
      );
    }
  }

  /// Toggle flash
  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
    // TODO: Actually toggle camera flash
  }

  /// Capture photo and navigate to results
  Future<void> captureAndProcess(BuildContext context) async {
    if (state.isCapturing) return;

    state = state.copyWith(isCapturing: true);

    try {
      // TODO: Implement actual photo capture
      // For now, simulate capture and processing
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Send image to Gemini Vision for processing
      // For now, navigate to results with dummy data

      if (context.mounted) {
        context.push(Routes.scanResults);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Failed to capture: $e');
      }
    } finally {
      state = state.copyWith(isCapturing: false);
    }
  }

  /// Open gallery to pick image
  Future<void> openGallery(BuildContext context) async {
    // TODO: Implement image picker from gallery
    _showSnackBar(context, 'Gallery picker coming soon');
  }

  /// Open manual input
  void openManualInput(BuildContext context) {
    // Navigate to scan results with empty list for manual entry
    context.push(Routes.scanResults, extra: {'isManualEntry': true});
  }

  /// Close scanner
  void close(BuildContext context) {
    // Camera disposal will be handled when camera package is integrated
    context.pop();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Provider for scan controller
final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);
