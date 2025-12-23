import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../recipe_controller.dart';
import 'recipe_list_card.dart';

/// Recipe suggestion widget for home screen
/// Uses the same RecipeListCard as recipe suggestions screen for consistency
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

    if (state.recipes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show max 3 recipes on home screen
    final recipesToShow = state.recipes.take(3).toList();

    return Column(
      children: recipesToShow.map((recipe) {
        return RecipeListCard(
          recipe: recipe,
          onTap: () => controller.navigateToDetail(context, recipe),
          onBookmarkTap: () => controller.toggleBookmark(recipe.id),
        );
      }).toList(),
    );
  }
}
