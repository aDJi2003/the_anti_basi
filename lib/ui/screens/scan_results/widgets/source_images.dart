import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Horizontal scrollable source images
class SourceImages extends StatelessWidget {
  const SourceImages({
    super.key,
    this.images = const [],
    this.onAddImage,
  });

  final List<String> images;
  final VoidCallback? onAddImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'SOURCE IMAGE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scroll
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: images.length + 1, // +1 for add button
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index < images.length) {
                return _ImageThumbnail(
                  imagePath: images[index],
                  isMain: index == 0,
                );
              }
              return _AddImageButton(onTap: onAddImage);
            },
          ),
        ),
      ],
    );
  }
}

/// Single image thumbnail
class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.imagePath,
    this.isMain = false,
  });

  final String imagePath;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 96,
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: isDark ? AppColors.darkSurfaceLight : AppColors.gray100,
              child: Icon(
                Icons.image_outlined,
                color: isDark ? AppColors.darkTextMuted : AppColors.gray400,
              ),
            ),
          ),

          // Overlay
          Container(
            color: Colors.black.withAlpha(51),
          ),

          // Main badge
          if (isMain)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Main',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Add image button
class _AddImageButton extends StatelessWidget {
  const _AddImageButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray300,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add_a_photo_outlined,
            color: isDark ? AppColors.darkTextMuted : AppColors.gray400,
            size: 28,
          ),
        ),
      ),
    );
  }
}
