import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Tạo instance của FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. Đăng nhập bằng Email & Password ---
  // Hàm này trả về String? (null nếu thành công, chuỗi lỗi nếu thất bại)
  // Cách này giúp UI dễ dàng hiển thị thông báo lỗi.
  Future<String?> loginWithEmail({
    required String email, 
    required String password
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      // Xử lý các mã lỗi phổ biến của Firebase
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
          return 'Mật khẩu không chính xác.';
        case 'invalid-email':
          return 'Định dạng email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        default:
          return 'Lỗi đăng nhập: ${e.message}';
      }
    } catch (e) {
      return 'Đã xảy ra lỗi không xác định.';
    }
  }

  // --- 2. Đăng ký bằng Email & Password ---
  Future<String?> registerWithEmail({
    required String email, 
    required String password
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng.';
        case 'weak-password':
          return 'Mật khẩu quá yếu.';
        case 'invalid-email':
          return 'Định dạng email không hợp lệ.';
        default:
          return 'Lỗi đăng ký: ${e.message}';
      }
    } catch (e) {
      return 'Đã xảy ra lỗi không xác định.';
    }
  }

  // --- 3. Đăng xuất ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- 4. Lấy User hiện tại ---
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}