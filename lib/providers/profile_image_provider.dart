import 'package:flutter/foundation.dart';

/// Provider quản lý state ảnh profile (ViewModel trong MVVM)
/// Sử dụng ChangeNotifier Pattern để notify UI khi state thay đổi
/// Hỗ trợ multi-user: mỗi user có ảnh profile riêng
class ProfileImageProvider extends ChangeNotifier {
  // TODO: Implement profile image service or remove this provider if not needed

  // State
  String? _imagePath;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId; // ID của user hiện tại

  // Getters
  String? get imagePath => _imagePath;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasImage => _imagePath != null;
  String? get currentUserId => _currentUserId;

  /// Load ảnh profile từ local storage cho user cụ thể
  /// [userId]: ID của user đang đăng nhập
  Future<void> loadProfileImageForUser(String? userId) async {
    _currentUserId = userId;
    _setLoading(true);
    
    // TODO: Implement profile image loading
    _imagePath = null;
    _errorMessage = null;
    
    _setLoading(false);
  }

  /// Reset state về mặc định (dùng cho màn hình đăng ký)
  /// Không load ảnh từ storage, chỉ hiển thị icon mặc định
  void resetToDefault() {
    _imagePath = null;
    _currentUserId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Đổi user (khi user khác đăng nhập)
  /// Tự động load ảnh của user mới
  Future<void> switchUser(String? userId) async {
    if (_currentUserId != userId) {
      await loadProfileImageForUser(userId);
    }
  }

  /// Chọn ảnh từ Gallery và lưu cho user hiện tại
  Future<bool> pickAndSaveFromGallery() async {
    _setLoading(true);
    
    // TODO: Implement image picking from gallery
    _setLoading(false);
    return false;
  }

  /// Chọn ảnh từ Camera và lưu cho user hiện tại
  Future<bool> pickAndSaveFromCamera() async {
    _setLoading(true);
    
    // TODO: Implement image picking from camera
    _setLoading(false);
    return false;
  }

  /// Xóa ảnh profile của user hiện tại
  Future<bool> removeProfileImage() async {
    _setLoading(true);
    
    // TODO: Implement profile image removal
    _imagePath = null;
    _errorMessage = null;
    _setLoading(false);
    return true;
  }

  /// Helper: Set loading và notify
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
