import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/recipe.dart';

/// Ingredient tile for recipe detail
class IngredientListTile extends StatelessWidget {
  const IngredientListTile({
    super.key,
    required this.ingredient,
    this.onAddTap,
  });

  final RecipeIngredient ingredient;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: ingredient.isInStock
            ? null
            : Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          // Ingredient icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIngredientIcon(ingredient.name),
              color: AppColors.mediumGrey,
              size: 20,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                Text(
                  ingredient.quantity,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          if (ingredient.isInStock)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 16,
              ),
            )
          else
            TextButton(
              onPressed: onAddTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '+ Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIngredientIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('egg')) return Icons.egg_outlined;
    if (lowerName.contains('avocado')) return Icons.eco_outlined;
    if (lowerName.contains('bread')) return Icons.bakery_dining_outlined;
    if (lowerName.contains('milk')) return Icons.local_drink_outlined;
    if (lowerName.contains('cheese')) return Icons.lunch_dining_outlined;
    if (lowerName.contains('spinach') || lowerName.contains('lettuce')) {
      return Icons.grass_outlined;
    }
    if (lowerName.contains('ham') || lowerName.contains('meat')) {
      return Icons.kebab_dining_outlined;
    }
    if (lowerName.contains('pasta')) return Icons.ramen_dining_outlined;
    if (lowerName.contains('chili') || lowerName.contains('pepper')) {
      return Icons.local_fire_department_outlined;
    }
    return Icons.restaurant_outlined;
  }
}
