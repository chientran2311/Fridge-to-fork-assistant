import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';
// new provider for auth management
class AuthProvider extends ChangeNotifier {
  // Khởi tạo Service
  final AuthService _authService = AuthService();
  
  // Biến lưu trữ user hiện tại
  User? _user;

  // Getter để UI truy cập
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // 1. Lấy user hiện tại ngay khi khởi động
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();

    // 2. Lắng nghe sự thay đổi trạng thái đăng nhập từ Firebase (Realtime)
    // Tự động chạy khi: Đăng nhập, Đăng xuất, Bị xóa, Token hết hạn...
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Cập nhật UI ngay lập tức
    });
  }

  // --- CÁC HÀM WRAPPER (GỌI SERVICE) ---

  // 1. Đăng nhập
  Future<String?> login(String email, String password) async {
    return await _authService.loginWithEmail(email: email, password: password);
  }

  // 2. Đăng ký
  Future<String?> register(String email, String password) async {
    return await _authService.registerWithEmail(email: email, password: password);
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
}