import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// Home screen state
class HomeState {
  const HomeState({
    this.isLoading = false,
    this.userName = 'User',
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
      .where(
        (i) =>
            i.expiryStatus == ExpiryStatus.expired ||
            i.expiryStatus == ExpiryStatus.expiringToday,
      )
      .length;

  /// Get time-based greeting
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

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
    _loadData();
    return const HomeState(isLoading: true);
  }

  InventoryRepository get _inventoryRepo => ref.read(inventoryRepositoryProvider);
  UserRepository get _userRepo => ref.read(userRepositoryProvider);

  /// Load home data from Firestore
  Future<void> _loadData() async {
    try {
      // Fetch user profile from Firestore
      debugPrint('[HomeController] Fetching user profile...');
      final userProfile = await _userRepo.getCurrentUser();
      debugPrint('[HomeController] Got user: ${userProfile?.displayName}');

      final userName = userProfile?.firstName ?? 'User';
      final userAvatar = userProfile?.photoURL;

      // Fetch inventory from Firestore
      debugPrint('[HomeController] Fetching inventory...');
      final allItems = await _inventoryRepo.getInventory();
      debugPrint('[HomeController] Got ${allItems.length} items');

      // Filter expiring items (within 3 days or already expired)
      final expiringItems =
          allItems
              .where(
                (item) =>
                    item.expiryStatus == ExpiryStatus.expired ||
                    item.expiryStatus == ExpiryStatus.expiringToday ||
                    item.expiryStatus == ExpiryStatus.expiringSoon,
              )
              .toList()
            ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

      debugPrint('[HomeController] Expiring items: ${expiringItems.length}');

      state = state.copyWith(
        isLoading: false,
        userName: userName,
        userAvatarUrl: userAvatar,
        totalItems: allItems.length,
        expiringItems: expiringItems,
        lastUpdated: DateTime.now(),
      );
    } catch (e, stack) {
      debugPrint('[HomeController] ERROR: $e');
      debugPrint('[HomeController] Stack: $stack');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Navigate to recipe suggestions
  void navigateToRecipes(BuildContext context) {
    context.go(Routes.recipes);
  }
}

/// Provider for home controller
final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
