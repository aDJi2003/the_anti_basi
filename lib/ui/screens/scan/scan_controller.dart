import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/scanned_item.dart';
import '../../../data/services/camera_service.dart';
import '../../../data/services/gemini_service.dart';

/// Camera scan screen state
class ScanState {
  const ScanState({
    this.isCameraInitialized = false,
    this.isFlashOn = false,
    this.isCapturing = false,
    this.isProcessing = false,
    this.processingMessage,
    this.lastImagePath,
    this.errorMessage,
    this.cameraController,
  });

  final bool isCameraInitialized;
  final bool isFlashOn;
  final bool isCapturing;
  final bool isProcessing;
  final String? processingMessage;
  final String? lastImagePath;
  final String? errorMessage;
  final CameraController? cameraController;

  /// Check if currently busy (capturing or processing)
  bool get isBusy => isCapturing || isProcessing;

  ScanState copyWith({
    bool? isCameraInitialized,
    bool? isFlashOn,
    bool? isCapturing,
    bool? isProcessing,
    String? processingMessage,
    String? lastImagePath,
    String? errorMessage,
    CameraController? cameraController,
  }) {
    return ScanState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isCapturing: isCapturing ?? this.isCapturing,
      isProcessing: isProcessing ?? this.isProcessing,
      processingMessage: processingMessage,
      lastImagePath: lastImagePath ?? this.lastImagePath,
      errorMessage: errorMessage,
      cameraController: cameraController ?? this.cameraController,
    );
  }
}

/// Camera scan controller
class ScanController extends Notifier<ScanState> {
  late final CameraService _cameraService;
  late final GeminiService _geminiService;

  @override
  ScanState build() {
    _cameraService = ref.read(cameraServiceProvider);
    _geminiService = ref.read(geminiServiceProvider);

    // Initialize camera when controller is built
    _initializeCamera();

    // Dispose camera when controller is disposed
    ref.onDispose(() {
      debugPrint('[ScanController] Disposing camera...');
      _cameraService.dispose();
    });

    return const ScanState();
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      debugPrint('[ScanController] Initializing camera...');
      await _cameraService.initialize();

      state = state.copyWith(
        isCameraInitialized: true,
        cameraController: _cameraService.controller,
      );

      debugPrint('[ScanController] Camera ready');
    } catch (e) {
      debugPrint('[ScanController] Camera init failed: $e');
      state = state.copyWith(
        errorMessage: 'Failed to initialize camera: $e',
      );
    }
  }

  /// Toggle flash
  Future<void> toggleFlash() async {
    await _cameraService.toggleFlash();
    state = state.copyWith(isFlashOn: _cameraService.isFlashOn);
  }

  /// Capture photo and process with Gemini
  Future<void> captureAndProcess(BuildContext context) async {
    if (state.isBusy) return;

    state = state.copyWith(isCapturing: true, processingMessage: 'Capturing...');

    try {
      debugPrint('[ScanController] Capturing photo...');
      final imagePath = await _cameraService.capturePhoto();

      if (imagePath == null) {
        throw Exception('Failed to capture photo');
      }

      debugPrint('[ScanController] Photo captured: $imagePath');
      state = state.copyWith(
        isCapturing: false,
        isProcessing: true,
        lastImagePath: imagePath,
        processingMessage: 'Analyzing with AI...',
      );

      // Process image with Gemini
      final scannedItems = await _processWithGemini(imagePath);

      // Navigate to results with scanned items
      if (context.mounted) {
        context.push(Routes.scanResults, extra: {
          'items': scannedItems,
          'imagePath': imagePath,
        });
      }
    } catch (e) {
      debugPrint('[ScanController] Capture/Process failed: $e');
      if (context.mounted) {
        _showError(context, 'Failed to process: $e');
      }
    } finally {
      state = state.copyWith(isCapturing: false, isProcessing: false);
    }
  }

  /// Open gallery and process picked image
  Future<void> openGallery(BuildContext context) async {
    if (state.isBusy) return;

    try {
      debugPrint('[ScanController] Opening gallery...');
      final imagePath = await _cameraService.pickFromGallery();

      if (imagePath == null) {
        debugPrint('[ScanController] No image selected from gallery');
        return;
      }

      debugPrint('[ScanController] Image picked: $imagePath');
      state = state.copyWith(
        isProcessing: true,
        lastImagePath: imagePath,
        processingMessage: 'Analyzing with AI...',
      );

      // Process image with Gemini
      final scannedItems = await _processWithGemini(imagePath);

      // Navigate to results with scanned items
      if (context.mounted) {
        context.push(Routes.scanResults, extra: {
          'items': scannedItems,
          'imagePath': imagePath,
        });
      }
    } catch (e) {
      debugPrint('[ScanController] Gallery pick/process failed: $e');
      if (context.mounted) {
        _showError(context, 'Failed to process image: $e');
      }
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Process image with Gemini AI
  Future<List<ScannedItem>> _processWithGemini(String imagePath) async {
    debugPrint('[ScanController] Processing with Gemini...');
    final items = await _geminiService.processImage(imagePath);
    debugPrint('[ScanController] Got ${items.length} items from Gemini');
    return items;
  }

  /// Open manual input
  void openManualInput(BuildContext context) {
    // Navigate to scan results with empty list for manual entry
    context.push(Routes.scanResults, extra: {'isManualEntry': true});
  }

  /// Close scanner
  void close(BuildContext context) {
    context.pop();
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
