import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/recipe.dart';
import '../../../../data/models/recipe_ingredient_display.dart';
import '../recipe_controller.dart';

/// Recipe suggestion widget for home screen
/// Shows saved recipes with ingredient validation status
class RecipeSuggestion extends ConsumerWidget {
  const RecipeSuggestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recipeControllerProvider);
    final controller = ref.read(recipeControllerProvider.notifier);

    if (state.isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.savedRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show max 3 recipes on home screen
    final recipesToShow = state.savedRecipes.take(3).toList();

    return Column(
      children: recipesToShow.map((recipe) {
        final summary = controller.getRecipeSummary(recipe);
        return _HomeRecipeCard(
          recipe: recipe,
          summary: summary,
          onTap: () => controller.navigateToDetail(context, recipe),
        );
      }).toList(),
    );
  }
}

/// Recipe card for home screen
class _HomeRecipeCard extends StatelessWidget {
  const _HomeRecipeCard({
    required this.recipe,
    required this.summary,
    required this.onTap,
  });

  final Recipe recipe;
  final IngredientSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Recipe info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Cook time & difficulty
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.cookTimeDisplay,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                      _buildDot(isDark),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: recipe.difficulty.color.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.difficulty.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: recipe.difficulty.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ingredient status
                  _IngredientBadges(summary: summary),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkTextMuted : AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Ingredient status badges
class _IngredientBadges extends StatelessWidget {
  const _IngredientBadges({required this.summary});

  final IngredientSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Available count
        _buildBadge(
          icon: Icons.check_circle_rounded,
          text: '${summary.available}/${summary.total}',
          color: summary.canCook ? AppColors.success : AppColors.warning,
          theme: theme,
        ),

        // Warning indicators
        if (summary.expiringSoon > 0) ...[
          const SizedBox(width: 6),
          _buildBadge(
            icon: Icons.warning_rounded,
            text: '${summary.expiringSoon}',
            color: AppColors.warning,
            theme: theme,
          ),
        ],
        if (summary.missing > 0) ...[
          const SizedBox(width: 6),
          _buildBadge(
            icon: Icons.help_outline_rounded,
            text: '${summary.missing}',
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray500,
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
