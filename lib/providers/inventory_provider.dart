import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';
import '../data/repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _repository = InventoryRepository();
  
  List<InventoryItem> _items = [];
  bool _isLoading = false;
  
  // Biến quản lý listener để tránh rò rỉ bộ nhớ
  StreamSubscription? _userSubscription;
  StreamSubscription? _inventorySubscription;

  List<InventoryItem> get items => _items;
  bool get isLoading => _isLoading;
  List<String> get ingredientNames => _items.map((e) => e.name).toList();

  InventoryProvider() {
    // Delay initialization to avoid notifyListeners during build
    Future.microtask(() => _init());
  }

  // --- 1. LOGIC KHỞI TẠO THÔNG MINH ---
  void _init() {
    // Lắng nghe trạng thái Auth thay vì gọi 1 lần rồi thôi
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _cancelSubscriptions(); // Hủy listener cũ nếu có
      
      if (user != null) {
        // User đã đăng nhập -> Bắt đầu nghe dữ liệu User
        _listenToUserDoc(user.uid);
      } else {
        // User chưa đăng nhập/Đăng xuất -> Xóa dữ liệu local
        _items = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // --- 2. LẮNG NGHE USER DOC (Để lấy household_id) ---
  void _listenToUserDoc(String uid) {
    _isLoading = true;
    notifyListeners();

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((userSnapshot) {
      
      if (userSnapshot.exists) {
        final householdId = userSnapshot.data()?['current_household_id'];
        // Có thay đổi về nhà -> Nghe lại kho
        _listenToInventory(householdId);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // --- 3. LẮNG NGHE KHO HÀNG (INVENTORY) ---
  void _listenToInventory(String? householdId) {
    // Hủy listener kho cũ trước khi tạo mới
    _inventorySubscription?.cancel();

    if (householdId != null) {
      _inventorySubscription = _repository.getInventoryStream(householdId).listen(
        (items) {
          _items = items;
          _isLoading = false;
          notifyListeners(); // Cập nhật UI
        },
        onError: (e) {
          debugPrint("❌ Lỗi lấy kho hàng: $e");
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      // User chưa có nhà
      _items = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hàm public để UI gọi nếu cần refresh thủ công (Optional)
  void listenToInventory() {
    // Hàm này giữ lại để tương thích code cũ ở main.dart, 
    // nhưng thực tế logic đã nằm trong _init() rồi.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) _listenToUserDoc(user.uid);
  }

  // --- ADD ITEM (Giữ nguyên logic của bạn) ---
  Future<void> addItem({
    required String name,
    required double quantity,
    required String unit,
    required DateTime expiryDate,
    String? category,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Bạn chưa đăng nhập");

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String? householdId = userDoc.data()?['current_household_id'];

    if (householdId == null) {
       // Tạo nhà mới nếu chưa có
       householdId = await _repository.createNewHousehold(user.uid);
    }

    final newItem = InventoryItem(
      id: '', 
      name: name,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      quickTag: category,
    );

    await _repository.addItem(householdId, newItem, user.uid);
  }

  // --- DỌN DẸP ---
  void _cancelSubscriptions() {
    _userSubscription?.cancel();
    _inventorySubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }


  // Xóa danh sách items
  Future<void> deleteItems(List<String> itemIds) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String? householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    final batch = FirebaseFirestore.instance.batch();
    for (var id in itemIds) {
      final docRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('inventory')
          .doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
  }

  // Cập nhật item
  Future<void> updateItem(InventoryItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String? householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('inventory')
        .doc(item.id)
        .update({
          'name': item.name,
          'quantity': item.quantity,
          'unit': item.unit,
          'expiry_date': item.expiryDate != null ? Timestamp.fromDate(item.expiryDate!) : null,
          'quick_tag': item.quickTag,
        });
  }
}