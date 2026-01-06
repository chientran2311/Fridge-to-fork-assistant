// =============================================================================
// DATABASE SEEDER - FIRESTORE TEST DATA GENERATOR
// =============================================================================
// File: lib/utils/database_seeder.dart
// Feature: Test Data for Expiry Alert Testing
// Description: Utility để seed dữ liệu mẫu vào Firestore cho testing
//              expiry notifications và recipe suggestions.
//
// Test Scenarios Created:
//   - Item expires TOMORROW -> Trigger urgent expiry alert
//   - Item expires in 2 DAYS -> Trigger warning notification  
//   - Favorite recipes -> Test AI recommendations
//   - Cooking history -> Test taste analysis
//
// Data Structure:
//   - users/{uid}: User với FCM token cho notifications
//   - households/{id}/inventory: Items với expiry_date
//   - households/{id}/favorite_recipes: For AI analysis
//   - households/{id}/cooking_history: For recommendations
//
// Usage: await DatabaseSeeder().seedDatabase();
// Author: Fridge to Fork Team
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// =============================================================================
// DATABASE SEEDER CLASS
// =============================================================================
class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Master Data IDs (shared across households)
  final String _beefId = 'ing_beef_01';
  final String _eggId = 'ing_egg_01';
  final String _milkId = 'ing_milk_01';
  final String _recipeId = 'recipe_seed_01';

  // ===========================================================================
  // MAIN SEED METHOD
  // ===========================================================================
  Future<void> seedDatabase() async {
    try {
      debugPrint("🚀 Bắt đầu tạo dữ liệu mẫu...");

      // Verify user logged in
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        debugPrint("❌ LỖI: Bạn chưa đăng nhập! Vui lòng login trước khi Seed.");
        return;
      }

      // Use real user info
      final String userId = currentUser.uid; 
      final String userEmail = currentUser.email ?? "user@test.com";
      final String displayName = currentUser.displayName ?? "Admin Bếp";
      
      // Create household ID based on user
      final String householdId = 'house_$userId';

      // ==========================================
      // MASTER DATA: INGREDIENTS
      // ==========================================
      await _firestore.collection('ingredients').doc(_beefId).set({
        'ingredient_id': _beefId,
        'name': 'Thịt bò',
        'barcode': '8938505974194',
        'category': 'meat',
        'default_unit': 'g',
        'image_url': 'https://spoonacular.com/cdn/ingredients_100x100/beef-cubes-raw.png',
        'created_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('ingredients').doc(_milkId).set({
        'ingredient_id': _milkId,
        'name': 'Sữa tươi TH True Milk',
        'barcode': '8938505974200',
        'category': 'dairy',
        'default_unit': 'ml',
        'image_url': 'https://spoonacular.com/cdn/ingredients_100x100/milk.png',
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ 1. Đã tạo Master Ingredients");

      // ==========================================
      // BƯỚC 1: CẬP NHẬT USER (Collection: users)
      // ==========================================
      // Dùng SetOptions(merge: true) để KHÔNG ghi đè mất FCM Token đã lưu khi Login
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': userEmail,
        'display_name': displayName,
        'photo_url': currentUser.photoURL ?? '',
        'language': 'vi',
        'fcm_token': '',
        'current_household_id': householdId, // Gắn user vào nhà mới
        'cuisines': ['Vietnamese', 'Healthy'],
        'updated_at': FieldValue.serverTimestamp(), // Đánh dấu thời điểm seed
      }, SetOptions(merge: true));
      debugPrint("✅ 2. Đã cập nhật User thật: $userId");

      // ==========================================
      // BƯỚC 2: TẠO HOUSEHOLD (Collection: households)
      // ==========================================
      final houseRef = _firestore.collection('households').doc(householdId);

      await houseRef.set({
        'household_id': householdId,
        'name': 'Gia Đình của $displayName', // Tên nhà động theo user
        'owner_id': userId,
        'invite_code': householdId, // invite_code = household_id
        'members': [userId], // [QUAN TRỌNG] Thêm chính user vào mảng members
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Households");

      // ==========================================
      // BƯỚC 3: TẠO TỦ LẠNH (Sub-collection: inventory)
      // ==========================================
      
      // Món 1: Thịt bò (Hết hạn NGAY MAI -> Để test thông báo)
      await houseRef.collection('inventory').doc('inv_01').set({
        'ingredient_id': 'inv_01',
        'household_id': householdId, // Gắn vào nhà mới
        'name': 'Thịt bò',
        'quantity': 500,
        'unit': 'g',
        'image_url': '',
        // Hết hạn sau 1 ngày (Ngày mai)
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'quick_tag': 'meat',
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Món 2: Trứng gà (Hết hạn ngày kia)
      await houseRef.collection('inventory').doc('inv_02').set({
        'ingredient_id': 'inv_02',
        'household_id': householdId,
        'name': 'Trứng gà',
        'quantity': 10,
        'unit': 'quả',
        'image_url': '',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'quick_tag': 'dairy',
        'added_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Inventory");

      // ==========================================
      // BƯỚC 4: TẠO CÔNG THỨC (Sub-collection: household_recipes)
      // ==========================================
      await houseRef.collection('household_recipes').doc(_recipeId).set({
        'local_recipe_id': _recipeId,
        'household_id': householdId,
        'api_recipe_id': 12345,
        'title': 'Bò Kho Tiêu',
        'image_url': 'https://spoonacular.com/recipeImages/beef-stew.jpg',
        'ready_in_minutes': 45,
        'calories': 350.5,
        'difficulty': 'Medium',
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'ingredients': [
          {'name': 'Thịt bò', 'amount': 300, 'unit': 'g'},
          {'name': 'Tiêu đen', 'amount': 1, 'unit': 'thìa'},
          {'name': 'Hành tím', 'amount': 2, 'unit': 'củ'},
        ],
        'instructions': 'Bước 1: Rửa sạch thịt bò...\nBước 2: Ướp gia vị...\nBước 3: Kho lửa nhỏ.',
      });
      debugPrint("✅ Đã tạo Recipes");

      // Sub-collection: Cooking History
      await houseRef.collection('cooking_history').add({
        'recipe_id': _recipeId,
        'api_recipe_id': 12345,
        'title': 'Bò Kho Tiêu',
        'cooked_at': FieldValue.serverTimestamp(),
        'is_favorite': true,
        'servings': 4,
        'tags': ['Beef', 'Spicy'],
      });
      debugPrint("✅ Đã tạo Cooking History");

      // Sub-collection: Favorite Recipes
      await houseRef.collection('favorite_recipes').doc('fav_01').set({
        'local_recipe_id': 'fav_01',
        'household_id': householdId,
        'api_recipe_id': 12345,
        'title': 'Bò Kho Tiêu',
        'image_url': 'https://spoonacular.com/recipeImages/beef-stew.jpg',
        'ready_in_minutes': 45,
        'calories': 350.5,
        'difficulty': 'Medium',
        'servings': 4,
        'added_by_uid': userId,
        'added_at': FieldValue.serverTimestamp(),
        'is_favorite': true,
        'ingredients': [
          {'name': 'Thịt bò', 'amount': 300, 'unit': 'g'},
          {'name': 'Tiêu đen', 'amount': 1, 'unit': 'thìa'},
          {'name': 'Hành tím', 'amount': 2, 'unit': 'củ'},
        ],
        'instructions': 'Bước 1: Rửa sạch thịt bò, cắt miếng vừa ăn.\nBước 2: Ướp thịt với tiêu đen, hành băm, nước mắm trong 30 phút.\nBước 3: Cho thịt vào nồi, thêm nước, kho lửa nhỏ khoảng 45 phút cho đến khi thịt mềm.\nBước 4: Nêm nếm lại gia vị, tắt bếp. Dùng nóng với bánh mì.',
      });

      // ==========================================
      // BƯỚC 5: TẠO LỊCH ĂN (Sub-collection: meal_plans)
      // ==========================================
      await houseRef.collection('meal_plans').doc('plan_01').set({
        'plan_id': 'plan_01',
        'household_id': householdId,
        'date': Timestamp.fromDate(DateTime.now()),
        'meal_type': 'Dinner',
        'local_recipe_id': _recipeId,
        'display_title': 'Bò Kho Tiêu',
        'display_image': 'https://spoonacular.com/recipeImages/beef-stew.jpg',
        'servings': 4,
        'is_cooked': false,
        'planned_by_uid': userId,
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Meal Plans");

      // ==========================================
      // BƯỚC 6: TẠO SHOPPING LIST (Sub-collection: shopping_list)
      // ==========================================
      await houseRef.collection('shopping_list').doc('shop_01').set({
        'item_id': 'shop_01',
        'household_id': householdId,
        'name': 'Hành tím',
        'quantity': 2,
        'unit': 'củ',
        'is_checked': false,
        'is_auto_generated': true,
        'for_recipe_id': _recipeId,
        'target_date': Timestamp.fromDate(DateTime.now()),
        'created_at': FieldValue.serverTimestamp(),
        'note': 'Mua loại củ to',
      });
      debugPrint("✅ Đã tạo Shopping List");

      debugPrint("🎉 HOÀN TẤT! Dữ liệu mẫu đã sẵn sàng cho User: $displayName");
    } catch (e) {
      debugPrint("❌ Lỗi khi tạo dữ liệu: $e");
    }
  }
}
