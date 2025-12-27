import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/models/scanned_item.dart';
import '../../../data/repositories/inventory_repository.dart';
import 'widgets/manual_input_sheet.dart';

/// Scan results screen state
class ScanResultsState {
  const ScanResultsState({
    this.isLoading = false,
    this.isSaving = false,
    this.items = const [],
    this.sourceImages = const [],
    this.destination = 'Main Fridge',
  });

  final bool isLoading;
  final bool isSaving;
  final List<ScannedItem> items;
  final List<String> sourceImages;
  final String destination;

  /// Count of selected items
  int get selectedCount => items.where((i) => i.isSelected).length;

  ScanResultsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ScannedItem>? items,
    List<String>? sourceImages,
    String? destination,
  }) {
    return ScanResultsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      items: items ?? this.items,
      sourceImages: sourceImages ?? this.sourceImages,
      destination: destination ?? this.destination,
    );
  }
}

/// Scan results controller
class ScanResultsController extends Notifier<ScanResultsState> {
  bool _isInitialized = false;

  @override
  ScanResultsState build() {
    return const ScanResultsState(isLoading: true);
  }

  InventoryRepository get _repository => ref.read(inventoryRepositoryProvider);

  /// Initialize with items from Gemini scan
  void initializeWithItems(List<ScannedItem> items, {String? imagePath}) {
    // Prevent double initialization
    if (_isInitialized) return;
    _isInitialized = true;

    debugPrint('[ScanResultsController] Initializing with ${items.length} items');

    // Set default expiry dates based on category if not set
    final processedItems = items.map((item) {
      if (item.expiryDate == null) {
        return item.copyWith(
          expiryDate: DateTime.now().add(Duration(days: _getDefaultExpiryDays(item.category))),
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      items: processedItems,
      sourceImages: imagePath != null ? [imagePath] : [],
    );
  }

  /// Initialize for manual entry mode (no scanned items)
  void initializeForManualEntry() {
    if (_isInitialized) return;
    _isInitialized = true;

    debugPrint('[ScanResultsController] Initializing for manual entry');

    state = state.copyWith(
      isLoading: false,
      items: [],
    );
  }

  /// Get default expiry days based on category
  int _getDefaultExpiryDays(ItemCategory category) {
    switch (category) {
      case ItemCategory.dairy:
        return 7;
      case ItemCategory.protein:
        return 5;
      case ItemCategory.vegetable:
        return 5;
      case ItemCategory.fruit:
        return 7;
      case ItemCategory.grain:
        return 30;
      case ItemCategory.condiment:
        return 90;
      case ItemCategory.beverage:
        return 14;
      case ItemCategory.other:
        return 14;
    }
  }

  /// Toggle item selection
  void toggleItem(String itemId) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  /// Update item quantity
  void updateQuantity(String itemId, double quantity) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  /// Update item unit
  void updateUnit(String itemId, String unit) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(unit: unit);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  /// Update item expiry date
  Future<void> updateExpiryDate(BuildContext context, String itemId) async {
    final item = state.items.firstWhere((i) => i.id == itemId);
    final initialDate = item.expiryDate ?? DateTime.now().add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF10B981),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final items = state.items.map((i) {
        if (i.id == itemId) {
          return i.copyWith(expiryDate: picked);
        }
        return i;
      }).toList();

      state = state.copyWith(items: items);
    }
  }

  /// Delete item
  void deleteItem(String itemId) {
    final items = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: items);
  }

  /// Add manual item
  Future<void> addManualItem(BuildContext context) async {
    final result = await showModalBottomSheet<ScannedItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ManualInputSheet(),
      ),
    );

    if (result != null) {
      state = state.copyWith(items: [...state.items, result]);
    }
  }

  /// Change destination
  void changeDestination(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Destination picker coming soon')),
    );
  }

  /// Add selected items to inventory
  Future<void> addToInventory(BuildContext context) async {
    final selectedItems = state.items.where((i) => i.isSelected).toList();

    if (selectedItems.isEmpty) {
      _showSnackBar(context, 'Please select at least one item');
      return;
    }

    state = state.copyWith(isSaving: true);

    try {
      // Convert ScannedItems to InventoryItems
      final inventoryItems = selectedItems
          .map((item) => item.toInventoryItem())
          .toList();

      // Save to Firestore
      await _repository.addItems(inventoryItems);

      if (context.mounted) {
        _showSnackBar(context, '${selectedItems.length} items added to inventory');

        // Navigate back to inventory
        context.go(Routes.inventory);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to save: $e');
      }
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  /// Go back
  void goBack(BuildContext context) {
    context.pop();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Provider for scan results controller
final scanResultsControllerProvider =
    NotifierProvider.autoDispose<ScanResultsController, ScanResultsState>(
        ScanResultsController.new);