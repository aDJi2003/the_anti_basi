import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/recipe.dart';

/// Recipe card for vertical list display (matches UI reference)
class RecipeListCard extends StatelessWidget {
  const RecipeListCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onBookmarkTap,
  });

  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon + Title + Bookmark
            Row(
              children: [
                // Food icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (recipe.iconColor ?? AppColors.primary).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    recipe.iconData ?? Icons.restaurant,
                    color: recipe.iconColor ?? AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Time, difficulty, servings
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.cookTimeDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          _buildDot(),
                          Icon(
                            Icons.signal_cellular_alt,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.difficulty.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          _buildDot(),
                          Text(
                            recipe.servingsDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bookmark button
                IconButton(
                  onPressed: onBookmarkTap,
                  icon: Icon(
                    recipe.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                    color: recipe.isBookmarked
                        ? AppColors.primary
                        : AppColors.mediumGrey,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Ingredient chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipe.ingredients.map((ingredient) {
                return _IngredientChip(
                  name: ingredient.name,
                  isInStock: ingredient.isInStock,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Ingredient chip showing availability status
class _IngredientChip extends StatelessWidget {
  const _IngredientChip({
    required this.name,
    required this.isInStock,
  });

  final String name;
  final bool isInStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isInStock
            ? AppColors.primary.withAlpha(26)
            : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
        border: isInStock
            ? Border.all(color: AppColors.primary.withAlpha(51))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isInStock) ...[
            Icon(
              Icons.check,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isInStock ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
