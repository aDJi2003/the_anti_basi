import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/models/scanned_item.dart';
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
  @override
  ScanResultsState build() {
    _loadDummyData();
    return const ScanResultsState(isLoading: true);
  }

  /// Load dummy scan results (replace with actual AI results)
  Future<void> _loadDummyData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final dummyItems = [
      ScannedItem(
        id: const Uuid().v4(),
        name: 'Whole Milk',
        category: ItemCategory.dairy,
        quantity: 1,
        unit: 'L',
        expiryDate: now.add(const Duration(days: 7)),
        isSelected: true,
      ),
      ScannedItem(
        id: const Uuid().v4(),
        name: 'Free Range Eggs',
        category: ItemCategory.protein,
        quantity: 12,
        unit: 'pcs',
        expiryDate: now.add(const Duration(days: 14)),
        isSelected: true,
      ),
      ScannedItem(
        id: const Uuid().v4(),
        name: 'Spinach',
        category: ItemCategory.vegetable,
        quantity: 2,
        unit: 'bags',
        expiryDate: now.add(const Duration(days: 3)),
        isSelected: false,
      ),
      ScannedItem(
        id: const Uuid().v4(),
        name: 'Unknown Item',
        category: ItemCategory.other,
        quantity: 1,
        unit: 'pcs',
        isSelected: false,
        isUnknown: true,
      ),
    ];

    state = state.copyWith(
      isLoading: false,
      items: dummyItems,
    );
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
    // TODO: Show destination picker
    _showSnackBar(context, 'Destination picker coming soon');
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
      // TODO: Actually save to Firestore
      await Future.delayed(const Duration(milliseconds: 500));

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
    NotifierProvider<ScanResultsController, ScanResultsState>(
        ScanResultsController.new);
