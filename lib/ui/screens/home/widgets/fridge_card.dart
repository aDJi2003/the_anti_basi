import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';

/// Hero card showing fridge overview with background image
class FridgeCard extends StatelessWidget {
  const FridgeCard({
    super.key,
    required this.itemCount,
    this.lastUpdated,
    this.onViewAll,
    this.fridgeImagePath,
  });

  final int itemCount;
  final DateTime? lastUpdated;
  final VoidCallback? onViewAll;
  final String? fridgeImagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.colors.darkGrey,
          boxShadow: [
            BoxShadow(
              color: context.colors.darkGrey.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (fridgeImagePath != null)
              Positioned.fill(
                child: Image.asset(
                  fridgeImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Fridge image error: $error');
                    return Container(
                      color: context.colors.darkGrey,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: context.colors.textMuted,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Gradient overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withAlpha(230), // 86%
                      Colors.black.withAlpha(102), // 40%
                      Colors.black.withAlpha(40), // 10%
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: icon and updated badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.kitchen_rounded,
                        color: AppColors.primaryLight.withAlpha(230),
                        size: 28,
                      ),
                      _UpdatedBadge(lastUpdated: lastUpdated),
                    ],
                  ),

                  // Bottom row: title and view all button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inside your Fridge',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$itemCount items cooling nicely',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      _ViewAllButton(onTap: onViewAll),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Updated timestamp badge
class _UpdatedBadge extends StatelessWidget {
  const _UpdatedBadge({this.lastUpdated});

  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(102), // 40%
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Text(
        _getTimeText(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white.withAlpha(230),
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getTimeText() {
    if (lastUpdated == null) return 'Updated Just now';

    final diff = DateTime.now().difference(lastUpdated!);
    if (diff.inMinutes < 1) return 'Updated Just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}

/// View all button with glass effect
class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.primary, // 20%
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          child: Text(
            'View All',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
