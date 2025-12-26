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

  /// Get icon for category - uses ItemCategory enum as single source of truth
  IconData get categoryIcon => category.icon;

  /// Get color for category - uses ItemCategory enum as single source of truth
  Color get categoryColor => category.color;

  /// Get background color for category icon - uses ItemCategory enum
  Color get categoryBgColor => category.lightColor;

  /// Convert to InventoryItem for saving
  InventoryItem toInventoryItem({String? displayName}) {
    return InventoryItem(
      id: id,
      name: name.toLowerCase(),
      displayName: displayName ?? _capitalizeFirst(name),
      category: category,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      addedAt: DateTime.now(),
    );
  }

  /// Capitalize first letter of each word
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
