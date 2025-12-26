import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/recipe_ingredient_display.dart';

/// Ingredient tile for recipe detail with dynamic validation status
class IngredientListTile extends StatelessWidget {
  const IngredientListTile({
    super.key,
    required this.ingredient,
  });

  final RecipeIngredientDisplay ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ingredient.status.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ingredient.status.color.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ingredient.status.color.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ingredient.status.icon,
              color: ingredient.status.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Name and quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredient.quantity,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Status text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ingredient.status.color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ingredient.statusText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: ingredient.status.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
