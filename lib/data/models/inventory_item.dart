import 'package:cloud_firestore/cloud_firestore.dart';
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
      ItemCategory.dairy => Icons.local_drink_outlined, // Milk/dairy products
      ItemCategory.protein => Icons.egg_outlined, // Eggs, meat, tofu
      ItemCategory.vegetable => Icons.eco_outlined, // Vegetables/greens
      ItemCategory.fruit => Icons.apple, // Fruits
      ItemCategory.grain => Icons.bakery_dining_outlined, // Bread, rice, pasta
      ItemCategory.condiment => Icons.local_dining_outlined, // Sauces, spices
      ItemCategory.beverage => Icons.local_cafe_outlined, // Drinks
      ItemCategory.other => Icons.inventory_2_outlined, // Misc items
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

  /// Convert string to ItemCategory enum
  static ItemCategory fromString(String value) {
    return ItemCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ItemCategory.other,
    );
  }
}

/// Expiry status for inventory items (computed, not stored)
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

  Color get color {
    return switch (this) {
      ExpiryStatus.fresh => const Color(0xFF22C55E), // Green
      ExpiryStatus.expiringSoon => const Color(0xFFF59E0B), // Amber
      ExpiryStatus.expiringToday => const Color(0xFFEF4444), // Red
      ExpiryStatus.expired => const Color(0xFF6B7280), // Gray
    };
  }
}

/// Inventory item model - matches Firestore schema
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.displayName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.addedAt,
  });

  final String id;
  final String name;           // "telur" - for matching/search
  final String displayName;    // "Telur Ayam" - for display
  final ItemCategory category;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final DateTime addedAt;

  // ============ COMPUTED GETTERS (not stored in Firestore) ============

  /// Whether item is fully consumed (quantity = 0)
  bool get isConsumed => quantity <= 0;

  /// Days until expiry (negative if expired)
  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  /// Get expiry status (computed from expiryDate)
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) return ExpiryStatus.expired;
    if (days == 0) return ExpiryStatus.expiringToday;
    if (days <= 3) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.fresh;
  }

  /// Display string for quantity (e.g., "10pcs", "500g")
  String get quantityDisplay {
    final qty = quantity.truncateToDouble() == quantity
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$qty $unit';
  }

  /// Human-readable expiry text
  String get expiryText {
    final days = daysUntilExpiry;
    if (days < 0) return 'Expired ${-days} day${-days == 1 ? '' : 's'} ago';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }

  // ============ FIRESTORE SERIALIZATION ============

  /// Create InventoryItem from Firestore document
  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      displayName: data['displayName'] as String? ?? data['name'] as String? ?? '',
      category: ItemCategory.fromString(data['category'] as String? ?? 'other'),
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'pcs',
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  // ============ COPY WITH ============

  /// Copy with method for immutable updates
  InventoryItem copyWith({
    String? id,
    String? name,
    String? displayName,
    ItemCategory? category,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    DateTime? addedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, displayName: $displayName, '
        'quantity: $quantity $unit, category: ${category.name}, '
        'expiryStatus: ${expiryStatus.name})';
  }
}
