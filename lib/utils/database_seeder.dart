import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nhận userId và householdId từ user đang đăng nhập
  Future<void> seedDatabase({
    required String userId,
    required String householdId,
  }) async {
    try {
      debugPrint("🚀 Bắt đầu tạo dữ liệu mẫu cho user: $userId...");

      // ==========================================
      // BƯỚC 1: LẤY HOUSEHOLD REFERENCE
      // ==========================================
      final houseRef = _firestore.collection('households').doc(householdId);

      // ==========================================
      // BƯỚC 2: TẠO TỦ LẠNH (Sub-collection: inventory) - 10 items
      // ==========================================
      final inventoryItems = [
        {'name': 'Thịt bò', 'quantity': 500.0, 'unit': 'g', 'tag': 'meat', 'days': 5},
        {'name': 'Trứng gà', 'quantity': 10.0, 'unit': 'quả', 'tag': 'dairy', 'days': 2},
        {'name': 'Cà rốt', 'quantity': 3.0, 'unit': 'củ', 'tag': 'vegetable', 'days': 7},
        {'name': 'Sữa tươi', 'quantity': 1.0, 'unit': 'lít', 'tag': 'dairy', 'days': 3},
        {'name': 'Thịt gà', 'quantity': 800.0, 'unit': 'g', 'tag': 'meat', 'days': 4},
        {'name': 'Cải thảo', 'quantity': 1.0, 'unit': 'kg', 'tag': 'vegetable', 'days': 6},
        {'name': 'Cá hồi', 'quantity': 400.0, 'unit': 'g', 'tag': 'seafood', 'days': 2},
        {'name': 'Khoai tây', 'quantity': 5.0, 'unit': 'củ', 'tag': 'vegetable', 'days': 10},
        {'name': 'Phô mai', 'quantity': 200.0, 'unit': 'g', 'tag': 'dairy', 'days': 15},
        {'name': 'Tôm tươi', 'quantity': 300.0, 'unit': 'g', 'tag': 'seafood', 'days': 1},
      ];
      
      for (int i = 0; i < inventoryItems.length; i++) {
        final item = inventoryItems[i];
        await houseRef.collection('inventory').doc('inv_${(i + 1).toString().padLeft(2, '0')}').set({
          'name': item['name'],
          'quantity': item['quantity'],
          'unit': item['unit'],
          'image_url': '',
          'expiry_date': Timestamp.fromDate(
            DateTime.now().add(Duration(days: item['days'] as int))
          ),
          'quick_tag': item['tag'],
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      
      debugPrint("✅ Đã tạo 10 Inventory items");

      // ==========================================
      // BƯỚC 3: TẠO CÔNG THỨC (Sub-collection: household_recipes) - 10 recipes
      // ==========================================
      final recipes = [
        {'title': 'Bò Kho Tiêu', 'time': 45, 'cal': 350.5, 'diff': 'Medium', 'apiId': 12345},
        {'title': 'Gà Rán Giòn', 'time': 30, 'cal': 420.0, 'diff': 'Easy', 'apiId': 12346},
        {'title': 'Cá Hồi Nướng', 'time': 25, 'cal': 280.0, 'diff': 'Easy', 'apiId': 12347},
        {'title': 'Canh Cải Thảo', 'time': 20, 'cal': 120.0, 'diff': 'Easy', 'apiId': 12348},
        {'title': 'Mì Ý Sốt Kem', 'time': 35, 'cal': 480.0, 'diff': 'Medium', 'apiId': 12349},
        {'title': 'Phở Bò', 'time': 60, 'cal': 400.0, 'diff': 'Hard', 'apiId': 12350},
        {'title': 'Tôm Chiên Xù', 'time': 25, 'cal': 320.0, 'diff': 'Medium', 'apiId': 12351},
        {'title': 'Salad Rau Củ', 'time': 15, 'cal': 150.0, 'diff': 'Easy', 'apiId': 12352},
        {'title': 'Súp Khoai Tây', 'time': 40, 'cal': 220.0, 'diff': 'Easy', 'apiId': 12353},
        {'title': 'Bánh Pizza Phô Mai', 'time': 50, 'cal': 520.0, 'diff': 'Medium', 'apiId': 12354},
      ];
      
      for (int i = 0; i < recipes.length; i++) {
        final recipe = recipes[i];
        final recipeId = 'recipe_${householdId}_${(i + 1).toString().padLeft(2, '0')}';
        
        await houseRef.collection('household_recipes').doc(recipeId).set({
          'local_recipe_id': recipeId,
          'household_id': householdId,
          'api_recipe_id': recipe['apiId'],
          'title': recipe['title'],
          'image_url': 'https://spoonacular.com/recipeImages/${recipe["apiId"]}.jpg',
          'ready_in_minutes': recipe['time'],
          'calories': recipe['cal'],
          'difficulty': recipe['diff'],
          'added_by_uid': userId,
          'added_at': FieldValue.serverTimestamp(),
          'ingredients': [
            {'name': 'Nguyên liệu 1', 'amount': 100, 'unit': 'g'},
            {'name': 'Nguyên liệu 2', 'amount': 2, 'unit': 'thìa'},
          ],
          'instructions': 'Bước 1: Chuẩn bị...\nBước 2: Chế biến...\nBước 3: Hoàn thành.',
        });
      }
      debugPrint("✅ Đã tạo 10 Recipes");

      // ==========================================
      // BƯỚC 4: TẠO LỊCH SỬ NẤU ĂN (Sub-collection: cooking_history) - 10 items
      // ==========================================
      for (int i = 0; i < 10; i++) {
        final recipe = recipes[i];
        await houseRef.collection('cooking_history').add({
          'recipe_id': 'recipe_${householdId}_${(i + 1).toString().padLeft(2, '0')}',
          'api_recipe_id': recipe['apiId'],
          'title': recipe['title'],
          'cooked_at': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 10 - i))
          ),
          'is_favorite': i < 3,
          'servings': 2 + (i % 4),
          'tags': ['Tag ${i + 1}'],
        });
      }
      debugPrint("✅ Đã tạo 10 Cooking History items");

      // ==========================================
      // BƯỚC 5: TẠO FAVORITE RECIPES - 10 items
      // ==========================================
      for (int i = 0; i < 10; i++) {
        final recipe = recipes[i];
        await houseRef.collection('favorite_recipes').doc('fav_${(i + 1).toString().padLeft(2, '0')}').set({
          'local_recipe_id': 'fav_${(i + 1).toString().padLeft(2, '0')}',
          'household_id': householdId,
          'api_recipe_id': recipe['apiId'],
          'title': recipe['title'],
          'image_url': 'https://spoonacular.com/recipeImages/${recipe["apiId"]}.jpg',
          'ready_in_minutes': recipe['time'],
          'calories': recipe['cal'],
          'difficulty': recipe['diff'],
          'servings': 2 + (i % 4),
          'added_by_uid': userId,
          'added_at': FieldValue.serverTimestamp(),
          'is_favorite': true,
        });
      }
      debugPrint("✅ Đã tạo 10 Favorite Recipes");
      
      // ==========================================
      // BƯỚC 6: TẠO LỊCH ĂN (Sub-collection: meal_plans) - 10 items
      // ==========================================
      final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
      for (int i = 0; i < 10; i++) {
        final recipe = recipes[i];
        await houseRef.collection('meal_plans').doc('plan_${(i + 1).toString().padLeft(2, '0')}').set({
          'plan_id': 'plan_${(i + 1).toString().padLeft(2, '0')}',
          'household_id': householdId,
          'date': Timestamp.fromDate(
            DateTime.now().add(Duration(days: i ~/ 3))
          ),
          'meal_type': mealTypes[i % mealTypes.length],
          'local_recipe_id': 'recipe_${householdId}_${(i + 1).toString().padLeft(2, '0')}',
          'display_title': recipe['title'],
          'display_image': 'https://spoonacular.com/recipeImages/${recipe["apiId"]}.jpg',
          'servings': 2 + (i % 4),
          'is_cooked': i < 2,
          'planned_by_uid': userId,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      debugPrint("✅ Đã tạo 10 Meal Plans");

      // ==========================================
      // BƯỚC 7: TẠO SHOPPING LIST (Sub-collection: shopping_list) - 10 items
      // ==========================================
      final shoppingItems = [
        {'name': 'Hành tím', 'qty': 2, 'unit': 'củ', 'note': 'Mua loại củ to'},
        {'name': 'Gừng', 'qty': 100, 'unit': 'g', 'note': 'Tươi'},
        {'name': 'Nước mắm', 'qty': 1, 'unit': 'chai', 'note': 'Loại ngon'},
        {'name': 'Dầu ăn', 'qty': 1, 'unit': 'lít', 'note': ''},
        {'name': 'Rau mùi', 'qty': 1, 'unit': 'bó', 'note': ''},
        {'name': 'Tỏi', 'qty': 3, 'unit': 'củ', 'note': ''},
        {'name': 'Ớt', 'qty': 5, 'unit': 'quả', 'note': 'Ớt hiểm'},
        {'name': 'Mì gói', 'qty': 10, 'unit': 'gói', 'note': ''},
        {'name': 'Rau xà lách', 'qty': 1, 'unit': 'kg', 'note': 'Rửa sạch'},
        {'name': 'Nước lọc', 'qty': 2, 'unit': 'chai', 'note': ''},
      ];
      
      for (int i = 0; i < shoppingItems.length; i++) {
        final item = shoppingItems[i];
        await houseRef.collection('shopping_list').doc('shop_${(i + 1).toString().padLeft(2, '0')}').set({
          'item_id': 'shop_${(i + 1).toString().padLeft(2, '0')}',
          'household_id': householdId,
          'name': item['name'],
          'quantity': item['qty'],
          'unit': item['unit'],
          'is_checked': i < 2,
          'is_auto_generated': i % 2 == 0,
          'for_recipe_id': 'recipe_${householdId}_${((i % 10) + 1).toString().padLeft(2, '0')}',
          'target_date': Timestamp.fromDate(
            DateTime.now().add(Duration(days: i % 5))
          ),
          'created_at': FieldValue.serverTimestamp(),
          'note': item['note'],
        });
      }
      debugPrint("✅ Đã tạo 10 Shopping List items");

      debugPrint("🎉 HOÀN TẤT! Dữ liệu mẫu đã sẵn sàng.");
    } catch (e) {
      debugPrint("❌ Lỗi khi tạo dữ liệu: $e");
    }
  }
}
