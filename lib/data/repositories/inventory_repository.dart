import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../models/inventory_item.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate random invite code format: XXXX-YYYY (8 chars)
  String _generateInviteCode(String userId) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final prefix = userId.substring(0, min(4, userId.length)).toUpperCase();
    final suffix = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    return '$prefix-$suffix';
  }

  // Lấy stream inventory
  Stream<List<InventoryItem>> getInventoryStream(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('inventory')
        .orderBy('expiry_date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromFirestore(doc))
            .toList());
  }

  // Logic tạo nhà mới (Tách khỏi Provider cho gọn)
  Future<String> createNewHousehold(String userId) async {
    final newHouseRef = _firestore.collection('households').doc();
    // Tạo ID nhà mới (ví dụ: house_UID) để dễ quản lý, hoặc để autoID cũng được
    // Ở đây giữ autoID như cũ nhưng sửa field members
    
    // Generate invite code
    final inviteCode = _generateInviteCode(userId);
    
    await newHouseRef.set({
      'household_id': newHouseRef.id,
      'name': 'Nhà của tôi',
      'owner_id': userId,
      'members': [userId], // [SỬA QUAN TRỌNG] Đổi 'residents' -> 'members'
      'created_at': FieldValue.serverTimestamp(),
      'invite_code': inviteCode,
    });
    
    // Update User
    await _firestore.collection('users').doc(userId).update({
      'current_household_id': newHouseRef.id,
    });
    
    return newHouseRef.id;
  }

  // Thêm món ăn
  Future<void> addItem(String householdId, InventoryItem item, String userId) async {
    final newItemRef = _firestore
        .collection('households')
        .doc(householdId)
        .collection('inventory')
        .doc(); // Auto ID

    await newItemRef.set({
      'ingredient_id': newItemRef.id,
      'household_id': householdId, // Đảm bảo field này luôn có
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'expiry_date': item.expiryDate != null ? Timestamp.fromDate(item.expiryDate!) : null,
      'quick_tag': item.quickTag ?? 'Other',
      'added_by_uid': userId,
      'created_at': FieldValue.serverTimestamp(),
      'image_url': item.imageUrl ?? '',
    });
  }
}