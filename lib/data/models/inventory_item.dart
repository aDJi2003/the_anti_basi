import 'package:flutter/material.dart';

/// Category for inventory items
enum ItemCategory {
  dairy,
  protein,
  vegetable,
  fruit,
  grain,
  condiment,
  beverage,
  other;

  String get displayName {
    return switch (this) {
      ItemCategory.dairy => 'Dairy',
      ItemCategory.protein => 'Protein',
      ItemCategory.vegetable => 'Vegetable',
      ItemCategory.fruit => 'Fruit',
      ItemCategory.grain => 'Grain',
      ItemCategory.condiment => 'Condiment',
      ItemCategory.beverage => 'Beverage',
      ItemCategory.other => 'Other',
    };
  }

  IconData get icon {
    return switch (this) {
      ItemCategory.dairy => Icons.local_drink_outlined,
      ItemCategory.protein => Icons.egg_outlined,
      ItemCategory.vegetable => Icons.eco_outlined,
      ItemCategory.fruit => Icons.apple,
      ItemCategory.grain => Icons.bakery_dining_outlined,
      ItemCategory.condiment => Icons.water_drop_outlined,
      ItemCategory.beverage => Icons.local_cafe_outlined,
      ItemCategory.other => Icons.inventory_2_outlined,
    };
  }

  Color get color {
    return switch (this) {
      ItemCategory.dairy => const Color(0xFF3B82F6), // Blue
      ItemCategory.protein => const Color(0xFFF97316), // Orange
      ItemCategory.vegetable => const Color(0xFF22C55E), // Green
      ItemCategory.fruit => const Color(0xFFA855F7), // Purple
      ItemCategory.grain => const Color(0xFFEAB308), // Yellow
      ItemCategory.condiment => const Color(0xFF14B8A6), // Teal
      ItemCategory.beverage => const Color(0xFF6366F1), // Indigo
      ItemCategory.other => const Color(0xFF6B7280), // Gray
    };
  }

  Color get lightColor {
    return switch (this) {
      ItemCategory.dairy => const Color(0xFFEFF6FF),
      ItemCategory.protein => const Color(0xFFFFF7ED),
      ItemCategory.vegetable => const Color(0xFFF0FDF4),
      ItemCategory.fruit => const Color(0xFFFAF5FF),
      ItemCategory.grain => const Color(0xFFFEFCE8),
      ItemCategory.condiment => const Color(0xFFF0FDFA),
      ItemCategory.beverage => const Color(0xFFEEF2FF),
      ItemCategory.other => const Color(0xFFF9FAFB),
    };
  }
}

/// Expiry status for inventory items
enum ExpiryStatus {
  fresh,
  expiringSoon,
  expiringToday,
  expired;

  String get displayName {
    return switch (this) {
      ExpiryStatus.fresh => 'Fresh',
      ExpiryStatus.expiringSoon => 'Expiring Soon',
      ExpiryStatus.expiringToday => 'Expires Today',
      ExpiryStatus.expired => 'Expired',
    };
  }
}

/// Inventory item model
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.imageUrl,
    this.addedAt,
  });

  final String id;
  final String name;
  final ItemCategory category;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final String? imageUrl;
  final DateTime? addedAt;

  /// Days until expiry (negative if expired)
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  /// Get expiry status
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) return ExpiryStatus.expired;
    if (days == 0) return ExpiryStatus.expiringToday;
    if (days <= 3) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.fresh;
  }

  /// Display string for quantity
  String get quantityDisplay => '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)}$unit';

  /// Copy with method
  InventoryItem copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? imageUrl,
    DateTime? addedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
