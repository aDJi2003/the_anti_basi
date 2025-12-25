import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_item.dart';

/// Repository for inventory Firestore operations
class InventoryRepository {
  InventoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Get inventory collection reference for current user
  CollectionReference<Map<String, dynamic>> get _inventoryCollection {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('inventory');
  }

  // ============ READ OPERATIONS ============

  /// Stream all inventory items (real-time updates)
  Stream<List<InventoryItem>> watchInventory() {
    try {
      debugPrint('[InventoryRepo] watchInventory - userId: $_userId');
      return _inventoryCollection
          .orderBy('expiryDate', descending: false)
          .snapshots()
          .map((snapshot) {
            debugPrint('[InventoryRepo] Got ${snapshot.docs.length} docs');
            return snapshot.docs
                .map((doc) => InventoryItem.fromFirestore(doc))
                .where((item) => !item.isConsumed)
                .toList();
          });
    } catch (e) {
      debugPrint('[InventoryRepo] watchInventory error: $e');
      return Stream.value([]);
    }
  }

  /// Stream expiring items (within 3 days)
  Stream<List<InventoryItem>> watchExpiringItems() {
    try {
      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));

      return _inventoryCollection
          .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(threeDaysLater))
          .orderBy('expiryDate', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => InventoryItem.fromFirestore(doc))
              .where((item) => !item.isConsumed)
              .toList());
    } catch (e) {
      debugPrint('[InventoryRepo] watchExpiringItems error: $e');
      return Stream.value([]);
    }
  }

  /// Get all inventory items (one-time fetch)
  Future<List<InventoryItem>> getInventory() async {
    final userId = _userId;
    debugPrint('[InventoryRepo] getInventory - userId: $userId');

    if (userId == null) {
      debugPrint('[InventoryRepo] ERROR: User not authenticated');
      return [];
    }

    try {
      final collectionPath = 'users/$userId/inventory';
      debugPrint('[InventoryRepo] Fetching from: $collectionPath');

      final snapshot = await _inventoryCollection.get();

      debugPrint('[InventoryRepo] Got ${snapshot.docs.length} documents');

      for (final doc in snapshot.docs) {
        debugPrint('[InventoryRepo] Doc ${doc.id}: ${doc.data()}');
      }

      return snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .where((item) => !item.isConsumed)
          .toList();
    } catch (e, stack) {
      debugPrint('[InventoryRepo] ERROR fetching inventory: $e');
      debugPrint('[InventoryRepo] Stack: $stack');
      return [];
    }
  }

  /// Get single inventory item by ID
  Future<InventoryItem?> getItem(String itemId) async {
    try {
      final doc = await _inventoryCollection.doc(itemId).get();
      if (!doc.exists) return null;
      return InventoryItem.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  /// Get total item count
  Future<int> getItemCount() async {
    try {
      final snapshot = await _inventoryCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ============ WRITE OPERATIONS ============

  /// Add single inventory item
  Future<void> addItem(InventoryItem item) async {
    try {
      await _inventoryCollection.doc(item.id).set(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  /// Add multiple inventory items (batch)
  Future<void> addItems(List<InventoryItem> items) async {
    if (items.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final docRef = _inventoryCollection.doc(item.id);
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add items: $e');
    }
  }

  /// Update inventory item
  Future<void> updateItem(InventoryItem item) async {
    try {
      await _inventoryCollection.doc(item.id).update(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, double newQuantity) async {
    try {
      await _inventoryCollection.doc(itemId).update({
        'quantity': newQuantity,
      });
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  /// Delete inventory item
  Future<void> deleteItem(String itemId) async {
    try {
      await _inventoryCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Delete multiple items (batch)
  Future<void> deleteItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final itemId in itemIds) {
        final docRef = _inventoryCollection.doc(itemId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete items: $e');
    }
  }

  /// Clear all inventory items
  Future<void> clearInventory() async {
    try {
      final snapshot = await _inventoryCollection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear inventory: $e');
    }
  }
}

// ============ PROVIDERS ============

/// Provider for inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

/// Provider for inventory stream (real-time updates)
final inventoryStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchInventory();
});

/// Provider for expiring items stream
final expiringItemsStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchExpiringItems();
});
