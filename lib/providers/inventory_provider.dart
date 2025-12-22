import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/inventory_item.dart';

class InventoryProvider extends ChangeNotifier {
  // --- STATE ---
  List<InventoryItem> _items = [];
  bool _isLoading = true;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;

  // Getter phụ
  List<String> get ingredientNames => _items.map((e) => e.name).toList();

  // --- LISTEN DATA ---
  void listenToInventory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((userSnapshot) {
      
      if (userSnapshot.exists) {
        final householdId = userSnapshot.data()?['current_household_id'];

        // Nếu có Household ID thì mới lắng nghe Inventory
        if (householdId != null) {
          FirebaseFirestore.instance
              .collection('households')
              .doc(householdId)
              .collection('inventory')
              .orderBy('expiry_date')
              .snapshots()
              .listen((inventorySnapshot) {
            
            _items = inventorySnapshot.docs
                .map((doc) => InventoryItem.fromFirestore(doc))
                .toList();

            _isLoading = false;
            notifyListeners();
          });
        } else {
          // Nếu chưa có nhà, danh sách rỗng, tắt loading
          _items = [];
          _isLoading = false;
          notifyListeners();
        }
      }
    });
  }

  // --- ADD ITEM (ĐÃ NÂNG CẤP LOGIC TỰ TẠO NHÀ) ---
  Future<void> addItem({
    required String name,
    required double quantity,
    required String unit,
    required DateTime expiryDate,
    String? category,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Bạn chưa đăng nhập");

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      
      // 1. Kiểm tra xem user đã có nhà chưa
      String? householdId = userDoc.data()?['current_household_id'];

      // 2. [LOGIC MỚI] Nếu chưa có nhà -> Tự động tạo "Nhà Riêng"
      if (householdId == null) {
        debugPrint("⚠️ User chưa có nhà. Đang tạo nhà cá nhân...");
        
        // Tạo document nhà mới
        final newHouseRef = FirebaseFirestore.instance.collection('households').doc();
        householdId = newHouseRef.id;

        // Lưu thông tin nhà mới
        await newHouseRef.set({
          'household_id': householdId,
          'name': 'Nhà của tôi', // Tên mặc định
          'owner_id': user.uid,
          'residents': [user.uid], // User là cư dân duy nhất
          'created_at': FieldValue.serverTimestamp(),
        });

        // Cập nhật ngược lại vào User để lần sau không phải tạo nữa
        await userRef.update({
          'current_household_id': householdId,
        });
        
        debugPrint("✅ Đã tạo nhà mới: $householdId");
      }

      // 3. Bây giờ chắc chắn đã có householdId, tiến hành thêm món ăn như bình thường
      final newItemRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('inventory')
          .doc();

      await newItemRef.set({
        'ingredient_id': newItemRef.id,
        'household_id': householdId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'expiry_date': Timestamp.fromDate(expiryDate),
        'quick_tag': category ?? 'Other',
        'added_by_uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'image_url': '',
      });

    } catch (e) {
      debugPrint("Lỗi thêm món: $e");
      rethrow;
    }
  }
}