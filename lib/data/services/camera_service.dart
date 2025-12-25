import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Camera service - handles camera operations
class CameraService {
  CameraService();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  /// Get camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Check if flash is on
  bool get isFlashOn => _controller?.value.flashMode == FlashMode.torch;

  /// Initialize camera
  Future<void> initialize() async {
    try {
      debugPrint('[CameraService] Getting available cameras...');
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      debugPrint('[CameraService] Found ${_cameras.length} cameras');

      // Use back camera by default
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      debugPrint('[CameraService] Using camera: ${backCamera.name}');

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;

      debugPrint('[CameraService] Camera initialized successfully');
    } catch (e) {
      debugPrint('[CameraService] ERROR initializing camera: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Toggle flash mode
  Future<void> toggleFlash() async {
    if (_controller == null || !_isInitialized) return;

    try {
      final currentMode = _controller!.value.flashMode;
      final newMode = currentMode == FlashMode.torch
          ? FlashMode.off
          : FlashMode.torch;

      await _controller!.setFlashMode(newMode);
      debugPrint('[CameraService] Flash mode: $newMode');
    } catch (e) {
      debugPrint('[CameraService] ERROR toggling flash: $e');
    }
  }

  /// Capture photo and return file path
  Future<String?> capturePhoto() async {
    if (_controller == null || !_isInitialized) {
      debugPrint('[CameraService] Camera not initialized');
      return null;
    }

    try {
      debugPrint('[CameraService] Capturing photo...');

      // Take picture
      final XFile image = await _controller!.takePicture();

      // Get temporary directory for storing the image
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(tempDir.path, fileName);

      // Copy to our path
      await File(image.path).copy(filePath);

      debugPrint('[CameraService] Photo saved to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('[CameraService] ERROR capturing photo: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<String?> pickFromGallery() async {
    try {
      debugPrint('[CameraService] Opening gallery...');

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('[CameraService] No image selected');
        return null;
      }

      debugPrint('[CameraService] Image picked: ${image.path}');
      return image.path;
    } catch (e) {
      debugPrint('[CameraService] ERROR picking from gallery: $e');
      return null;
    }
  }

  /// Dispose camera controller
  Future<void> dispose() async {
    debugPrint('[CameraService] Disposing camera...');
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}

// ============ PROVIDERS ============

/// Provider for camera service
final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
