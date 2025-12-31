import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseSeederV2 {
  // ✅ Sử dụng instance mặc định (sẽ dùng database được cấu hình cho platform hiện tại)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============================
  // FIXED IDS
  // =============================
  final String userId = 'user_01';
  final String householdId = 'house_01';

  // Ingredients (10 items - each with at least 4+ ingredients per recipe)
  final String beefId = 'ing_0001';
  final String eggId = 'ing_0002';
  final String onionId = 'ing_0003';
  final String tomatoId = 'ing_0004';
  final String garlicId = 'ing_0005';
  final String fishSauceId = 'ing_0006';
  final String pepperBlackId = 'ing_0007';
  final String oilId = 'ing_0008';
  final String lemonId = 'ing_0009';
  final String carrotId = 'ing_0010';

  // Recipes (5 recipes, each with 4+ ingredients)
  final String recipe01 = 'recipe_01'; // Bò Kho Tiêu (4 ingredients)
  final String recipe02 = 'recipe_02'; // Trứng Cà Chua (4 ingredients)
  final String recipe03 = 'recipe_03'; // Canh Cà Chua Trứng (5 ingredients)
  final String recipe04 = 'recipe_04'; // Bò Kho Carrot (5 ingredients)
  final String recipe05 = 'recipe_05'; // Canh Dưa Trứng (4 ingredients)

  Future<void> seedDatabase() async {
    try {
      debugPrint('🚀 START SEEDING DATABASE V2');
      debugPrint('📌 Firebase Project: fridge-to-fork-d960d (Android)');
      debugPrint('⚠️  Make sure you are running on Android emulator/device!');
      debugPrint('');

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

      await _firestore.collection('ingredients').doc(tomatoId).set({
        'ingredient_id': tomatoId,
        'name': 'Tomato',
        'barcode': '8938505974224',
        'category': 'vegetable',
        'default_unit': 'pcs',
        'image_url': '',
        'nutrition': {
          'calories': 18,
          'protein': 0.9,
          'fat': 0.2,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(garlicId).set({
        'ingredient_id': garlicId,
        'name': 'Garlic',
        'barcode': '8938505974231',
        'category': 'vegetable',
        'default_unit': 'cloves',
        'image_url': '',
        'nutrition': {
          'calories': 150,
          'protein': 6,
          'fat': 0.5,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(fishSauceId).set({
        'ingredient_id': fishSauceId,
        'name': 'Fish sauce',
        'barcode': '8938505974248',
        'category': 'condiment',
        'default_unit': 'ml',
        'image_url': '',
        'nutrition': {
          'calories': 5,
          'protein': 1,
          'fat': 0,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(pepperBlackId).set({
        'ingredient_id': pepperBlackId,
        'name': 'Black pepper',
        'barcode': '8938505974255',
        'category': 'spice',
        'default_unit': 'g',
        'image_url': '',
        'nutrition': {
          'calories': 250,
          'protein': 10,
          'fat': 3,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(oilId).set({
        'ingredient_id': oilId,
        'name': 'Cooking oil',
        'barcode': '8938505974262',
        'category': 'oil',
        'default_unit': 'ml',
        'image_url': '',
        'nutrition': {
          'calories': 884,
          'protein': 0,
          'fat': 100,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(lemonId).set({
        'ingredient_id': lemonId,
        'name': 'Lemon',
        'barcode': '8938505974279',
        'category': 'fruit',
        'default_unit': 'pcs',
        'image_url': '',
        'nutrition': {
          'calories': 29,
          'protein': 1.1,
          'fat': 0.3,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(carrotId).set({
        'ingredient_id': carrotId,
        'name': 'Carrot',
        'barcode': '8938505974286',
        'category': 'vegetable',
        'default_unit': 'pcs',
        'image_url': '',
        'nutrition': {
          'calories': 41,
          'protein': 0.9,
          'fat': 0.2,
        },
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Ingredients created (10 items)');

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
      // ✅ Beef - Giảm để một số recipe thiếu
      await houseRef.collection('inventory').doc('inv_01').set({
        'inventory_id': 'inv_01',
        'ingredient_id': beefId,
        'household_id': householdId,
        'quantity': 200, // ⬇️ Giảm từ 800g xuống 200g (các recipe cần 300-400g)
        'unit': 'g',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Eggs - Giảm để thiếu
      await houseRef.collection('inventory').doc('inv_02').set({
        'inventory_id': 'inv_02',
        'ingredient_id': eggId,
        'household_id': householdId,
        'quantity': 5, // ⬇️ Giảm từ 20 xuống 5 (3 recipe cần 2-3 cái mỗi cái)
        'unit': 'pcs',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Onion
      await houseRef.collection('inventory').doc('inv_03').set({
        'inventory_id': 'inv_03',
        'ingredient_id': onionId,
        'household_id': householdId,
        'quantity': 2, // ⬇️ Giảm từ 8 xuống 2 (2 recipe cần 1-2 cái)
        'unit': 'pcs',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 20))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Tomato - Giảm để thiếu
      await houseRef.collection('inventory').doc('inv_04').set({
        'inventory_id': 'inv_04',
        'ingredient_id': tomatoId,
        'household_id': householdId,
        'quantity': 2, // ⬇️ Giảm từ 6 xuống 2 (recipe cần 2-3 cái)
        'unit': 'pcs',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Garlic - Giảm để thiếu
      await houseRef.collection('inventory').doc('inv_05').set({
        'inventory_id': 'inv_05',
        'ingredient_id': garlicId,
        'household_id': householdId,
        'quantity': 5, // ⬇️ Giảm từ 30 xuống 5 (2 recipe cần 3-5 cloves)
        'unit': 'cloves',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Fish sauce
      await houseRef.collection('inventory').doc('inv_06').set({
        'inventory_id': 'inv_06',
        'ingredient_id': fishSauceId,
        'household_id': householdId,
        'quantity': 30, // ⬇️ Giảm từ 500 xuống 30 (2 recipe cần 15-20ml)
        'unit': 'ml',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 60))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Black pepper
      await houseRef.collection('inventory').doc('inv_07').set({
        'inventory_id': 'inv_07',
        'ingredient_id': pepperBlackId,
        'household_id': householdId,
        'quantity': 20,
        'unit': 'g',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 180))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Oil
      await houseRef.collection('inventory').doc('inv_08').set({
        'inventory_id': 'inv_08',
        'ingredient_id': oilId,
        'household_id': householdId,
        'quantity': 750,
        'unit': 'ml',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 360))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Lemon - Giảm để thiếu
      await houseRef.collection('inventory').doc('inv_09').set({
        'inventory_id': 'inv_09',
        'ingredient_id': lemonId,
        'household_id': householdId,
        'quantity': 0, // ⬇️ Không có (recipe cần 1 cái)
        'unit': 'pcs',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Carrot - Không có
      await houseRef.collection('inventory').doc('inv_10').set({
        'inventory_id': 'inv_10',
        'ingredient_id': carrotId,
        'household_id': householdId,
        'quantity': 0, // ⬇️ Không có (recipe cần 3 cái)
        'unit': 'pcs',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 21))),
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Inventory created (10 items)');

      // =====================================================
      // 5️⃣ HOUSEHOLD RECIPES (LINK INGREDIENT) - 5 RECIPES, EACH WITH 4+ INGREDIENTS
      // =====================================================
      
      // ✅ Recipe 1: Bò Kho Tiêu (4 ingredients)
      await houseRef.collection('household_recipes').doc(recipe01).set({
        'local_recipe_id': recipe01,
        'household_id': householdId,
        'title': 'Bò Kho Tiêu',
        'author': 'Chef Demo',
        'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'calories': 350,
        'ready_in_minutes': 45,
        'difficulty': 'Medium',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {'ingredient_id': beefId, 'amount': 300, 'unit': 'g'},
          {'ingredient_id': onionId, 'amount': 2, 'unit': 'pcs'},
          {'ingredient_id': pepperBlackId, 'amount': 5, 'unit': 'g'},
          {'ingredient_id': oilId, 'amount': 30, 'unit': 'ml'},
        ],
        'instructions': 'Bước 1: Sơ chế thịt bò\nBước 2: Ướp gia vị\nBước 3: Kho nhỏ lửa 45 phút',
      });

      // ✅ Recipe 2: Trứng Cà Chua (4 ingredients)
      await houseRef.collection('household_recipes').doc(recipe02).set({
        'local_recipe_id': recipe02,
        'household_id': householdId,
        'title': 'Trứng Cà Chua',
        'author': 'Chef Demo',
        'image_url': 'https://images.unsplash.com/photo-1555939594-58d7cb561a1a',
        'calories': 220,
        'ready_in_minutes': 15,
        'difficulty': 'Easy',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {'ingredient_id': eggId, 'amount': 3, 'unit': 'pcs'},
          {'ingredient_id': tomatoId, 'amount': 2, 'unit': 'pcs'},
          {'ingredient_id': onionId, 'amount': 1, 'unit': 'pcs'},
          {'ingredient_id': oilId, 'amount': 20, 'unit': 'ml'},
        ],
        'instructions': 'Bước 1: Đánh trứng\nBước 2: Xào hành cà chua\nBước 3: Đổ trứng vào xào nhanh',
      });

      // ✅ Recipe 3: Canh Cà Chua Trứng (5 ingredients)
      await houseRef.collection('household_recipes').doc(recipe03).set({
        'local_recipe_id': recipe03,
        'household_id': householdId,
        'title': 'Canh Cà Chua Trứng',
        'author': 'Chef Demo',
        'image_url': 'https://images.unsplash.com/photo-1603046891726-36bfd957e2af',
        'calories': 180,
        'ready_in_minutes': 20,
        'difficulty': 'Easy',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {'ingredient_id': eggId, 'amount': 2, 'unit': 'pcs'},
          {'ingredient_id': tomatoId, 'amount': 3, 'unit': 'pcs'},
          {'ingredient_id': garlicId, 'amount': 3, 'unit': 'cloves'},
          {'ingredient_id': fishSauceId, 'amount': 15, 'unit': 'ml'},
          {'ingredient_id': oilId, 'amount': 10, 'unit': 'ml'},
        ],
        'instructions': 'Bước 1: Đun nước sôi\nBước 2: Cho cà chua vào nấu\nBước 3: Nêm gia vị\nBước 4: Đổ trứng từng sợi',
      });

      // ✅ Recipe 4: Bò Kho Cà Rốt (5 ingredients)
      await houseRef.collection('household_recipes').doc(recipe04).set({
        'local_recipe_id': recipe04,
        'household_id': householdId,
        'title': 'Bò Kho Cà Rốt',
        'author': 'Chef Demo',
        'image_url': 'https://images.unsplash.com/photo-1584437895049-2f72b7e59f09',
        'calories': 380,
        'ready_in_minutes': 60,
        'difficulty': 'Hard',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {'ingredient_id': beefId, 'amount': 400, 'unit': 'g'},
          {'ingredient_id': carrotId, 'amount': 3, 'unit': 'pcs'},
          {'ingredient_id': onionId, 'amount': 2, 'unit': 'pcs'},
          {'ingredient_id': garlicId, 'amount': 5, 'unit': 'cloves'},
          {'ingredient_id': fishSauceId, 'amount': 20, 'unit': 'ml'},
        ],
        'instructions': 'Bước 1: Sốt thịt bò\nBước 2: Thêm hành, tỏi\nBước 3: Nêm gia vị\nBước 4: Kho cà rốt 60 phút',
      });

      // ✅ Recipe 5: Canh Dưa Trứng (4 ingredients)
      await houseRef.collection('household_recipes').doc(recipe05).set({
        'local_recipe_id': recipe05,
        'household_id': householdId,
        'title': 'Canh Dưa Trứng',
        'author': 'Chef Demo',
        'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'calories': 150,
        'ready_in_minutes': 15,
        'difficulty': 'Easy',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {'ingredient_id': eggId, 'amount': 2, 'unit': 'pcs'},
          {'ingredient_id': lemonId, 'amount': 1, 'unit': 'pcs'},
          {'ingredient_id': garlicId, 'amount': 2, 'unit': 'cloves'},
          {'ingredient_id': fishSauceId, 'amount': 10, 'unit': 'ml'},
        ],
        'instructions': 'Bước 1: Đun nước sôi\nBước 2: Cho chanh vào\nBước 3: Nêm mắm tôm\nBước 4: Đổ trứng từng sợi',
      });

      debugPrint('✅ Recipes created (5 recipes)');

      // =====================================================
      // 6️⃣ MEAL PLANS - 5 MEAL PLANS (2 FOR 29/12, 3 FOR 31/12)
      // =====================================================
      
      // 📅 29/12/2025 - 2 meal plans
      final date29Dec = DateTime(2025, 12, 29);
      
      // Meal 1: 29/12 - Breakfast - Trứng Cà Chua
      await houseRef.collection('meal_plans').doc('plan_01').set({
        'plan_id': 'plan_01',
        'household_id': householdId,
        'date': Timestamp.fromDate(date29Dec),
        'meal_type': 'Breakfast',
        'local_recipe_id': recipe02,
        'servings': 2,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Meal 2: 29/12 - Dinner - Bò Kho Tiêu
      await houseRef.collection('meal_plans').doc('plan_02').set({
        'plan_id': 'plan_02',
        'household_id': householdId,
        'date': Timestamp.fromDate(date29Dec),
        'meal_type': 'Dinner',
        'local_recipe_id': recipe01,
        'servings': 4,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // 📅 31/12/2025 - 3 meal plans
      final date31Dec = DateTime(2025, 12, 31);
      
      // Meal 3: 31/12 - Breakfast - Canh Cà Chua Trứng
      await houseRef.collection('meal_plans').doc('plan_03').set({
        'plan_id': 'plan_03',
        'household_id': householdId,
        'date': Timestamp.fromDate(date31Dec),
        'meal_type': 'Breakfast',
        'local_recipe_id': recipe03,
        'servings': 3,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Meal 4: 31/12 - Lunch - Canh Dưa Trứng
      await houseRef.collection('meal_plans').doc('plan_04').set({
        'plan_id': 'plan_04',
        'household_id': householdId,
        'date': Timestamp.fromDate(date31Dec),
        'meal_type': 'Lunch',
        'local_recipe_id': recipe05,
        'servings': 2,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Meal 5: 31/12 - Dinner - Bò Kho Cà Rốt
      await houseRef.collection('meal_plans').doc('plan_05').set({
        'plan_id': 'plan_05',
        'household_id': householdId,
        'date': Timestamp.fromDate(date31Dec),
        'meal_type': 'Dinner',
        'local_recipe_id': recipe04,
        'servings': 4,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Meal plans created (5 meal plans: 2 for 29/12, 3 for 31/12)');

      // =====================================================
      // 7️⃣ SHOPPING LIST (auto-generated from meal plans)
      // =====================================================
      // Note: In real app, shopping list would be calculated from meal plans + inventory
      // For now, we'll add a few sample items
      
      await houseRef.collection('shopping_list').doc('shop_01').set({
        'item_id': 'shop_01',
        'household_id': householdId,
        'ingredient_id': beefId,
        'quantity': 700,
        'unit': 'g',
        'is_checked': false,
        'is_auto_generated': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      await houseRef.collection('shopping_list').doc('shop_02').set({
        'item_id': 'shop_02',
        'household_id': householdId,
        'ingredient_id': tomatoId,
        'quantity': 5,
        'unit': 'pcs',
        'is_checked': false,
        'is_auto_generated': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      await houseRef.collection('shopping_list').doc('shop_03').set({
        'item_id': 'shop_03',
        'household_id': householdId,
        'ingredient_id': carrotId,
        'quantity': 3,
        'unit': 'pcs',
        'is_checked': false,
        'is_auto_generated': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Shopping list created (3 items)');

      debugPrint('🎉 SEED DATABASE V2 COMPLETED - ALL DATA READY!');

    } catch (e) {
      debugPrint('❌ SEED ERROR: $e');
    }
  }
}
