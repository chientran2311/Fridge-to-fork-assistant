import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM PHỤ: ĐỒNG BỘ USER SANG FIRESTORE ---
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      
      // Thêm timeout để tránh treo khi Firestore không phản hồi
      final snapshot = await userRef.get().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("⏰ Firestore timeout - bỏ qua sync");
          throw Exception("Firestore timeout");
        },
      );

      if (!snapshot.exists) {
        // A. Nếu chưa có hồ sơ -> Tạo mới
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'display_name': user.displayName ?? 'Người dùng mới',
          'photo_url': user.photoURL ?? '',
          'current_household_id': null,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
      } else {
        // B. Nếu đã có hồ sơ -> Cập nhật giờ đăng nhập mới nhất
        await userRef.update({
          'last_login': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
      }
      print("✅ Sync Firestore thành công");
    } catch (e) {
      print("⚠️ Lỗi đồng bộ Firestore: $e");
      // Không throw để login vẫn thành công dù sync thất bại
    }
  }

  // --- 1. Đăng nhập bằng Email & Password ---
  Future<String?> loginWithEmail(
      {required String email, required String password}) async {
    try {
      print("🔐 Đang đăng nhập: $email");
      
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print("✅ Firebase Auth thành công: ${cred.user?.uid}");

      if (cred.user != null) {
        // Không await sync để login nhanh hơn
        _syncUserToFirestore(cred.user!);
      }

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code}");
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
        case 'invalid-credential':
          return 'Email hoặc mật khẩu không chính xác.';
        default:
          return 'Lỗi đăng nhập: ${e.message}';
      }
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      return 'Đã xảy ra lỗi: $e';
    }
  }

  // --- 2. Đăng ký bằng Email & Password ---
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // B1: Tạo Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = cred.user;
      if (user != null) {
        // B1.5: Cập nhật displayName vào FirebaseAuth profile
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }

        // B2: Tạo Nhà Mới ngay lập tức
        final String newHouseholdId =
            'house_${user.uid}'; // ID nhà gắn với ID User

        await _firestore.collection('households').doc(newHouseholdId).set({
          'household_id': newHouseholdId,
          'name': 'Gia đình của bạn',
          'owner_id': user.uid,
          'members': [user.uid], // Quan trọng: Có user trong members
          'created_at': FieldValue.serverTimestamp(),
        });

        // B3: Tạo User Document (Link tới nhà vừa tạo)
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'display_name':
              displayName ?? 'Người dùng mới', // [SỬA] Lấy từ parameter
          'photo_url': user.photoURL ?? '',
          'current_household_id':
              newHouseholdId, // [QUAN TRỌNG] Không để null nữa
          'fcm_token': '', // Sẽ được update ở màn hình Login/Register
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        });
      }

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng.';
        case 'weak-password':
          return 'Mật khẩu quá yếu.';
        case 'invalid-email':
          return 'Email không hợp lệ.';
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

  // --- 4. Xóa tài khoản (Mới) ---
  Future<String?> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Không tìm thấy người dùng.";

      // Bước 1: Xóa dữ liệu user trong Firestore
      // Lưu ý: Không xóa household vì có thể còn thành viên khác
      await _firestore.collection('users').doc(user.uid).delete();

      // Bước 2: Xóa tài khoản Auth
      await user.delete();

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      // Lỗi này xảy ra nếu user đăng nhập quá lâu
      if (e.code == 'requires-recent-login') {
        return 'Để bảo mật, vui lòng đăng xuất và đăng nhập lại để thực hiện hành động này.';
      }
      return 'Lỗi xóa tài khoản: ${e.message}';
    } catch (e) {
      return 'Đã xảy ra lỗi không xác định: $e';
    }
  }

  // --- 5. Lấy User hiện tại ---
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
