import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import 'widgets/inventory_filter_chips.dart';

/// Inventory screen state
class InventoryState {
  const InventoryState({
    this.isLoading = false,
    this.allItems = const [],
    this.searchQuery = '',
    this.selectedFilter = InventoryFilter.all,
    this.errorMessage,
  });

  final bool isLoading;
  final List<InventoryItem> allItems;
  final String searchQuery;
  final InventoryFilter selectedFilter;
  final String? errorMessage;

  /// Get filtered items based on search and filter
  List<InventoryItem> get filteredItems {
    var items = allItems;

    // Apply search filter (search by displayName or name)
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      items = items
          .where((i) =>
              i.displayName.toLowerCase().contains(query) ||
              i.name.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    switch (selectedFilter) {
      case InventoryFilter.all:
        break;
      case InventoryFilter.expiringSoon:
        items = items
            .where((i) =>
                i.expiryStatus == ExpiryStatus.expiringSoon ||
                i.expiryStatus == ExpiryStatus.expiringToday ||
                i.expiryStatus == ExpiryStatus.expired)
            .toList();
        break;
      case InventoryFilter.fresh:
        items = items.where((i) => i.expiryStatus == ExpiryStatus.fresh).toList();
        break;
      case InventoryFilter.frozen:
        // TODO: Add frozen category support
        items = [];
        break;
    }

    return items;
  }

  /// Get expiring items (today or soon)
  List<InventoryItem> get expiringItems => filteredItems
      .where((i) =>
          i.expiryStatus == ExpiryStatus.expired ||
          i.expiryStatus == ExpiryStatus.expiringToday ||
          i.expiryStatus == ExpiryStatus.expiringSoon)
      .toList()
    ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

  /// Get fresh items
  List<InventoryItem> get freshItems => filteredItems
      .where((i) => i.expiryStatus == ExpiryStatus.fresh)
      .toList()
    ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

  InventoryState copyWith({
    bool? isLoading,
    List<InventoryItem>? allItems,
    String? searchQuery,
    InventoryFilter? selectedFilter,
    String? errorMessage,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      allItems: allItems ?? this.allItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage,
    );
  }
}

/// Inventory controller - handles inventory screen logic
class InventoryController extends Notifier<InventoryState> {
  @override
  InventoryState build() {
    _loadData();
    return const InventoryState(isLoading: true);
  }

  /// Load inventory data
  Future<void> _loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final dummyItems = _getDummyItems();

      state = state.copyWith(
        isLoading: false,
        allItems: dummyItems,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }

  /// Update search query
  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update filter
  void onFilterChanged(InventoryFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Navigate to scan screen
  void navigateToScan(BuildContext context) {
    context.push(Routes.scan);
  }

  /// Navigate to item detail
  void navigateToItemDetail(BuildContext context, InventoryItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: ${item.name}'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Dummy data for development
  List<InventoryItem> _getDummyItems() {
    final now = DateTime.now();

    return [
      // Expiring items
      InventoryItem(
        id: '1',
        name: 'milk',
        displayName: 'Whole Milk',
        category: ItemCategory.dairy,
        quantity: 0.5,
        unit: 'Gal',
        expiryDate: DateTime(now.year, now.month, now.day + 1),
        addedAt: now.subtract(const Duration(days: 5)),
      ),
      InventoryItem(
        id: '2',
        name: 'bread',
        displayName: 'Sourdough',
        category: ItemCategory.grain,
        quantity: 4,
        unit: 'Slices',
        expiryDate: DateTime(now.year, now.month, now.day + 2),
        addedAt: now.subtract(const Duration(days: 3)),
      ),
      // Fresh items
      InventoryItem(
        id: '3',
        name: 'eggs',
        displayName: 'Organic Eggs',
        category: ItemCategory.protein,
        quantity: 12,
        unit: 'ct',
        expiryDate: DateTime(now.year, now.month, now.day + 10),
        addedAt: now.subtract(const Duration(days: 2)),
      ),
      InventoryItem(
        id: '4',
        name: 'chicken',
        displayName: 'Chicken Breast',
        category: ItemCategory.protein,
        quantity: 2,
        unit: 'lbs',
        expiryDate: DateTime(now.year, now.month, now.day + 5),
        addedAt: now.subtract(const Duration(days: 1)),
      ),
      InventoryItem(
        id: '5',
        name: 'spinach',
        displayName: 'Spinach',
        category: ItemCategory.vegetable,
        quantity: 1,
        unit: 'Bag',
        expiryDate: DateTime(now.year, now.month, now.day + 4),
        addedAt: now.subtract(const Duration(days: 2)),
      ),
      InventoryItem(
        id: '6',
        name: 'yogurt',
        displayName: 'Greek Yogurt',
        category: ItemCategory.dairy,
        quantity: 500,
        unit: 'g',
        expiryDate: DateTime(now.year, now.month, now.day + 7),
        addedAt: now.subtract(const Duration(days: 4)),
      ),
      InventoryItem(
        id: '7',
        name: 'juice',
        displayName: 'Orange Juice',
        category: ItemCategory.beverage,
        quantity: 1,
        unit: 'L',
        expiryDate: DateTime(now.year, now.month, now.day + 14),
        addedAt: now.subtract(const Duration(days: 7)),
      ),
      InventoryItem(
        id: '8',
        name: 'cheese',
        displayName: 'Cheddar Cheese',
        category: ItemCategory.dairy,
        quantity: 200,
        unit: 'g',
        expiryDate: DateTime(now.year, now.month, now.day + 21),
        addedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}

/// Provider for inventory controller
final inventoryControllerProvider =
    NotifierProvider<InventoryController, InventoryState>(
        InventoryController.new);
