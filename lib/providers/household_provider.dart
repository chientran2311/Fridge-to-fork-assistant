import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/household_service.dart';

/// HouseholdProvider - MVVM Pattern
/// Wrap HouseholdService để UI có thể reactive update
class HouseholdProvider extends ChangeNotifier {
  final HouseholdService _householdService = HouseholdService();

  // State
  Map<String, dynamic>? _currentHousehold;
  List<Map<String, dynamic>> _userHouseholds = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get currentHousehold => _currentHousehold;
  List<Map<String, dynamic>> get userHouseholds => _userHouseholds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String? get currentHouseholdId => _currentHousehold?['household_id'];
  String? get currentHouseholdName => _currentHousehold?['name'];
  String? get inviteCode => _currentHousehold?['invite_code']?.toString();
  bool get isOwner => _currentHousehold?['owner_id'] == FirebaseAuth.instance.currentUser?.uid;

  HouseholdProvider() {
    // Delay initialization to avoid notifyListeners during build
    Future.microtask(() => _init());
  }

  /// Khởi tạo: Lắng nghe auth state và load household
  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await loadCurrentHousehold();
        await loadUserHouseholds();
      } else {
        _currentHousehold = null;
        _userHouseholds = [];
        notifyListeners();
      }
    });
  }

  /// Load thông tin household hiện tại
  Future<void> loadCurrentHousehold() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentHousehold = await _householdService.getCurrentUserHousehold();
      
      debugPrint('🏠 HouseholdProvider: Loaded household = $_currentHousehold');
      debugPrint('🔑 Invite code = ${_currentHousehold?['invite_code']}');
      
      // Nếu chưa có household, tự động tạo mới
      if (_currentHousehold == null) {
        debugPrint('⚠️ No household found, creating new one...');
        await _householdService.initializeUserHousehold();
        _currentHousehold = await _householdService.getCurrentUserHousehold();
        debugPrint('✅ Created new household = $_currentHousehold');
      }
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin nhà: $e';
      debugPrint('❌ Error loading household: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load danh sách households user là thành viên
  Future<void> loadUserHouseholds() async {
    try {
      _userHouseholds = await _householdService.getUserHouseholds();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user households: $e');
    }
  }

  /// Tạo household mới
  Future<bool> createHousehold(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final householdId = await _householdService.createHousehold(name);
      if (householdId != null) {
        await switchHousehold(householdId);
        await loadUserHouseholds();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Không thể tạo nhà mới: $e';
      debugPrint('❌ Error creating household: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Tham gia household bằng invite code
  Future<String?> joinHousehold(String inviteCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _householdService.joinHousehold(inviteCode);
      
      if (result == 'invalid_code') {
        _errorMessage = 'Mã mời không hợp lệ';
        _isLoading = false;
        notifyListeners();
        return 'invalid_code';
      }
      
      if (result == 'already_member') {
        _errorMessage = 'Bạn đã là thành viên của nhà này';
        _isLoading = false;
        notifyListeners();
        return 'already_member';
      }
      
      if (result != null) {
        await switchHousehold(result);
        await loadUserHouseholds();
        _isLoading = false;
        notifyListeners();
        return 'success';
      }
    } catch (e) {
      _errorMessage = 'Không thể tham gia: $e';
      debugPrint('❌ Error joining household: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Chuyển đổi household
  Future<bool> switchHousehold(String householdId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _householdService.switchHousehold(householdId);
      if (success) {
        await loadCurrentHousehold();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Không thể chuyển nhà: $e';
      debugPrint('❌ Error switching household: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Rời khỏi household
  Future<bool> leaveHousehold(String householdId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _householdService.leaveHousehold(householdId);
      if (success) {
        await loadCurrentHousehold();
        await loadUserHouseholds();
        return true;
      } else {
        _errorMessage = 'Chủ nhà không thể rời đi';
      }
    } catch (e) {
      _errorMessage = 'Không thể rời nhà: $e';
      debugPrint('❌ Error leaving household: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Xóa thành viên (chỉ owner)
  Future<bool> removeMember(String memberUid) async {
    if (_currentHousehold == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _householdService.removeMember(
        _currentHousehold!['household_id'],
        memberUid,
      );
      if (success) {
        await loadCurrentHousehold();
        return true;
      } else {
        _errorMessage = 'Không thể xóa thành viên';
      }
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      debugPrint('❌ Error removing member: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Lấy danh sách thành viên
  Future<List<Map<String, dynamic>>> getMembers() async {
    if (_currentHousehold == null) return [];

    try {
      return await _householdService.getHouseholdMembers(
        _currentHousehold!['household_id'],
      );
    } catch (e) {
      debugPrint('❌ Error getting members: $e');
      return [];
    }
  }

  /// Kiểm tra user đã sở hữu household chưa
  Future<bool> checkIfUserOwnsHousehold() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    for (var household in _userHouseholds) {
      if (household['owner_id'] == user.uid) {
        return true;
      }
    }
    return false;
  }

  /// Reset error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
