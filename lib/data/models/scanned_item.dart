import 'package:flutter/material.dart';
import 'inventory_item.dart';

/// Represents an item detected from camera scan
class ScannedItem {
  ScannedItem({
    required this.id,
    required this.name,
    this.category = ItemCategory.other,
    this.quantity = 1,
    this.unit = 'pcs',
    this.expiryDate,
    this.isSelected = true,
    this.confidence = 1.0,
    this.isUnknown = false,
  });

  final String id;
  String name;
  ItemCategory category;
  double quantity;
  String unit;
  DateTime? expiryDate;
  bool isSelected;
  final double confidence; // AI detection confidence 0-1
  final bool isUnknown; // Could not detect details

  /// Get icon for category
  IconData get categoryIcon {
    switch (category) {
      case ItemCategory.dairy:
        return Icons.local_drink_outlined;
      case ItemCategory.protein:
        return Icons.egg_outlined;
      case ItemCategory.vegetable:
        return Icons.grass_outlined;
      case ItemCategory.fruit:
        return Icons.apple;
      case ItemCategory.grain:
        return Icons.bakery_dining_outlined;
      case ItemCategory.condiment:
        return Icons.local_dining_outlined;
      case ItemCategory.beverage:
        return Icons.local_cafe_outlined;
      case ItemCategory.other:
        return Icons.bubble_chart_outlined;
    }
  }

  /// Get color for category
  Color get categoryColor {
    switch (category) {
      case ItemCategory.dairy:
        return const Color(0xFF3B82F6); // blue
      case ItemCategory.protein:
        return const Color(0xFFEAB308); // yellow
      case ItemCategory.vegetable:
        return const Color(0xFF22C55E); // green
      case ItemCategory.fruit:
        return const Color(0xFFF97316); // orange
      case ItemCategory.grain:
        return const Color(0xFFA855F7); // purple
      case ItemCategory.condiment:
        return const Color(0xFFEC4899); // pink
      case ItemCategory.beverage:
        return const Color(0xFF06B6D4); // cyan
      case ItemCategory.other:
        return const Color(0xFF8B5CF6); // violet
    }
  }

  /// Get background color for category icon
  Color get categoryBgColor {
    return categoryColor.withAlpha(26); // 10% opacity
  }

  /// Convert to InventoryItem for saving
  InventoryItem toInventoryItem() {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 7)),
    );
  }

  /// Create a copy with updated fields
  ScannedItem copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    bool? isSelected,
    double? confidence,
    bool? isUnknown,
  }) {
    return ScannedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      isSelected: isSelected ?? this.isSelected,
      confidence: confidence ?? this.confidence,
      isUnknown: isUnknown ?? this.isUnknown,
    );
  }
}
