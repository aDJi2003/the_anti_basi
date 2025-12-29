import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../data/models/recipe.dart';
import '../../../../data/models/recipe_ingredient_display.dart';
import '../../../../data/models/inventory_item.dart';

/// Bottom sheet for previewing generated recipe details
/// Used only from recipe preview screen (generated recipes not yet saved)
class RecipePreviewSheet extends StatelessWidget {
  const RecipePreviewSheet({
    super.key,
    required this.recipe,
    required this.inventory,
  });

  final Recipe recipe;
  final List<InventoryItem> inventory;

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Recipe recipe,
    required List<InventoryItem> inventory,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipePreviewSheet(
        recipe: recipe,
        inventory: inventory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    // Get validated ingredients
    final validatedIngredients = RecipeValidator.validateIngredients(
      recipe,
      inventory,
    );
    final availableIngredients = validatedIngredients
        .where((ing) => !ing.isMissing)
        .toList();
    final summary = RecipeValidator.getSummary(validatedIngredients);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe header
                  _RecipeHeader(recipe: recipe),

                  const SizedBox(height: 20),

                  // Quick stats row
                  _QuickStats(recipe: recipe, summary: summary),

                  const SizedBox(height: 24),

                  // Ingredients section
                  Row(
                    children: [
                      Icon(
                        Icons.kitchen_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ingredients',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: summary.canCook
                              ? AppColors.success.withAlpha(26)
                              : AppColors.warning.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${summary.available}/${summary.total} ready',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: summary.canCook
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Available ingredients from inventory
                  if (availableIngredients.isNotEmpty) ...[
                    ...availableIngredients.map(
                      (ing) => _IngredientChip(ingredient: ing),
                    ),
                  ],

                  // Missing ingredients hint
                  if (summary.missing > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 18,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${summary.missing} ingredient${summary.missing > 1 ? 's' : ''} not in inventory',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Pro tip if available
                  if (recipe.proTip != null && recipe.proTip!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.purple.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: AppColors.purple,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pro Tip',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.purple,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  recipe.proTip!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
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

/// Recipe header with icon and title
class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),

        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (recipe.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  recipe.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Quick stats row
class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.recipe,
    required this.summary,
  });

  final Recipe recipe;
  final IngredientSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.gray50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.schedule_rounded,
              label: recipe.cookTimeDisplay,
              color: colors.textSecondary,
            ),
          ),
          _VerticalDivider(color: colors.gray200),
          Expanded(
            child: _StatItem(
              icon: recipe.difficulty.icon,
              label: recipe.difficulty.displayName,
              color: recipe.difficulty.color,
            ),
          ),
          _VerticalDivider(color: colors.gray200),
          Expanded(
            child: _StatItem(
              icon: Icons.people_outline_rounded,
              label: recipe.servingsDisplay,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: color,
    );
  }
}

/// Ingredient chip showing name, quantity and status
class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.ingredient});

  final RecipeIngredientDisplay ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final isDark = theme.brightness == Brightness.dark;

    // Use alpha-based background that works in both light and dark mode
    final bgColor = isDark
        ? ingredient.status.color.withAlpha(38)
        : ingredient.status.bgColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ingredient.status.color.withAlpha(isDark ? 77 : 51),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ingredient.status.icon,
            size: 18,
            color: ingredient.status.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          Text(
            ingredient.quantity,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
