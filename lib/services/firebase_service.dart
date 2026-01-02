import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient.dart';
import '../models/inventory_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Fallback IDs for testing only - should not be used in production
  static const String DEFAULT_HOUSEHOLD_ID = 'house_01';
  static const String DEFAULT_USER_ID = 'user_01';

  /// Get current logged-in user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get household ID for current user
  /// Fetches from user document's current_household_id field
  Future<String> get currentHouseholdId async {
    final userId = currentUserId;
    if (userId == null) {
      debugPrint('⚠️ No user logged in, using default household');
      return DEFAULT_HOUSEHOLD_ID;
    }
    
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final householdId = userDoc.data()?['current_household_id'];
      
      if (householdId != null) {
        return householdId;
      }
      
      // Fallback to user's default household
      return 'house_$userId';
    } catch (e) {
      debugPrint('⚠️ Error getting household ID: $e');
      return 'house_$userId';
    }
  }

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
    return Stream.fromFuture(currentHouseholdId).asyncExpand((houseId) {
      final resolvedHouseId = householdId ?? houseId;
      debugPrint('📦 [INVENTORY STREAM] Loading inventory for household: $resolvedHouseId');
      
      return _firestore
          .collection('households')
          .doc(resolvedHouseId)
          .collection('inventory')
          .snapshots()
          .timeout(
            const Duration(seconds: 15),
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
          
          // Check if this is a manual entry (empty ingredientId) or barcode scanned item
          if (inventoryItem.ingredientId.isEmpty) {
            // Manual entry - use direct name and category from inventory
            inventoryItem.ingredientName = inventoryItem.name;
            inventoryItem.ingredientCategory = inventoryItem.category;
            debugPrint('✅ Loaded manual entry: ${inventoryItem.name} (${inventoryItem.category})');
          } else {
            // Barcode scanned item - populate from ingredients table
            try {
              final ingredientDoc = await _firestore
                  .collection('ingredients')
                  .doc(inventoryItem.ingredientId)
                  .get()
                  .timeout(
                    const Duration(seconds: 3),
                    onTimeout: () {
                      throw TimeoutException('Ingredient fetch timeout');
                    },
                  );
              
              if (ingredientDoc.exists) {
                final ingredient = Ingredient.fromFirestore(ingredientDoc);
                inventoryItem.ingredientName = ingredient.name;
                inventoryItem.ingredientBarcode = ingredient.barcode;
                inventoryItem.ingredientCategory = ingredient.category;
                inventoryItem.ingredientImageUrl = ingredient.imageUrl;
                
                debugPrint('✅ Loaded barcode item: ${ingredient.name} (${ingredient.category})');
              } else {
                // Ingredient not found - treat as corrupted data, use fallback
                debugPrint('⚠️ Ingredient not found: ${inventoryItem.ingredientId}');
                inventoryItem.ingredientName = inventoryItem.name ?? 'Unknown Item';
                inventoryItem.ingredientCategory = inventoryItem.category ?? 'Other';
              }
            } catch (e) {
              debugPrint('❌ Error fetching ingredient ${inventoryItem.ingredientId}: $e');
              // Use fallback from inventory data if available
              inventoryItem.ingredientName = inventoryItem.name ?? 'Unknown Item';
              inventoryItem.ingredientCategory = inventoryItem.category ?? 'Other';
            }
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
        throw error;
      });
    });
  }

  /// Add inventory item from barcode scan (with ingredient reference)
  Future<bool> addInventoryWithIngredient({
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
      final houseId = householdId ?? await currentHouseholdId;
      final uid = userId ?? currentUserId ?? DEFAULT_USER_ID;
      
      debugPrint('➕ Adding scanned item to household: $houseId');
      
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
      debugPrint('✅ Scanned item added: ${inventoryRef.id}');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Error adding inventory item: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error adding inventory item: $e');
      return false;
    }
  }

  /// Add inventory item manually (without ingredient reference)
  Future<bool> addInventoryManual({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
    String? householdId,
    String? userId,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      debugPrint('❌ Invalid name: cannot be empty');
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
      final houseId = householdId ?? await currentHouseholdId;
      final uid = userId ?? currentUserId ?? DEFAULT_USER_ID;
      
      debugPrint('➕ Adding manual item "$name" to household: $houseId');
      
      final inventoryRef = _firestore
          .collection('households')
          .doc(houseId)
          .collection('inventory')
          .doc();

      final inventoryItem = InventoryItem(
        inventoryId: inventoryRef.id,
        ingredientId: '', // Empty for manual entry
        householdId: houseId,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        addedByUid: uid,
        name: name,
        category: category,
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
    String? name, // For manual entries only
    String? category, // For manual entries only
  }) async {
    try {
      final houseId = householdId ?? await currentHouseholdId;
      debugPrint('✏️ Updating item in household: $houseId');
      
      // Build update map
      final updateData = <String, dynamic>{
        'quantity': quantity,
        'unit': unit,
        'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
      };
      
      // Add name/category only if provided (for manual entries)
      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      
      await _firestore
          .collection('households')
          .doc(houseId)
          .collection('inventory')
          .doc(inventoryId)
          .update(updateData)
          .timeout(
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
      
      final houseId = householdId ?? await currentHouseholdId;
      debugPrint('🗑️ Deleting items from household: $houseId');
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
