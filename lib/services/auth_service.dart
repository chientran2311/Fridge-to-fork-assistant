import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 2. Instance Firestore

  // --- HÀM PHỤ: ĐỒNG BỘ USER SANG FIRESTORE ---
  // Hàm này tự động chạy sau khi Login hoặc Register thành công
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        // A. Nếu chưa có hồ sơ -> Tạo mới
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'display_name': user.displayName ?? 'Người dùng mới',
          'photo_url': user.photoURL ?? '',
          'current_household_id': null, // Để null, InventoryProvider sẽ tự xử lý tạo nhà sau
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        });
      } else {
        // B. Nếu đã có hồ sơ -> Cập nhật giờ đăng nhập mới nhất
        await userRef.update({
          'last_login': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Chỉ log lỗi, không chặn luồng đăng nhập của user
      print("⚠️ Lỗi đồng bộ Firestore: $e");
    }
  }

  // --- 1. Đăng nhập bằng Email & Password ---
  Future<String?> loginWithEmail({
    required String email, 
    required String password
  }) async {
    try {
      // 1. Đăng nhập Auth
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // 2. Đồng bộ sang Firestore (Quan trọng)
      if (cred.user != null) {
        await _syncUserToFirestore(cred.user!);
      }

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
          return 'Mật khẩu không chính xác.';
        case 'invalid-email':
          return 'Định dạng email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'too-many-requests':
          return 'Quá nhiều lần thử thất bại. Vui lòng thử lại sau.';
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
      // 1. Tạo tài khoản Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // 2. Đồng bộ sang Firestore (Quan trọng)
      if (cred.user != null) {
        await _syncUserToFirestore(cred.user!);
      }

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng.';
        case 'weak-password':
          return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
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