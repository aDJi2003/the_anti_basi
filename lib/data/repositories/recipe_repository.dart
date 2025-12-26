import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';

/// Repository for recipe Firestore operations (savedRecipes collection)
class RecipeRepository {
  RecipeRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Get saved recipes collection reference for current user
  CollectionReference<Map<String, dynamic>> get _savedRecipesCollection {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('savedRecipes');
  }

  // ============ READ OPERATIONS ============

  /// Stream all saved recipes (real-time updates)
  Stream<List<Recipe>> watchSavedRecipes() {
    try {
      debugPrint('[RecipeRepo] watchSavedRecipes - userId: $_userId');
      return _savedRecipesCollection
          .orderBy('savedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            debugPrint('[RecipeRepo] Got ${snapshot.docs.length} saved recipes');
            return snapshot.docs
                .map((doc) => Recipe.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      debugPrint('[RecipeRepo] watchSavedRecipes error: $e');
      return Stream.value([]);
    }
  }

  /// Get all saved recipes (one-time fetch)
  Future<List<Recipe>> getSavedRecipes() async {
    final userId = _userId;
    debugPrint('[RecipeRepo] getSavedRecipes - userId: $userId');

    if (userId == null) {
      debugPrint('[RecipeRepo] ERROR: User not authenticated');
      return [];
    }

    try {
      final snapshot = await _savedRecipesCollection
          .orderBy('savedAt', descending: true)
          .get();

      debugPrint('[RecipeRepo] Got ${snapshot.docs.length} saved recipes');

      return snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();
    } catch (e, stack) {
      debugPrint('[RecipeRepo] ERROR fetching saved recipes: $e');
      debugPrint('[RecipeRepo] Stack: $stack');
      return [];
    }
  }

  /// Get single recipe by ID
  Future<Recipe?> getRecipe(String recipeId) async {
    try {
      final doc = await _savedRecipesCollection.doc(recipeId).get();
      if (!doc.exists) return null;
      return Recipe.fromFirestore(doc);
    } catch (e) {
      debugPrint('[RecipeRepo] ERROR fetching recipe: $e');
      return null;
    }
  }

  /// Get saved recipes count
  Future<int> getSavedRecipesCount() async {
    try {
      final snapshot = await _savedRecipesCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ============ WRITE OPERATIONS ============

  /// Save single recipe
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      debugPrint('[RecipeRepo] Saving recipe: ${recipe.name}');
      final recipeWithSavedAt = recipe.copyWith(savedAt: DateTime.now());
      await _savedRecipesCollection.doc(recipe.id).set(recipeWithSavedAt.toFirestore());
      debugPrint('[RecipeRepo] Recipe saved successfully');
    } catch (e) {
      debugPrint('[RecipeRepo] ERROR saving recipe: $e');
      throw Exception('Failed to save recipe: $e');
    }
  }

  /// Save multiple recipes (batch)
  Future<void> saveRecipes(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;

    try {
      debugPrint('[RecipeRepo] Saving ${recipes.length} recipes');
      final batch = _firestore.batch();
      final now = DateTime.now();

      for (final recipe in recipes) {
        final recipeWithSavedAt = recipe.copyWith(savedAt: now);
        final docRef = _savedRecipesCollection.doc(recipe.id);
        batch.set(docRef, recipeWithSavedAt.toFirestore());
      }

      await batch.commit();
      debugPrint('[RecipeRepo] ${recipes.length} recipes saved successfully');
    } catch (e) {
      debugPrint('[RecipeRepo] ERROR saving recipes: $e');
      throw Exception('Failed to save recipes: $e');
    }
  }

  /// Delete saved recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      debugPrint('[RecipeRepo] Deleting recipe: $recipeId');
      await _savedRecipesCollection.doc(recipeId).delete();
      debugPrint('[RecipeRepo] Recipe deleted successfully');
    } catch (e) {
      debugPrint('[RecipeRepo] ERROR deleting recipe: $e');
      throw Exception('Failed to delete recipe: $e');
    }
  }

  /// Delete multiple recipes (batch)
  Future<void> deleteRecipes(List<String> recipeIds) async {
    if (recipeIds.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final recipeId in recipeIds) {
        final docRef = _savedRecipesCollection.doc(recipeId);
        batch.delete(docRef);
      }

      await batch.commit();
      debugPrint('[RecipeRepo] ${recipeIds.length} recipes deleted');
    } catch (e) {
      debugPrint('[RecipeRepo] ERROR deleting recipes: $e');
      throw Exception('Failed to delete recipes: $e');
    }
  }

  /// Clear all saved recipes
  Future<void> clearSavedRecipes() async {
    try {
      final snapshot = await _savedRecipesCollection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('[RecipeRepo] All saved recipes cleared');
    } catch (e) {
      debugPrint('[RecipeRepo] ERROR clearing recipes: $e');
      throw Exception('Failed to clear saved recipes: $e');
    }
  }
}

// ============ PROVIDERS ============

/// Provider for recipe repository
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

/// Provider for saved recipes stream (real-time updates)
final savedRecipesStreamProvider = StreamProvider<List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.watchSavedRecipes();
});
