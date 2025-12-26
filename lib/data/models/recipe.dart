import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Difficulty level for recipes
enum RecipeDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    return switch (this) {
      RecipeDifficulty.easy => 'Easy',
      RecipeDifficulty.medium => 'Medium',
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

  Color get color {
    return switch (this) {
      RecipeDifficulty.easy => const Color(0xFF22C55E),
      RecipeDifficulty.medium => const Color(0xFFF59E0B),
      RecipeDifficulty.hard => const Color(0xFFEF4444),
    };
  }

  /// Parse from string
  static RecipeDifficulty fromString(String value) {
    return RecipeDifficulty.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => RecipeDifficulty.easy,
    );
  }
}

/// Ingredient for a recipe (stored in Firestore)
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.quantity,
  });

  final String name;
  final String quantity;

  // ============ FIRESTORE SERIALIZATION ============

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String? ?? '',
      quantity: map['quantity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  RecipeIngredient copyWith({
    String? name,
    String? quantity,
  }) {
    return RecipeIngredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
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

  // ============ FIRESTORE SERIALIZATION ============

  factory RecipeInstruction.fromMap(Map<String, dynamic> map) {
    return RecipeInstruction(
      stepNumber: map['stepNumber'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
    };
  }
}

/// Recipe model with Firestore serialization
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    this.description,
    required this.cookTime,
    required this.difficulty,
    required this.servings,
    this.calories,
    this.proTip,
    this.usesExpiringItems = const [],
    required this.ingredients,
    required this.instructions,
    this.savedAt,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String? description;
  final int cookTime; // in minutes
  final RecipeDifficulty difficulty;
  final int servings;
  final int? calories;
  final String? proTip;
  final List<String> usesExpiringItems; // Items that are expiring soon
  final List<RecipeIngredient> ingredients;
  final List<RecipeInstruction> instructions;
  final DateTime? savedAt;
  final bool isSelected; // For preview screen selection

  // ============ COMPUTED GETTERS ============

  /// Get cook time display string
  String get cookTimeDisplay => '$cookTime min';

  /// Get servings display string
  String get servingsDisplay => '$servings porsi';

  /// Check if recipe is saved
  bool get isSaved => savedAt != null;

  // ============ FIRESTORE SERIALIZATION ============

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Recipe(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      cookTime: data['cookTime'] as int? ?? 0,
      difficulty: RecipeDifficulty.fromString(data['difficulty'] as String? ?? 'easy'),
      servings: data['servings'] as int? ?? 1,
      calories: data['calories'] as int?,
      proTip: data['proTip'] as String?,
      usesExpiringItems: List<String>.from(data['usesExpiringItems'] ?? []),
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map((i) => RecipeIngredient.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      instructions: (data['instructions'] as List<dynamic>?)
              ?.map((i) => RecipeInstruction.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      savedAt: (data['savedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'cookTime': cookTime,
      'difficulty': difficulty.name,
      'servings': servings,
      'calories': calories,
      'proTip': proTip,
      'usesExpiringItems': usesExpiringItems,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions.map((i) => i.toMap()).toList(),
      'savedAt': savedAt != null ? Timestamp.fromDate(savedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Create from Gemini JSON response
  factory Recipe.fromGeminiJson(Map<String, dynamic> json, String id) {
    return Recipe(
      id: id,
      name: json['name'] as String? ?? 'Unnamed Recipe',
      description: json['description'] as String?,
      cookTime: json['cookTime'] as int? ?? 15,
      difficulty: RecipeDifficulty.fromString(json['difficulty'] as String? ?? 'easy'),
      servings: json['servings'] as int? ?? 2,
      calories: json['calories'] as int?,
      proTip: json['proTip'] as String?,
      usesExpiringItems: List<String>.from(json['usesExpiringItems'] ?? []),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) => RecipeIngredient.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((i) => RecipeInstruction.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      isSelected: true, // Default selected in preview
    );
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    int? cookTime,
    RecipeDifficulty? difficulty,
    int? servings,
    int? calories,
    String? proTip,
    List<String>? usesExpiringItems,
    List<RecipeIngredient>? ingredients,
    List<RecipeInstruction>? instructions,
    DateTime? savedAt,
    bool? isSelected,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      proTip: proTip ?? this.proTip,
      usesExpiringItems: usesExpiringItems ?? this.usesExpiringItems,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      savedAt: savedAt ?? this.savedAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, cookTime: $cookTime, difficulty: ${difficulty.name})';
  }
}
