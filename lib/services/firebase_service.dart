import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/ingredient.dart';
import '../models/inventory_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Fixed IDs - should match your DatabaseSeederV2
  static const String DEFAULT_HOUSEHOLD_ID = 'house_01';
  static const String DEFAULT_USER_ID = 'user_01';

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
        .asyncMap((snapshot) async {
      List<InventoryItem> items = [];
      
      for (var doc in snapshot.docs) {
        final inventoryItem = InventoryItem.fromFirestore(doc);
        
        // Populate ingredient data
        try {
          final ingredientDoc = await _firestore
              .collection('ingredients')
              .doc(inventoryItem.ingredientId)
              .get();
          
          if (ingredientDoc.exists) {
            final ingredient = Ingredient.fromFirestore(ingredientDoc);
            inventoryItem.ingredientName = ingredient.name;
            inventoryItem.ingredientBarcode = ingredient.barcode;
            inventoryItem.ingredientCategory = ingredient.category;
            inventoryItem.ingredientImageUrl = ingredient.imageUrl;
          }
        } catch (e) {
          debugPrint('Error populating ingredient data: $e');
        }
        
        items.add(inventoryItem);
      }
      
      return items;
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

      await inventoryRef.set(inventoryItem.toFirestore());
      debugPrint('✅ Inventory item added: ${inventoryRef.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding inventory item: $e');
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
      });
      
      debugPrint('✅ Inventory item updated: $inventoryId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating inventory item: $e');
      return false;
    }
  }

  /// Delete inventory items
  Future<bool> deleteInventoryItems({
    required List<String> inventoryIds,
    String? householdId,
  }) async {
    try {
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
      
      await batch.commit();
      debugPrint('✅ Deleted ${inventoryIds.length} inventory items');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting inventory items: $e');
      return false;
    }
  }
}
