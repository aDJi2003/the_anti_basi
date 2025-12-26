import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/models/recipe.dart';
import '../../../data/models/recipe_ingredient_display.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/recipe_repository.dart';
import '../../../data/services/gemini_service.dart';

/// State for recipe screen
class RecipeState {
  const RecipeState({
    this.savedRecipes = const [],
    this.generatedRecipes = const [],
    this.inventory = const [],
    this.selectedRecipe,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.expiringItemNames = const [],
  });

  final List<Recipe> savedRecipes;
  final List<Recipe> generatedRecipes; // For preview screen
  final List<InventoryItem> inventory;
  final Recipe? selectedRecipe;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final List<String> expiringItemNames;

  /// Check if has saved recipes
  bool get hasSavedRecipes => savedRecipes.isNotEmpty;

  /// Check if has generated recipes (for preview)
  bool get hasGeneratedRecipes => generatedRecipes.isNotEmpty;

  /// Get selected count for preview
  int get selectedCount => generatedRecipes.where((r) => r.isSelected).length;

  /// Get expiring items count
  int get expiringCount => expiringItemNames.length;

  RecipeState copyWith({
    List<Recipe>? savedRecipes,
    List<Recipe>? generatedRecipes,
    List<InventoryItem>? inventory,
    Recipe? selectedRecipe,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    List<String>? expiringItemNames,
  }) {
    return RecipeState(
      savedRecipes: savedRecipes ?? this.savedRecipes,
      generatedRecipes: generatedRecipes ?? this.generatedRecipes,
      inventory: inventory ?? this.inventory,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      expiringItemNames: expiringItemNames ?? this.expiringItemNames,
    );
  }
}

/// Recipe controller using Riverpod Notifier pattern
class RecipeController extends Notifier<RecipeState> {
  late final RecipeRepository _recipeRepository;
  late final InventoryRepository _inventoryRepository;
  late final GeminiService _geminiService;

  @override
  RecipeState build() {
    _recipeRepository = ref.watch(recipeRepositoryProvider);
    _inventoryRepository = ref.watch(inventoryRepositoryProvider);
    _geminiService = ref.watch(geminiServiceProvider);

    // Load initial data
    _loadData();
    return const RecipeState(isLoading: true);
  }

  /// Load saved recipes and inventory
  Future<void> _loadData() async {
    try {
      debugPrint('[RecipeController] Loading data...');

      // Fetch saved recipes and inventory in parallel
      final results = await Future.wait([
        _recipeRepository.getSavedRecipes(),
        _inventoryRepository.getInventory(),
      ]);

      final savedRecipes = results[0] as List<Recipe>;
      final inventory = results[1] as List<InventoryItem>;

      // Get expiring items
      final expiringNames = inventory
          .where((i) => i.daysUntilExpiry <= 3 && i.daysUntilExpiry >= 0)
          .map((i) => i.name)
          .toList();

      debugPrint('[RecipeController] Loaded ${savedRecipes.length} recipes, ${inventory.length} items');

      state = state.copyWith(
        savedRecipes: savedRecipes,
        inventory: inventory,
        expiringItemNames: expiringNames,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[RecipeController] ERROR loading data: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load recipes',
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadData();
  }

  /// Generate recipes using Gemini AI
  Future<void> generateRecipes(BuildContext context) async {
    if (state.inventory.isEmpty) {
      _showSnackBar(context, 'Tambahkan bahan ke inventory dulu', isError: true);
      return;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      debugPrint('[RecipeController] Generating recipes...');

      final recipes = await _geminiService.generateRecipes(state.inventory);

      if (recipes.isEmpty) {
        state = state.copyWith(isGenerating: false);
        if (context.mounted) {
          _showSnackBar(context, 'Tidak dapat generate resep. Coba lagi.', isError: true);
        }
        return;
      }

      debugPrint('[RecipeController] Generated ${recipes.length} recipes');

      state = state.copyWith(
        generatedRecipes: recipes,
        isGenerating: false,
      );

      // Navigate to preview screen
      if (context.mounted) {
        context.push(Routes.recipePreview);
      }
    } catch (e) {
      debugPrint('[RecipeController] ERROR generating recipes: $e');
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate recipes',
      );
      if (context.mounted) {
        _showSnackBar(context, 'Gagal generate resep: $e', isError: true);
      }
    }
  }

  /// Toggle recipe selection in preview
  void toggleRecipeSelection(String recipeId) {
    final updatedRecipes = state.generatedRecipes.map((recipe) {
      if (recipe.id == recipeId) {
        return recipe.copyWith(isSelected: !recipe.isSelected);
      }
      return recipe;
    }).toList();

    state = state.copyWith(generatedRecipes: updatedRecipes);
  }

  /// Save selected recipes from preview
  Future<void> saveSelectedRecipes(BuildContext context) async {
    final selectedRecipes = state.generatedRecipes
        .where((r) => r.isSelected)
        .toList();

    if (selectedRecipes.isEmpty) {
      _showSnackBar(context, 'Pilih minimal 1 resep untuk disimpan', isError: true);
      return;
    }

    try {
      debugPrint('[RecipeController] Saving ${selectedRecipes.length} recipes...');

      await _recipeRepository.saveRecipes(selectedRecipes);

      // Refresh saved recipes
      final updatedSavedRecipes = await _recipeRepository.getSavedRecipes();

      state = state.copyWith(
        savedRecipes: updatedSavedRecipes,
        generatedRecipes: [], // Clear preview
      );

      if (context.mounted) {
        _showSnackBar(context, '${selectedRecipes.length} resep disimpan!');
        context.pop(); // Go back to recipe screen
      }
    } catch (e) {
      debugPrint('[RecipeController] ERROR saving recipes: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Gagal menyimpan resep', isError: true);
      }
    }
  }

  /// Delete saved recipe
  Future<void> deleteRecipe(String recipeId, BuildContext context) async {
    try {
      await _recipeRepository.deleteRecipe(recipeId);

      final updatedRecipes = state.savedRecipes
          .where((r) => r.id != recipeId)
          .toList();

      state = state.copyWith(savedRecipes: updatedRecipes);

      if (context.mounted) {
        _showSnackBar(context, 'Resep dihapus');
      }
    } catch (e) {
      debugPrint('[RecipeController] ERROR deleting recipe: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Gagal menghapus resep', isError: true);
      }
    }
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

  /// Validate ingredients for selected recipe
  List<RecipeIngredientDisplay> validateSelectedRecipeIngredients() {
    final recipe = state.selectedRecipe;
    if (recipe == null) return [];

    return RecipeValidator.validateIngredients(recipe, state.inventory);
  }

  /// Get ingredient summary for selected recipe
  IngredientSummary? getSelectedRecipeSummary() {
    final ingredients = validateSelectedRecipeIngredients();
    if (ingredients.isEmpty) return null;

    return RecipeValidator.getSummary(ingredients);
  }

  /// Get ingredient summary for a specific recipe
  IngredientSummary getRecipeSummary(Recipe recipe) {
    final ingredients = RecipeValidator.validateIngredients(recipe, state.inventory);
    return RecipeValidator.getSummary(ingredients);
  }

  /// Clear generated recipes (cancel preview)
  void clearGeneratedRecipes() {
    state = state.copyWith(generatedRecipes: []);
  }

  /// Show snackbar
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Provider for recipe controller
final recipeControllerProvider =
    NotifierProvider<RecipeController, RecipeState>(RecipeController.new);
