import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/providers/auth_state_provider.dart';
import '../../../data/repositories/inventory_repository.dart';
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
    // Watch auth state - this causes rebuild when user changes
    ref.watch(currentUserIdProvider);
    _loadData();
    return const InventoryState(isLoading: true);
  }

  InventoryRepository get _repository => ref.read(inventoryRepositoryProvider);

  /// Load inventory data from Firestore
  Future<void> _loadData() async {
    try {
      final items = await _repository.getInventory();

      state = state.copyWith(
        isLoading: false,
        allItems: items,
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
    state = state.copyWith(isLoading: true, errorMessage: null);
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
        content: Text('Viewing: ${item.displayName}'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Delete an item from inventory
  Future<void> deleteItem(String itemId) async {
    try {
      await _repository.deleteItem(itemId);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Update item quantity
  Future<void> updateItemQuantity(String itemId, double newQuantity) async {
    try {
      await _repository.updateQuantity(itemId, newQuantity);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

/// Provider for inventory controller
final inventoryControllerProvider =
    NotifierProvider<InventoryController, InventoryState>(
        InventoryController.new);
