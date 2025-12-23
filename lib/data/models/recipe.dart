import 'package:flutter/material.dart';

/// Difficulty level for recipes
enum RecipeDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    return switch (this) {
      RecipeDifficulty.easy => 'Easy',
      RecipeDifficulty.medium => 'Med',
      RecipeDifficulty.hard => 'Hard',
    };
  }

  IconData get icon {
    return switch (this) {
      RecipeDifficulty.easy => Icons.sentiment_satisfied_outlined,
      RecipeDifficulty.medium => Icons.whatshot_outlined,
      RecipeDifficulty.hard => Icons.local_fire_department,
    };
  }
}

/// Ingredient for a recipe
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.quantity,
    this.iconPath,
    this.isInStock = false,
  });

  final String name;
  final String quantity;
  final String? iconPath;
  final bool isInStock;

  RecipeIngredient copyWith({
    String? name,
    String? quantity,
    String? iconPath,
    bool? isInStock,
  }) {
    return RecipeIngredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      iconPath: iconPath ?? this.iconPath,
      isInStock: isInStock ?? this.isInStock,
    );
  }
}

/// Instruction step for a recipe
class RecipeInstruction {
  const RecipeInstruction({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  final int stepNumber;
  final String title;
  final String description;
}

/// Recipe model
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.cookTime,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    this.calories,
    this.iconData,
    this.iconColor,
    this.imageUrl,
    this.proTip,
    this.isBookmarked = false,
  });

  final String id;
  final String name;
  final int cookTime; // in minutes
  final RecipeDifficulty difficulty;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<RecipeInstruction> instructions;
  final int? calories;
  final IconData? iconData;
  final Color? iconColor;
  final String? imageUrl;
  final String? proTip;
  final bool isBookmarked;

  /// Get cook time display string
  String get cookTimeDisplay => '$cookTime min';

  /// Get servings display string
  String get servingsDisplay => '$servings serv';

  /// Get number of ingredients in stock
  int get ingredientsInStock =>
      ingredients.where((i) => i.isInStock).length;

  /// Get ingredients that are available from inventory
  List<RecipeIngredient> get availableIngredients =>
      ingredients.where((i) => i.isInStock).toList();

  /// Get ingredients that need to be added
  List<RecipeIngredient> get missingIngredients =>
      ingredients.where((i) => !i.isInStock).toList();

  Recipe copyWith({
    String? id,
    String? name,
    int? cookTime,
    RecipeDifficulty? difficulty,
    int? servings,
    List<RecipeIngredient>? ingredients,
    List<RecipeInstruction>? instructions,
    int? calories,
    IconData? iconData,
    Color? iconColor,
    String? imageUrl,
    String? proTip,
    bool? isBookmarked,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      calories: calories ?? this.calories,
      iconData: iconData ?? this.iconData,
      iconColor: iconColor ?? this.iconColor,
      imageUrl: imageUrl ?? this.imageUrl,
      proTip: proTip ?? this.proTip,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
