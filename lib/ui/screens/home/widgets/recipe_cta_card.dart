import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/inventory_item.dart';

/// Recipe CTA card - psychological trigger for generating recipes
/// Uses expiring items to create urgency
class RecipeCtaCard extends StatelessWidget {
  const RecipeCtaCard({
    super.key,
    required this.expiringItems,
    required this.onGenerateRecipes,
    this.isGenerating = false,
  });

  final List<InventoryItem> expiringItems;
  final VoidCallback onGenerateRecipes;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgentItems = expiringItems
        .where((i) => i.daysUntilExpiry <= 2 && i.daysUntilExpiry >= 0)
        .toList();
    final hasUrgent = urgentItems.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hasUrgent
                ? [AppColors.orange, AppColors.error]
                : [AppColors.teal, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (hasUrgent ? AppColors.orange : AppColors.teal)
                  .withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onGenerateRecipes,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          hasUrgent
                              ? Icons.schedule_rounded
                              : Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(urgentItems),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getSubtitle(urgentItems, hasUrgent),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withAlpha(204),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Expiring items preview
                  if (hasUrgent) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: urgentItems.take(3).map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.expiryStatus == ExpiryStatus.expiringToday
                                    ? Icons.warning_rounded
                                    : Icons.schedule_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.displayName} • ${_formatExpiry(item)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // CTA button with loading state
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isGenerating
                          ? Colors.white.withAlpha(230)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isGenerating
                        ? _LoadingButton(
                            accentColor:
                                hasUrgent ? AppColors.orange : AppColors.teal,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu_rounded,
                                color: hasUrgent
                                    ? AppColors.orange
                                    : AppColors.teal,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasUrgent ? 'Cook now' : 'Find recipes',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: hasUrgent
                                      ? AppColors.orange
                                      : AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: hasUrgent
                                    ? AppColors.orange
                                    : AppColors.teal,
                                size: 16,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(List<InventoryItem> urgentItems) {
    if (urgentItems.isEmpty) {
      return 'Need recipe ideas?';
    } else if (urgentItems.length == 1) {
      return '${urgentItems.first.name} expiring soon!';
    } else {
      return '${urgentItems.length} items expiring soon!';
    }
  }

  String _getSubtitle(List<InventoryItem> urgentItems, bool hasUrgent) {
    if (!hasUrgent) {
      return 'Generate recipes from your fridge items';
    } else {
      return "Don't let food go to waste";
    }
  }

  String _formatExpiry(InventoryItem item) {
    if (item.daysUntilExpiry == 0) {
      return 'Today';
    } else if (item.daysUntilExpiry == 1) {
      return 'Tomorrow';
    } else {
      return '${item.daysUntilExpiry}d';
    }
  }
}

/// Animated loading button with cooking text
class _LoadingButton extends StatefulWidget {
  const _LoadingButton({required this.accentColor});

  final Color accentColor;

  @override
  State<_LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<_LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _dotsAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cooking pot icon with subtle rotation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 0.1 - 0.05,
              child: Icon(
                Icons.soup_kitchen_rounded,
                color: widget.accentColor,
                size: 18,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        // "Cooking" text with animated dots
        AnimatedBuilder(
          animation: _dotsAnimation,
          builder: (context, child) {
            final dots = '.' * _dotsAnimation.value.floor();
            return Text(
              'Cooking$dots',
              style: theme.textTheme.titleSmall?.copyWith(
                color: widget.accentColor,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        // Small loading indicator
        const SizedBox(width: 8),
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
          ),
        ),
      ],
    );
  }
}
