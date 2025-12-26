import 'package:flutter/material.dart';
import 'inventory_item.dart';
import 'recipe.dart';

/// Status of an ingredient when validated against inventory
enum IngredientStatus {
  inStock,      // Available and fresh
  expiringSoon, // Available but expiring soon
  expired,      // In inventory but expired
  missing;      // Not in inventory

  String get displayName {
    return switch (this) {
      IngredientStatus.inStock => 'In Stock',
      IngredientStatus.expiringSoon => 'Expiring Soon',
      IngredientStatus.expired => 'Expired',
      IngredientStatus.missing => 'Missing',
    };
  }

  IconData get icon {
    return switch (this) {
      IngredientStatus.inStock => Icons.check_circle_rounded,
      IngredientStatus.expiringSoon => Icons.warning_rounded,
      IngredientStatus.expired => Icons.cancel_rounded,
      IngredientStatus.missing => Icons.help_outline_rounded,
    };
  }

  Color get color {
    return switch (this) {
      IngredientStatus.inStock => const Color(0xFF22C55E),
      IngredientStatus.expiringSoon => const Color(0xFFF59E0B),
      IngredientStatus.expired => const Color(0xFFEF4444),
      IngredientStatus.missing => const Color(0xFF6B7280),
    };
  }

  Color get bgColor {
    return switch (this) {
      IngredientStatus.inStock => const Color(0xFFF0FDF4),
      IngredientStatus.expiringSoon => const Color(0xFFFEFCE8),
      IngredientStatus.expired => const Color(0xFFFEF2F2),
      IngredientStatus.missing => const Color(0xFFF9FAFB),
    };
  }
}

/// Ingredient with computed status for UI display
class RecipeIngredientDisplay {
  const RecipeIngredientDisplay({
    required this.ingredient,
    required this.status,
    this.inventoryItem,
    this.expiryText,
  });

  final RecipeIngredient ingredient;
  final IngredientStatus status;
  final InventoryItem? inventoryItem;
  final String? expiryText;

  /// Convenience getters
  String get name => ingredient.name;
  String get quantity => ingredient.quantity;

  bool get isAvailable => status == IngredientStatus.inStock;
  bool get isExpired => status == IngredientStatus.expired;
  bool get isExpiringSoon => status == IngredientStatus.expiringSoon;
  bool get isMissing => status == IngredientStatus.missing;

  /// Get status text for display
  String get statusText {
    if (expiryText != null) return expiryText!;
    return switch (status) {
      IngredientStatus.inStock => 'Available',
      IngredientStatus.expiringSoon => 'Use soon',
      IngredientStatus.expired => 'Expired',
      IngredientStatus.missing => 'Not in inventory',
    };
  }
}

/// Helper class to validate recipe ingredients against inventory
class RecipeValidator {
  const RecipeValidator._();

  /// Validate all ingredients of a recipe against current inventory
  static List<RecipeIngredientDisplay> validateIngredients(
    Recipe recipe,
    List<InventoryItem> inventory,
  ) {
    return recipe.ingredients.map((ingredient) {
      final inventoryItem = _findInInventory(ingredient.name, inventory);

      if (inventoryItem == null) {
        return RecipeIngredientDisplay(
          ingredient: ingredient,
          status: IngredientStatus.missing,
          expiryText: 'Tidak di inventory',
        );
      }

      // Check expiry status
      final status = switch (inventoryItem.expiryStatus) {
        ExpiryStatus.expired => IngredientStatus.expired,
        ExpiryStatus.expiringToday => IngredientStatus.expiringSoon,
        ExpiryStatus.expiringSoon => IngredientStatus.expiringSoon,
        ExpiryStatus.fresh => IngredientStatus.inStock,
      };

      return RecipeIngredientDisplay(
        ingredient: ingredient,
        status: status,
        inventoryItem: inventoryItem,
        expiryText: inventoryItem.expiryText,
      );
    }).toList();
  }

  /// Find matching item in inventory using fuzzy matching
  static InventoryItem? _findInInventory(
    String ingredientName,
    List<InventoryItem> inventory,
  ) {
    final normalized = ingredientName.toLowerCase().trim();

    // Try exact match first
    for (final item in inventory) {
      if (item.name.toLowerCase() == normalized) {
        return item;
      }
    }

    // Try contains match
    for (final item in inventory) {
      final itemName = item.name.toLowerCase();
      if (itemName.contains(normalized) || normalized.contains(itemName)) {
        return item;
      }
    }

    return null;
  }

  /// Get summary of ingredient statuses
  static IngredientSummary getSummary(List<RecipeIngredientDisplay> ingredients) {
    int inStock = 0;
    int expiringSoon = 0;
    int expired = 0;
    int missing = 0;

    for (final ing in ingredients) {
      switch (ing.status) {
        case IngredientStatus.inStock:
          inStock++;
        case IngredientStatus.expiringSoon:
          expiringSoon++;
        case IngredientStatus.expired:
          expired++;
        case IngredientStatus.missing:
          missing++;
      }
    }

    return IngredientSummary(
      total: ingredients.length,
      inStock: inStock,
      expiringSoon: expiringSoon,
      expired: expired,
      missing: missing,
    );
  }
}

/// Summary of ingredient statuses for a recipe
class IngredientSummary {
  const IngredientSummary({
    required this.total,
    required this.inStock,
    required this.expiringSoon,
    required this.expired,
    required this.missing,
  });

  final int total;
  final int inStock;
  final int expiringSoon;
  final int expired;
  final int missing;

  /// Check if all ingredients are available (in stock or expiring soon)
  bool get allAvailable => inStock + expiringSoon == total;

  /// Check if recipe can be cooked (no expired or missing)
  bool get canCook => expired == 0 && missing == 0;

  /// Get available count (in stock + expiring soon)
  int get available => inStock + expiringSoon;

  /// Get unavailable count (expired + missing)
  int get unavailable => expired + missing;
}
