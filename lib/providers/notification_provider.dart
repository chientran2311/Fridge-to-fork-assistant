import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fridge_notification.dart';

class NotificationProvider extends ChangeNotifier {
  List<FridgeNotification> _notifications = [];
  bool _isLoading = false;
  
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _userSubscription;

  List<FridgeNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  /// Số lượng thông báo chưa đọc
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    Future.microtask(() => _init());
  }

  // Khởi tạo và lắng nghe auth
  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _cancelSubscriptions();
      
      if (user != null) {
        _listenToUserDoc(user.uid);
      } else {
        _notifications = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Lắng nghe user doc để lấy household_id
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
        _listenToNotifications(householdId);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Lắng nghe thông báo của household
  void _listenToNotifications(String? householdId) {
    _notificationSubscription?.cancel();

    if (householdId != null) {
      _notificationSubscription = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50) // Giới hạn 50 thông báo gần nhất
          .snapshots()
          .listen(
        (snapshot) {
          _notifications = snapshot.docs
              .map((doc) => FridgeNotification.fromFirestore(doc))
              .toList();
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          debugPrint("❌ Lỗi lấy thông báo: $e");
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      _notifications = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm thông báo mới
  Future<void> addNotification(FridgeNotification notification) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('notifications')
        .add(notification.toFirestore());
  }

  // Đánh dấu tất cả là đã đọc
  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    final batch = FirebaseFirestore.instance.batch();
    
    for (var notification in _notifications.where((n) => !n.isRead)) {
      final docRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('notifications')
          .doc(notification.id);
      
      batch.update(docRef, {'is_read': true});
    }
    
    await batch.commit();
  }

  // Đánh dấu một thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('notifications')
        .doc(notificationId)
        .update({'is_read': true});
  }

  // Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    await FirebaseFirestore.instance
        .collection('households')
        .doc(householdId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Xóa tất cả thông báo
  Future<void> clearAllNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final householdId = userDoc.data()?['current_household_id'];
    if (householdId == null) return;

    final batch = FirebaseFirestore.instance.batch();
    
    for (var notification in _notifications) {
      final docRef = FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .collection('notifications')
          .doc(notification.id);
      
      batch.delete(docRef);
    }
    
    await batch.commit();
  }

  void _cancelSubscriptions() {
    _userSubscription?.cancel();
    _notificationSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}