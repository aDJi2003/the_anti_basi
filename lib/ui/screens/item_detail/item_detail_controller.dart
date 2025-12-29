import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/repositories/inventory_repository.dart';

/// State for item detail screen
class ItemDetailState {
  const ItemDetailState({
    this.item,
    this.isLoading = false,
    this.isDeleting = false,
    this.isUpdating = false,
    this.error,
  });

  final InventoryItem? item;
  final bool isLoading;
  final bool isDeleting;
  final bool isUpdating;
  final String? error;

  ItemDetailState copyWith({
    InventoryItem? item,
    bool? isLoading,
    bool? isDeleting,
    bool? isUpdating,
    String? error,
  }) {
    return ItemDetailState(
      item: item ?? this.item,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
    );
  }
}

/// Controller for item detail screen
class ItemDetailController extends Notifier<ItemDetailState> {
  @override
  ItemDetailState build() {
    return const ItemDetailState(isLoading: true);
  }

  InventoryRepository get _repository => ref.read(inventoryRepositoryProvider);

  /// Load item by ID
  Future<void> loadItem(String itemId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final item = await _repository.getItem(itemId);
      if (item != null) {
        state = state.copyWith(item: item, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Item not found',
        );
      }
    } catch (e) {
      debugPrint('[ItemDetailController] Error loading item: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load item',
      );
    }
  }

  /// Set item directly (when passed via navigation)
  void setItem(InventoryItem item) {
    state = state.copyWith(item: item, isLoading: false);
  }

  /// Update item quantity
  Future<bool> updateQuantity(double newQuantity) async {
    final item = state.item;
    if (item == null) return false;

    state = state.copyWith(isUpdating: true);

    try {
      final updatedItem = item.copyWith(quantity: newQuantity);
      await _repository.updateItem(updatedItem);
      state = state.copyWith(item: updatedItem, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('[ItemDetailController] Error updating quantity: $e');
      state = state.copyWith(isUpdating: false, error: 'Failed to update');
      return false;
    }
  }

  /// Delete item
  Future<bool> deleteItem() async {
    final item = state.item;
    if (item == null) return false;

    state = state.copyWith(isDeleting: true);

    try {
      await _repository.deleteItem(item.id);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e) {
      debugPrint('[ItemDetailController] Error deleting item: $e');
      state = state.copyWith(isDeleting: false, error: 'Failed to delete');
      return false;
    }
  }

  /// Mark item as consumed (set quantity to 0)
  Future<bool> markAsConsumed() async {
    return updateQuantity(0);
  }

  /// Update item category
  Future<bool> updateCategory(ItemCategory newCategory) async {
    final item = state.item;
    if (item == null) return false;

    state = state.copyWith(isUpdating: true);

    try {
      final updatedItem = item.copyWith(category: newCategory);
      await _repository.updateItem(updatedItem);
      state = state.copyWith(item: updatedItem, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('[ItemDetailController] Error updating category: $e');
      state = state.copyWith(isUpdating: false, error: 'Failed to update');
      return false;
    }
  }

  /// Update item expiry date
  Future<bool> updateExpiryDate(DateTime newDate) async {
    final item = state.item;
    if (item == null) return false;

    state = state.copyWith(isUpdating: true);

    try {
      final updatedItem = item.copyWith(expiryDate: newDate);
      await _repository.updateItem(updatedItem);
      state = state.copyWith(item: updatedItem, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('[ItemDetailController] Error updating expiry date: $e');
      state = state.copyWith(isUpdating: false, error: 'Failed to update');
      return false;
    }
  }
}

/// Provider for item detail controller
final itemDetailControllerProvider =
    NotifierProvider<ItemDetailController, ItemDetailState>(
  ItemDetailController.new,
);
