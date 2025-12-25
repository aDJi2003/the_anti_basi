import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';

/// Home screen state
class HomeState {
  const HomeState({
    this.isLoading = false,
    this.userName = 'Budi',
    this.userAvatarUrl,
    this.totalItems = 0,
    this.expiringItems = const [],
    this.lastUpdated,
    this.errorMessage,
  });

  final bool isLoading;
  final String userName;
  final String? userAvatarUrl;
  final int totalItems;
  final List<InventoryItem> expiringItems;
  final DateTime? lastUpdated;
  final String? errorMessage;

  int get attentionCount => expiringItems
      .where((i) =>
          i.expiryStatus == ExpiryStatus.expired ||
          i.expiryStatus == ExpiryStatus.expiringToday)
      .length;

  HomeState copyWith({
    bool? isLoading,
    String? userName,
    String? userAvatarUrl,
    int? totalItems,
    List<InventoryItem>? expiringItems,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      totalItems: totalItems ?? this.totalItems,
      expiringItems: expiringItems ?? this.expiringItems,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}

/// Home controller - handles home screen logic
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    // Load data on initialization
    _loadData();
    return const HomeState(isLoading: true);
  }

  /// Load home data (TODO: Replace with actual API call)
  Future<void> _loadData() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Replace with actual data fetching
      final dummyItems = _getDummyItems();

      state = state.copyWith(
        isLoading: false,
        totalItems: 32,
        expiringItems: dummyItems,
        lastUpdated: DateTime.now(),
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

  /// Handle AI assistant query
  void onAiQuery(String query, BuildContext context) {
    // TODO: Implement AI query
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI Query: $query'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Navigate to inventory
  void navigateToInventory(BuildContext context) {
    context.go(Routes.inventory);
  }

  /// Navigate to add item (scan)
  void navigateToScan(BuildContext context) {
    context.push(Routes.scan);
  }

  /// Navigate to item detail
  void navigateToItemDetail(BuildContext context, InventoryItem item) {
    // TODO: Implement navigation to item detail
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

  /// Navigate to recipe suggestions
  void navigateToRecipes(BuildContext context) {
    context.go(Routes.recipes);
  }

  /// Dummy data for development
  List<InventoryItem> _getDummyItems() {
    final now = DateTime.now();

    return [
      InventoryItem(
        id: '1',
        name: 'milk',
        displayName: 'Fresh Milk',
        category: ItemCategory.dairy,
        quantity: 1.5,
        unit: 'L',
        expiryDate: DateTime(now.year, now.month, now.day),
        addedAt: now.subtract(const Duration(days: 3)),
      ),
      InventoryItem(
        id: '2',
        name: 'eggs',
        displayName: 'Organic Eggs',
        category: ItemCategory.protein,
        quantity: 6,
        unit: 'pcs',
        expiryDate: DateTime(now.year, now.month, now.day),
        addedAt: now.subtract(const Duration(days: 5)),
      ),
      InventoryItem(
        id: '3',
        name: 'spinach',
        displayName: 'Spinach',
        category: ItemCategory.vegetable,
        quantity: 200,
        unit: 'g',
        expiryDate: DateTime(now.year, now.month, now.day + 1),
        addedAt: now.subtract(const Duration(days: 1)),
      ),
      InventoryItem(
        id: '4',
        name: 'salmon',
        displayName: 'Salmon Fillet',
        category: ItemCategory.protein,
        quantity: 300,
        unit: 'g',
        expiryDate: DateTime(now.year, now.month, now.day + 1),
        addedAt: now.subtract(const Duration(days: 2)),
      ),
      InventoryItem(
        id: '5',
        name: 'yogurt',
        displayName: 'Greek Yogurt',
        category: ItemCategory.dairy,
        quantity: 500,
        unit: 'g',
        expiryDate: DateTime(now.year, now.month, now.day + 2),
        addedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}

/// Provider for home controller
final homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);
