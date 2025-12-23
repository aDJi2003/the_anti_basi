import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Bottom sheet for camera scan with capture controls
class ScanBottomSheet extends StatelessWidget {
  const ScanBottomSheet({
    super.key,
    required this.onCapture,
    required this.onGallery,
    required this.onManualInput,
    this.lastImagePath,
  });

  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onManualInput;
  final String? lastImagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            // Lighting tip
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wb_sunny_rounded,
                  color: Color(0xFFF59E0B), // amber
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ensure good lighting for best results',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery button
                  _ActionButton(
                    onTap: onGallery,
                    child: lastImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              lastImagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const _GalleryPlaceholder(),
                            ),
                          )
                        : const _GalleryPlaceholder(),
                  ),

                  // Capture button
                  _CaptureButton(onTap: onCapture),

                  // Manual input button
                  _ActionButton(
                    onTap: onManualInput,
                    child: const Icon(
                      Icons.keyboard_rounded,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Branding
            Text(
              'THE ANTI-BASI',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.gray300,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Gallery placeholder icon
class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray100,
      child: const Icon(
        Icons.photo_library_outlined,
        color: AppColors.gray400,
        size: 24,
      ),
    );
  }
}

/// Side action button (gallery/manual input)
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Main capture button
class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withAlpha(51), // 20%
            width: 4,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(77), // 30%
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(77), // 30%
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
