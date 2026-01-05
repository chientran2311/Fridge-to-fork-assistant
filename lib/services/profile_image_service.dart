import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service xử lý ảnh profile (Repository Pattern)
/// Chịu trách nhiệm: Pick ảnh, lưu local, đọc path
/// Hỗ trợ multi-user bằng cách lưu ảnh theo userId
class ProfileImageService {
  // Singleton Pattern
  static final ProfileImageService _instance = ProfileImageService._internal();
  factory ProfileImageService() => _instance;
  ProfileImageService._internal();

  final ImagePicker _picker = ImagePicker();
  
  // Key prefix lưu trong SharedPreferences
  static const String _profileImageKeyPrefix = 'profile_image_path_';

  /// Tạo key dựa trên userId
  String _getKeyForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return '${_profileImageKeyPrefix}guest';
    }
    return '$_profileImageKeyPrefix$userId';
  }

  /// Chọn ảnh từ Gallery
  /// Returns: File? (null nếu user cancel)
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Lỗi pick image: $e');
      return null;
    }
  }

  /// Chọn ảnh từ Camera
  /// Returns: File? (null nếu user cancel)
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Lỗi capture image: $e');
      return null;
    }
  }

  /// Lưu ảnh vào app directory và lưu path vào SharedPreferences
  /// Returns: String? (path của ảnh đã lưu, null nếu lỗi)
  /// [userId]: ID của user để phân biệt ảnh giữa các user
  Future<String?> saveProfileImage(File imageFile, {String? userId}) async {
    try {
      // Lấy app document directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String userFolder = userId ?? 'guest';
      final String fileName = 'profile_avatar_${userFolder}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = '${appDir.path}/$fileName';
      
      // Copy file vào app directory
      final File savedFile = await imageFile.copy(savedPath);
      
      // Xóa ảnh cũ nếu có
      await _deleteOldProfileImage(userId: userId);
      
      // Lưu path vào SharedPreferences với key theo userId
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getKeyForUser(userId), savedFile.path);
      
      print('✅ Đã lưu ảnh profile cho user $userId: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      print('❌ Lỗi lưu ảnh: $e');
      return null;
    }
  }

  /// Lấy path ảnh profile đã lưu
  /// Returns: String? (null nếu chưa có ảnh)
  /// [userId]: ID của user
  Future<String?> getProfileImagePath({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? path = prefs.getString(_getKeyForUser(userId));
      
      // Kiểm tra file có tồn tại không
      if (path != null && await File(path).exists()) {
        return path;
      }
      return null;
    } catch (e) {
      print('❌ Lỗi đọc path ảnh: $e');
      return null;
    }
  }

  /// Xóa ảnh profile
  /// [userId]: ID của user
  Future<bool> deleteProfileImage({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForUser(userId);
      final String? path = prefs.getString(key);
      
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      await prefs.remove(key);
      print('✅ Đã xóa ảnh profile cho user $userId');
      return true;
    } catch (e) {
      print('❌ Lỗi xóa ảnh: $e');
      return false;
    }
  }

  /// Helper: Xóa ảnh cũ trước khi lưu ảnh mới
  /// [userId]: ID của user
  Future<void> _deleteOldProfileImage({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? oldPath = prefs.getString(_getKeyForUser(userId));
    
    if (oldPath != null) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) {
        await oldFile.delete();
        print('🗑️ Đã xóa ảnh cũ');
      }
    }
  }
}