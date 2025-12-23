import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/recipe.dart';
import 'recipe_controller.dart';
import 'widgets/ingredient_list_tile.dart';
import 'widgets/instruction_step_tile.dart';
import 'widgets/pro_tip_card.dart';

/// Recipe detail screen with collapsible header
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recipeControllerProvider);
    final controller = ref.read(recipeControllerProvider.notifier);

    // Find recipe by id
    final recipe = state.recipes.firstWhere(
      (r) => r.id == recipeId,
      orElse: () => state.selectedRecipe ?? _placeholderRecipe,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible header
          SliverAppBar(
            expandedHeight: 280,
            collapsedHeight: 80,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => controller.toggleBookmark(recipe.id),
                  icon: Icon(
                    recipe.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border_outlined,
                    color: AppColors.accent,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate how collapsed we are (0 = expanded, 1 = collapsed)
                  final expandRatio = ((constraints.maxHeight - 80) / (280 - 80))
                      .clamp(0.0, 1.0);
                  final isCollapsed = expandRatio < 0.3;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 1.0 : 0.0,
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              background: _ExpandedHeader(recipe: recipe),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Ingredients section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: _SectionHeader(
                      title: 'Ingredients',
                      trailing: Text(
                        '${recipe.ingredientsInStock} items in stock',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: recipe.ingredients.map((ingredient) {
                        return IngredientListTile(
                          ingredient: ingredient,
                          onAddTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${ingredient.name} to shopping list'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(title: 'Instructions'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: recipe.instructions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final instruction = entry.value;
                        return InstructionStepTile(
                          instruction: instruction,
                          isLast: index == recipe.instructions.length - 1,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pro tip
                  if (recipe.proTip != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProTipCard(tip: recipe.proTip!),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Done cooking button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.markDoneCooking(recipe.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Great job! Enjoy your meal!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Done Cooking',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expanded header content
class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recipe icon in circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: (recipe.iconColor ?? AppColors.primary).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                recipe.iconData ?? Icons.restaurant,
                color: recipe.iconColor ?? AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            // Recipe title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                recipe.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Info chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: recipe.cookTimeDisplay,
                ),
                const SizedBox(width: 8),
                if (recipe.calories != null) ...[
                  _InfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label: '${recipe.calories} kcal',
                  ),
                  const SizedBox(width: 8),
                ],
                _InfoChip(
                  icon: recipe.difficulty.icon,
                  label: recipe.difficulty.displayName,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Placeholder recipe for error states
final _placeholderRecipe = Recipe(
  id: '0',
  name: 'Recipe Not Found',
  cookTime: 0,
  difficulty: RecipeDifficulty.easy,
  servings: 0,
  ingredients: const [],
  instructions: const [],
);
