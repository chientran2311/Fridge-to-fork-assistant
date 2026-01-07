import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // Khởi tạo Service
  final AuthService _authService = AuthService();

  // Biến lưu trữ user hiện tại
  User? _user;

  // Display name từ Firestore
  String? _displayName;

  // Getter để UI truy cập
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String get displayName => _displayName ?? _user?.displayName ?? 'User';

  AuthProvider() {
    // Delay initialization to avoid notifyListeners during build
    Future.microtask(() => _init());
  }

  void _init() {
    // 1. Lấy user hiện tại ngay khi khởi động
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchDisplayName();
    }
    notifyListeners();

    // 2. Lắng nghe sự thay đổi trạng thái đăng nhập từ Firebase (Realtime)
    // Tự động chạy khi: Đăng nhập, Đăng xuất, Bị xóa, Token hết hạn...
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchDisplayName();
      } else {
        _displayName = null;
      }
      notifyListeners(); // Cập nhật UI ngay lập tức
    });
  }

  /// Fetch display_name từ Firestore
  Future<void> _fetchDisplayName() async {
    if (_user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (doc.exists) {
        _displayName = doc.data()?['display_name'] ?? _user?.displayName;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching display name: $e');
    }
  }

  // --- CÁC HÀM WRAPPER (GỌI SERVICE) ---

  // 1. Đăng nhập
  Future<String?> login(String email, String password) async {
    return await _authService.loginWithEmail(email: email, password: password);
  }

  // 2. Đăng ký
  Future<String?> register(String email, String password) async {
    return await _authService.registerWithEmail(
        email: email, password: password);
  }

  // 3. Đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
    // Lưu ý: authStateChanges ở trên sẽ tự động bắt được sự kiện này
    // và set _user = null, sau đó notifyListeners().
  }

  // 4. Xóa tài khoản
  Future<String?> deleteAccount() async {
    // Gọi hàm xóa bên Service
    String? error = await _authService.deleteAccount();

    if (error == null) {
      // Nếu xóa thành công (không có lỗi)
      _user = null; // Reset user local ngay lập tức để UI phản hồi nhanh
      notifyListeners();
    }

    return error; // Trả về null nếu thành công, hoặc chuỗi lỗi nếu thất bại
  }

  // 5. Cập nhật display_name
  Future<String?> updateDisplayName(String newName) async {
    if (_user == null) return 'User not logged in';

    try {
      // Cập nhật trên FirebaseAuth
      await _user!.updateDisplayName(newName);

      // Cập nhật trên Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'display_name': newName});

      // Cập nhật local state
      _displayName = newName;
      notifyListeners();

      return null; // Thành công
    } catch (e) {
      debugPrint('⚠️ Error updating display name: $e');
      return 'Lỗi cập nhật tên: $e';
    }
  }
}
