import 'package:flutter/material.dart';

/// Top bar for camera scan screen with close and flash buttons
class ScanTopBar extends StatelessWidget {
  const ScanTopBar({
    super.key,
    required this.onClose,
    required this.onFlashToggle,
    this.isFlashOn = false,
  });

  final VoidCallback onClose;
  final VoidCallback onFlashToggle;
  final bool isFlashOn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GlassButton(
              icon: Icons.close_rounded,
              onTap: onClose,
            ),
            _GlassButton(
              icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              onTap: onFlashToggle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-morphism style button
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(51), // 20%
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(26), // 10%
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
