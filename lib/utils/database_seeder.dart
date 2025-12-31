import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeederV2 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============================
  // FIXED IDS
  // =============================
  final String userId = 'user_01';
  final String householdId = 'house_01';

  final String beefId = 'ing_0001';
  final String eggId = 'ing_0002';
  final String onionId = 'ing_0003';

  final String recipeId = 'recipe_01';

  Future<void> seedDatabase() async {
    try {
      debugPrint('🚀 START SEEDING DATABASE V2');

      // =====================================================
      // 1️⃣ INGREDIENTS (MASTER DATA – BARCODE)
      // =====================================================
      await _firestore.collection('ingredients').doc(beefId).set({
        'ingredient_id': beefId,
        'name': 'Beef',
        'barcode': '8938505974194',
        'category': 'meat',
        'default_unit': 'g',
        'image_url': '',
        'nutrition': {
          'calories': 250,
          'protein': 26,
          'fat': 15,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(eggId).set({
        'ingredient_id': eggId,
        'name': 'Chicken egg',
        'barcode': '8938505974200',
        'category': 'dairy',
        'default_unit': 'pcs',
        'image_url': '',
        'nutrition': {
          'calories': 70,
          'protein': 6,
          'fat': 5,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(onionId).set({
        'ingredient_id': onionId,
        'name': 'Purple onion',
        'barcode': '8938505974217',
        'category': 'vegetable',
        'default_unit': 'pcs',
        'image_url': '',
        'nutrition': {
          'calories': 40,
          'protein': 1.2,
          'fat': 0.1,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Ingredients created');

      // =====================================================
      // 2️⃣ USERS
      // =====================================================
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': 'admin@beptroly.com',
        'display_name': 'Admin Bếp',
        'photo_url': 'https://i.pravatar.cc/300',
        'language': 'vi',
        'current_household_id': householdId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ User created');

      // =====================================================
      // 3️⃣ HOUSEHOLDS
      // =====================================================
      final houseRef =
          _firestore.collection('households').doc(householdId);

      await houseRef.set({
        'household_id': householdId,
        'name': 'Gia Đình Demo',
        'owner_id': userId,
        'invite_code': 'ABC-123',
        'members': [userId],
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Household created');

      // =====================================================
      // 4️⃣ INVENTORY (STOCK – LINK INGREDIENT)
      // =====================================================
      await houseRef.collection('inventory').doc('inv_01').set({
        'inventory_id': 'inv_01',
        'ingredient_id': beefId,
        'household_id': householdId,
        'quantity': 500,
        'unit': 'g',
        'expiry_date':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      await houseRef.collection('inventory').doc('inv_02').set({
        'inventory_id': 'inv_02',
        'ingredient_id': eggId,
        'household_id': householdId,
        'quantity': 10,
        'unit': 'quả',
        'expiry_date':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Inventory created');

      // =====================================================
      // 5️⃣ HOUSEHOLD RECIPES (LINK INGREDIENT)
      // =====================================================
      await houseRef.collection('household_recipes').doc(recipeId).set({
        'local_recipe_id': recipeId,
        'household_id': householdId,
        'title': 'Bò Kho Tiêu',
        'image_url': '',
        'ready_in_minutes': 45,
        'difficulty': 'Medium',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {
            'ingredient_id': beefId,
            'amount': 300,
            'unit': 'g',
          },
          {
            'ingredient_id': onionId,
            'amount': 2,
            'unit': 'củ',
          },
        ],
        'instructions':
            'Bước 1: Sơ chế thịt bò\nBước 2: Ướp gia vị\nBước 3: Kho nhỏ lửa',
      });

      debugPrint('✅ Recipe created');

      // =====================================================
      // 6️⃣ MEAL PLANS
      // =====================================================
      await houseRef.collection('meal_plans').doc('plan_01').set({
        'plan_id': 'plan_01',
        'household_id': householdId,
        'date': Timestamp.fromDate(DateTime.now()),
        'meal_type': 'Dinner',
        'local_recipe_id': recipeId,
        'servings': 4,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Meal plan created');

      // =====================================================
      // 7️⃣ SHOPPING LIST
      // =====================================================
      await houseRef.collection('shopping_list').doc('shop_01').set({
        'item_id': 'shop_01',
        'household_id': householdId,
        'ingredient_id': onionId,
        'quantity': 2,
        'unit': 'củ',
        'is_checked': false,
        'is_auto_generated': true,
        'for_recipe_id': recipeId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('🎉 SEED DATABASE V2 COMPLETED');

    } catch (e) {
      debugPrint('❌ SEED ERROR: $e');
    }
  }
}
