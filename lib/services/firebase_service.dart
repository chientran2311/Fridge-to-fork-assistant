import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/ingredient.dart';
import '../models/inventory_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Fixed IDs - should match your DatabaseSeederV2
  static const String DEFAULT_HOUSEHOLD_ID = 'house_01';
  static const String DEFAULT_USER_ID = 'user_01';

  FirebaseService() {
    // Enable offline persistence for better UX
    _enableOfflinePersistence();
  }

  void _enableOfflinePersistence() async {
    try {
      await _firestore.settings.persistenceEnabled;
      debugPrint('✅ Firestore offline persistence enabled');
    } catch (e) {
      debugPrint('⚠️ Could not enable offline persistence: $e');
    }
  }

  // =============================
  // INGREDIENT METHODS
  // =============================
  
  /// Get ingredient by barcode
  Future<Ingredient?> getIngredientByBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection('ingredients')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No ingredient found for barcode: $barcode');
        return null;
      }

      return Ingredient.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting ingredient by barcode: $e');
      return null;
    }
  }

  /// Get all ingredients
  Future<List<Ingredient>> getAllIngredients() async {
    try {
      final querySnapshot = await _firestore.collection('ingredients').get();
      return querySnapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting all ingredients: $e');
      return [];
    }
  }

  // =============================
  // INVENTORY METHODS
  // =============================
  
  /// Get all inventory items for a household with ingredient data populated
  Stream<List<InventoryItem>> getInventoryStream({String? householdId}) {
    final houseId = householdId ?? DEFAULT_HOUSEHOLD_ID;
    
    return _firestore
        .collection('households')
        .doc(houseId)
        .collection('inventory')
        .snapshots()
        .timeout(
          const Duration(seconds: 30),
          onTimeout: (sink) {
            debugPrint('⚠️ Firestore stream timeout - check internet connection');
            sink.addError('Connection timeout. Please check your internet connection.');
          },
        )
        .asyncMap((snapshot) async {
      List<InventoryItem> items = [];
      
      for (var doc in snapshot.docs) {
        try {
          final inventoryItem = InventoryItem.fromFirestore(doc);
          
          // Populate ingredient data with timeout
          try {
            final ingredientDoc = await _firestore
                .collection('ingredients')
                .doc(inventoryItem.ingredientId)
                .get()
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    debugPrint('⚠️ Timeout fetching ingredient: ${inventoryItem.ingredientId}');
                    throw Exception('Timeout fetching ingredient data');
                  },
                );
            
            if (ingredientDoc.exists) {
              final ingredient = Ingredient.fromFirestore(ingredientDoc);
              inventoryItem.ingredientName = ingredient.name;
              inventoryItem.ingredientBarcode = ingredient.barcode;
              inventoryItem.ingredientCategory = ingredient.category;
              inventoryItem.ingredientImageUrl = ingredient.imageUrl;
            } else {
              debugPrint('⚠️ Ingredient not found: ${inventoryItem.ingredientId}');
              inventoryItem.ingredientName = 'Unknown Item';
            }
          } catch (e) {
            debugPrint('❌ Error populating ingredient data for ${inventoryItem.ingredientId}: $e');
            // Set default values instead of failing completely
            inventoryItem.ingredientName = 'Unknown Item';
            inventoryItem.ingredientCategory = 'Other';
          }
          
          items.add(inventoryItem);
        } catch (e) {
          debugPrint('❌ Error processing inventory item ${doc.id}: $e');
          // Continue processing other items even if one fails
        }
      }
      
      return items;
    }).handleError((error) {
      debugPrint('❌ Stream error in getInventoryStream: $error');
      // Re-throw to let UI handle it
      throw error;
    });
  }

  /// Add new inventory item
  Future<bool> addInventoryItem({
    required String ingredientId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
    String? householdId,
    String? userId,
  }) async {
    // Validation
    if (ingredientId.isEmpty) {
      debugPrint('❌ Invalid ingredientId: cannot be empty');
      return false;
    }
    if (quantity <= 0) {
      debugPrint('❌ Invalid quantity: must be greater than 0');
      return false;
    }
    if (unit.isEmpty) {
      debugPrint('❌ Invalid unit: cannot be empty');
      return false;
    }
    
    try {
      final houseId = householdId ?? DEFAULT_HOUSEHOLD_ID;
      final uid = userId ?? DEFAULT_USER_ID;
      
      final inventoryRef = _firestore
          .collection('households')
          .doc(houseId)
          .collection('inventory')
          .doc();

      final inventoryItem = InventoryItem(
        inventoryId: inventoryRef.id,
        ingredientId: ingredientId,
        householdId: houseId,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        addedByUid: uid,
      );

      await inventoryRef
          .set(inventoryItem.toFirestore())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout. Please check your internet.'),
          );
      debugPrint('✅ Inventory item added: ${inventoryRef.id}');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Error adding inventory item: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error adding inventory item: $e');
      return false;
    }
  }

  /// Update inventory item
  Future<bool> updateInventoryItem({
    required String inventoryId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
    String? householdId,
  }) async {
    try {
      final houseId = householdId ?? DEFAULT_HOUSEHOLD_ID;
      
      await _firestore
          .collection('households')
          .doc(houseId)
          .collection('inventory')
          .doc(inventoryId)
          .update({
        'quantity': quantity,
        'unit': unit,
        'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Please check your internet.'),
      );
      
      debugPrint('✅ Inventory item updated: $inventoryId');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Error updating inventory item: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error updating inventory item: $e');
      return false;
    }
  }

  /// Delete inventory items
  Future<bool> deleteInventoryItems({
    required List<String> inventoryIds,
    String? householdId,
  }) async {
    try {
      if (inventoryIds.isEmpty) {
        debugPrint('⚠️ No items to delete');
        return true;
      }
      
      final houseId = householdId ?? DEFAULT_HOUSEHOLD_ID;
      final batch = _firestore.batch();
      
      for (final id in inventoryIds) {
        final docRef = _firestore
            .collection('households')
            .doc(houseId)
            .collection('inventory')
            .doc(id);
        batch.delete(docRef);
      }
      
      await batch.commit().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout. Please check your internet.'),
      );
      debugPrint('✅ Deleted ${inventoryIds.length} inventory items');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Error deleting inventory items: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error deleting inventory items: $e');
      return false;
    }
  }
}
