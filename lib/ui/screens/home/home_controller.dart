import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/inventory_item.dart';
import '../../../data/providers/auth_state_provider.dart';
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
  // Cache user info to avoid losing it on rebuilds
  String _cachedUserName = 'User';
  String? _cachedUserAvatarUrl;
  bool _userLoaded = false;

  @override
  HomeState build() {
    // Watch auth state - this causes rebuild when user changes
    ref.watch(currentUserIdProvider);

    // Watch real-time inventory stream for automatic updates
    final inventoryAsync = ref.watch(inventoryStreamProvider);

    // Load user profile (one-time, doesn't need real-time updates)
    if (!_userLoaded) {
      _loadUserProfile();
    }

    // Process inventory data from stream
    final allItems = inventoryAsync.value ?? [];
    final expiringItems = allItems
        .where(
          (item) =>
              item.expiryStatus == ExpiryStatus.expired ||
              item.expiryStatus == ExpiryStatus.expiringToday ||
              item.expiryStatus == ExpiryStatus.expiringSoon,
        )
        .toList()
      ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

    return HomeState(
      isLoading: inventoryAsync.isLoading,
      userName: _cachedUserName,
      userAvatarUrl: _cachedUserAvatarUrl,
      totalItems: allItems.length,
      expiringItems: expiringItems,
      lastUpdated: DateTime.now(),
      errorMessage: inventoryAsync.hasError ? inventoryAsync.error.toString() : null,
    );
  }

  UserRepository get _userRepo => ref.read(userRepositoryProvider);

  /// Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    try {
      debugPrint('[HomeController] Fetching user profile...');
      final userProfile = await _userRepo.getCurrentUser();
      debugPrint('[HomeController] Got user: ${userProfile?.displayName}');

      _cachedUserName = userProfile?.firstName ?? 'User';
      _cachedUserAvatarUrl = userProfile?.photoURL;
      _userLoaded = true;

      // Trigger rebuild with updated user info
      state = state.copyWith(
        userName: _cachedUserName,
        userAvatarUrl: _cachedUserAvatarUrl,
      );
    } catch (e) {
      debugPrint('[HomeController] Error loading user profile: $e');
      _userLoaded = true; // Mark as loaded to prevent infinite retries
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    // Invalidate stream to force refresh from Firestore
    ref.invalidate(inventoryStreamProvider);
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
    context.push(
      Routes.itemDetail.replaceFirst(':id', item.id),
      extra: item,
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
