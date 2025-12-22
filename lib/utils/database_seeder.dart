import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // IDs cố định để dễ dàng liên kết dữ liệu với nhau
  final String _userId = 'user_seed_01';
  final String _householdId = 'house_seed_01';
  final String _recipeId = 'recipe_seed_01';

  Future<void> seedDatabase() async {
    try {
      debugPrint("🚀 Bắt đầu tạo dữ liệu mẫu...");

      // ==========================================
      // BƯỚC 1: TẠO USER (Collection: users)
      // ==========================================
      await _firestore.collection('users').doc(_userId).set({
        'uid': _userId,
        'email': 'admin@beptroly.com',
        'display_name': 'Admin Bếp',
        'photo_url': 'https://i.pravatar.cc/300', // Ảnh avatar mẫu
        'language': 'vi',
        'fcm_token': '', 
        'current_household_id': _householdId, // Liên kết sang nhà
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Users");

      // ==========================================
      // BƯỚC 2: TẠO HOUSEHOLD (Collection: households)
      // ==========================================
      final houseRef = _firestore.collection('households').doc(_householdId);
      
      await houseRef.set({
        'household_id': _householdId,
        'name': 'Gia Đình Mẫu',
        'owner_id': _userId,
        'invite_code': 'ABC-123',
        'members': [_userId], // Mảng chứa UID các thành viên
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Households");

      // ==========================================
      // BƯỚC 3: TẠO TỦ LẠNH (Sub-collection: inventory)
      // ==========================================
      // Món 1: Thịt bò
      await houseRef.collection('inventory').doc('inv_01').set({
        'ingredient_id': 'inv_01',
        'household_id': _householdId,
        'name': 'Thịt bò',
        'quantity': 500,
        'unit': 'g',
        'image_url': '',
        // Hết hạn sau 5 ngày
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'quick_tag': 'meat',
        'added_by_uid': _userId,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Món 2: Trứng gà (Sắp hết hạn để test thông báo)
      await houseRef.collection('inventory').doc('inv_02').set({
        'ingredient_id': 'inv_02',
        'household_id': _householdId,
        'name': 'Trứng gà',
        'quantity': 10,
        'unit': 'quả',
        'image_url': '',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'quick_tag': 'dairy',
        'added_by_uid': _userId,
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Inventory");

      // ==========================================
      // BƯỚC 4: TẠO CÔNG THỨC (Sub-collection: household_recipes)
      // ==========================================
      await houseRef.collection('household_recipes').doc(_recipeId).set({
        'local_recipe_id': _recipeId,
        'household_id': _householdId,
        'api_recipe_id': 12345, // ID giả định từ API Spoonacular
        'title': 'Bò Kho Tiêu',
        'image_url': 'https://spoonacular.com/recipeImages/beef-stew.jpg',
        'ready_in_minutes': 45,
        'calories': 350.5,
        'difficulty': 'Medium',
        'added_by_uid': _userId,
        'added_at': FieldValue.serverTimestamp(),
        
        // Cấu trúc mảng nguyên liệu (Thay thế bảng Recipe_Required_Ingredients)
        'ingredients': [
          {'name': 'Thịt bò', 'amount': 300, 'unit': 'g'},
          {'name': 'Tiêu đen', 'amount': 1, 'unit': 'thìa'},
          {'name': 'Hành tím', 'amount': 2, 'unit': 'củ'},
        ],
        
        'instructions': 'Bước 1: Rửa sạch thịt bò...\nBước 2: Ướp gia vị...\nBước 3: Kho lửa nhỏ.',
      });
      debugPrint("✅ Đã tạo Recipes");

      // ==========================================
      // BƯỚC 5: TẠO LỊCH ĂN (Sub-collection: meal_plans)
      // ==========================================
      await houseRef.collection('meal_plans').doc('plan_01').set({
        'plan_id': 'plan_01',
        'household_id': _householdId,
        'date': Timestamp.fromDate(DateTime.now()), // Lịch ăn hôm nay
        'meal_type': 'Dinner',
        'local_recipe_id': _recipeId, // Trỏ về công thức Bò Kho ở trên
        'display_title': 'Bò Kho Tiêu',
        'display_image': 'https://spoonacular.com/recipeImages/beef-stew.jpg',
        'servings': 4,
        'is_cooked': false,
        'planned_by_uid': _userId,
        'created_at': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Đã tạo Meal Plans");

      // ==========================================
      // BƯỚC 6: TẠO SHOPPING LIST (Sub-collection: shopping_list)
      // ==========================================
      await houseRef.collection('shopping_list').doc('shop_01').set({
        'item_id': 'shop_01',
        'household_id': _householdId,
        'name': 'Hành tím',
        'quantity': 2,
        'unit': 'củ',
        'is_checked': false,
        'is_auto_generated': true,
        'for_recipe_id': _recipeId, // Mua để nấu Bò Kho
        'target_date': Timestamp.fromDate(DateTime.now()),
        'created_at': FieldValue.serverTimestamp(),
        'note': 'Mua loại củ to',
      });
      debugPrint("✅ Đã tạo Shopping List");
      
      debugPrint("🎉 HOÀN TẤT! Dữ liệu mẫu đã sẵn sàng.");

    } catch (e) {
      debugPrint("❌ Lỗi khi tạo dữ liệu: $e");
    }
  }
}