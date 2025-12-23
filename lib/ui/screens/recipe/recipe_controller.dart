import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/recipe.dart';

/// State for recipe screens
class RecipeState {
  const RecipeState({
    this.recipes = const [],
    this.bookmarkedRecipes = const [],
    this.selectedRecipe,
    this.isLoading = false,
    this.urgentMessage,
    this.expiringItems = const [],
  });

  final List<Recipe> recipes;
  final List<Recipe> bookmarkedRecipes;
  final Recipe? selectedRecipe;
  final bool isLoading;
  final String? urgentMessage;
  final List<String> expiringItems; // Items expiring soon for banner

  RecipeState copyWith({
    List<Recipe>? recipes,
    List<Recipe>? bookmarkedRecipes,
    Recipe? selectedRecipe,
    bool? isLoading,
    String? urgentMessage,
    List<String>? expiringItems,
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      bookmarkedRecipes: bookmarkedRecipes ?? this.bookmarkedRecipes,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
      isLoading: isLoading ?? this.isLoading,
      urgentMessage: urgentMessage ?? this.urgentMessage,
      expiringItems: expiringItems ?? this.expiringItems,
    );
  }
}

/// Recipe controller using Riverpod Notifier pattern
class RecipeController extends Notifier<RecipeState> {
  @override
  RecipeState build() {
    // Load initial data
    _loadRecipes();
    return const RecipeState(isLoading: true);
  }

  /// Load recipes (mock data for now, later from Gemini)
  Future<void> _loadRecipes() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data matching the UI reference
    final mockRecipes = [
      Recipe(
        id: '1',
        name: 'Spinach & Cheese Omelet',
        cookTime: 15,
        difficulty: RecipeDifficulty.easy,
        servings: 2,
        calories: 280,
        iconData: Icons.egg_alt_outlined,
        iconColor: const Color(0xFFF97316),
        ingredients: [
          const RecipeIngredient(name: 'Spinach', quantity: '1 cup', isInStock: true),
          const RecipeIngredient(name: 'Eggs', quantity: '3 pcs', isInStock: true),
          const RecipeIngredient(name: 'Cheddar', quantity: '50g', isInStock: false),
        ],
        instructions: [
          const RecipeInstruction(
            stepNumber: 1,
            title: 'Prepare ingredients',
            description: 'Wash spinach and crack eggs into a bowl. Beat eggs with salt and pepper.',
          ),
          const RecipeInstruction(
            stepNumber: 2,
            title: 'Cook spinach',
            description: 'Sauté spinach in butter until wilted, about 2 minutes.',
          ),
          const RecipeInstruction(
            stepNumber: 3,
            title: 'Make omelet',
            description: 'Pour eggs over spinach, add cheese, fold and serve.',
          ),
        ],
        proTip: 'Use room temperature eggs for a fluffier omelet.',
      ),
      Recipe(
        id: '2',
        name: 'Creamy Milk Pasta',
        cookTime: 20,
        difficulty: RecipeDifficulty.medium,
        servings: 1,
        calories: 450,
        iconData: Icons.ramen_dining,
        iconColor: const Color(0xFF3B82F6),
        ingredients: [
          const RecipeIngredient(name: 'Milk', quantity: '200ml', isInStock: true),
          const RecipeIngredient(name: 'Pasta', quantity: '100g', isInStock: false),
          const RecipeIngredient(name: 'Butter', quantity: '2 tbsp', isInStock: false),
        ],
        instructions: [
          const RecipeInstruction(
            stepNumber: 1,
            title: 'Boil pasta',
            description: 'Cook pasta according to package directions until al dente.',
          ),
          const RecipeInstruction(
            stepNumber: 2,
            title: 'Make sauce',
            description: 'Melt butter in a pan, add milk and simmer until slightly thickened.',
          ),
          const RecipeInstruction(
            stepNumber: 3,
            title: 'Combine',
            description: 'Toss pasta with sauce, season with salt and pepper.',
          ),
        ],
        proTip: 'Save pasta water to adjust sauce consistency.',
      ),
      Recipe(
        id: '3',
        name: 'Quick Ham Sandwich',
        cookTime: 5,
        difficulty: RecipeDifficulty.easy,
        servings: 1,
        calories: 320,
        iconData: Icons.lunch_dining,
        iconColor: const Color(0xFFEF4444),
        ingredients: [
          const RecipeIngredient(name: 'Ham', quantity: '2 slices', isInStock: true),
          const RecipeIngredient(name: 'Lettuce', quantity: '2 leaves', isInStock: true),
          const RecipeIngredient(name: 'Bread', quantity: '2 slices', isInStock: false),
        ],
        instructions: [
          const RecipeInstruction(
            stepNumber: 1,
            title: 'Toast bread',
            description: 'Toast bread slices until golden brown.',
          ),
          const RecipeInstruction(
            stepNumber: 2,
            title: 'Assemble',
            description: 'Layer ham and lettuce on bread. Add condiments as desired.',
          ),
        ],
      ),
    ];

    state = state.copyWith(
      recipes: mockRecipes,
      isLoading: false,
      expiringItems: ['milk', 'spinach'],
      urgentMessage: 'Use your milk and spinach before Sunday.',
    );
  }

  /// Refresh recipes
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadRecipes();
  }

  /// Toggle bookmark for a recipe
  void toggleBookmark(String recipeId) {
    final updatedRecipes = state.recipes.map((recipe) {
      if (recipe.id == recipeId) {
        return recipe.copyWith(isBookmarked: !recipe.isBookmarked);
      }
      return recipe;
    }).toList();

    final bookmarked = updatedRecipes.where((r) => r.isBookmarked).toList();

    state = state.copyWith(
      recipes: updatedRecipes,
      bookmarkedRecipes: bookmarked,
    );
  }

  /// Select a recipe for detail view
  void selectRecipe(Recipe recipe) {
    state = state.copyWith(selectedRecipe: recipe);
  }

  /// Navigate to recipe detail
  void navigateToDetail(BuildContext context, Recipe recipe) {
    selectRecipe(recipe);
    context.push('${Routes.recipes}/${recipe.id}');
  }

  /// Handle AI query for recipes
  Future<void> onAiQuery(String query, BuildContext context) async {
    // TODO: Implement Gemini AI query for recipes
    // For now, just show a snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching recipes for: $query'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  /// Mark recipe as done cooking
  void markDoneCooking(String recipeId) {
    // TODO: Update inventory (reduce quantities)
    // For now just show feedback
  }
}

/// Provider for recipe controller
final recipeControllerProvider =
    NotifierProvider<RecipeController, RecipeState>(RecipeController.new);
