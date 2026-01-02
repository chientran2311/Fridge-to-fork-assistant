import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class HouseholdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize household for current user if not exists
  Future<void> initializeUserHousehold() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ No user logged in');
      return;
    }

    final householdId = 'house_${user.uid}';
    final householdRef = _firestore.collection('households').doc(householdId);

    // Check if household already exists
    final householdDoc = await householdRef.get();
    if (householdDoc.exists) {
      debugPrint('✅ Household already exists: $householdId');
      return;
    }

    // Create new household for user
    try {
      await householdRef.set({
        'household_id': householdId,
        'name': '${user.email ?? "User"}\'s Kitchen',
        'owner_id': user.uid,
        'members': [user.uid],
        'created_at': FieldValue.serverTimestamp(),
        'invite_code': _generateInviteCode(),
      });
      
      // Update user's current_household_id
      await _updateUserCurrentHousehold(user.uid, householdId);
      
      debugPrint('✅ Created household for user: ${user.email}');
    } catch (e) {
      debugPrint('❌ Error creating household: $e');
    }
  }

  /// Generate random invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join('-');
  }

  /// Get household info for current user
  Future<Map<String, dynamic>?> getCurrentUserHousehold() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Get user's current household ID from user document
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final currentHouseholdId = userDoc.data()?['current_household_id'];
    
    if (currentHouseholdId == null) {
      // Fallback to default household
      final householdId = 'house_${user.uid}';
      final doc = await _firestore.collection('households').doc(householdId).get();
      return doc.exists ? doc.data() : null;
    }
    
    final doc = await _firestore.collection('households').doc(currentHouseholdId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  /// Get all households the user is a member of
  Future<List<Map<String, dynamic>>> getUserHouseholds() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('households')
          .where('members', arrayContains: user.uid)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user households: $e');
      return [];
    }
  }

  /// Create a new household
  Future<String?> createHousehold(String householdName) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ No user logged in');
      return null;
    }

    try {
      final householdRef = _firestore.collection('households').doc();
      final inviteCode = _generateInviteCode();

      await householdRef.set({
        'household_id': householdRef.id,
        'name': householdName,
        'owner_id': user.uid,
        'members': [user.uid],
        'created_at': FieldValue.serverTimestamp(),
        'invite_code': inviteCode,
      });

      debugPrint('✅ Created new household: ${householdRef.id}');
      return householdRef.id;
    } catch (e) {
      debugPrint('❌ Error creating household: $e');
      return null;
    }
  }

  /// Join a household using invite code
  Future<String?> joinHousehold(String inviteCode) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ No user logged in');
      return null;
    }

    try {
      // Find household with this invite code
      final querySnapshot = await _firestore
          .collection('households')
          .where('invite_code', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('❌ No household found with invite code: $inviteCode');
        return 'invalid_code';
      }

      final householdDoc = querySnapshot.docs.first;
      final householdData = householdDoc.data();
      final members = List<String>.from(householdData['members'] ?? []);

      // Check if user is already a member
      if (members.contains(user.uid)) {
        debugPrint('⚠️ User already a member of this household');
        return 'already_member';
      }

      // Add user to household members
      await householdDoc.reference.update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      debugPrint('✅ Joined household: ${householdDoc.id}');
      return householdDoc.id;
    } catch (e) {
      debugPrint('❌ Error joining household: $e');
      return null;
    }
  }

  /// Switch to a different household
  Future<bool> switchHousehold(String householdId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Verify user is a member of this household
      final householdDoc = await _firestore
          .collection('households')
          .doc(householdId)
          .get();

      if (!householdDoc.exists) {
        debugPrint('❌ Household does not exist');
        return false;
      }

      final members = List<String>.from(householdDoc.data()?['members'] ?? []);
      if (!members.contains(user.uid)) {
        debugPrint('❌ User is not a member of this household');
        return false;
      }

      // Update user's current household
      await _updateUserCurrentHousehold(user.uid, householdId);
      debugPrint('✅ Switched to household: $householdId');
      return true;
    } catch (e) {
      debugPrint('❌ Error switching household: $e');
      return false;
    }
  }

  /// Leave a household
  Future<bool> leaveHousehold(String householdId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final householdDoc = await _firestore
          .collection('households')
          .doc(householdId)
          .get();

      if (!householdDoc.exists) return false;

      final householdData = householdDoc.data();
      final ownerId = householdData?['owner_id'];

      // If user is the owner, they cannot leave (must delete or transfer ownership)
      if (ownerId == user.uid) {
        debugPrint('❌ Owner cannot leave household');
        return false;
      }

      // Remove user from members
      await householdDoc.reference.update({
        'members': FieldValue.arrayRemove([user.uid]),
      });

      // Switch to user's default household
      final defaultHouseholdId = 'house_${user.uid}';
      await _updateUserCurrentHousehold(user.uid, defaultHouseholdId);

      debugPrint('✅ Left household: $householdId');
      return true;
    } catch (e) {
      debugPrint('❌ Error leaving household: $e');
      return false;
    }
  }

  /// Regenerate invite code for a household
  Future<String?> regenerateInviteCode(String householdId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final householdDoc = await _firestore
          .collection('households')
          .doc(householdId)
          .get();

      if (!householdDoc.exists) return null;

      final ownerId = householdDoc.data()?['owner_id'];
      if (ownerId != user.uid) {
        debugPrint('❌ Only owner can regenerate invite code');
        return null;
      }

      final newCode = _generateInviteCode();
      await householdDoc.reference.update({'invite_code': newCode});
      
      debugPrint('✅ Regenerated invite code: $newCode');
      return newCode;
    } catch (e) {
      debugPrint('❌ Error regenerating invite code: $e');
      return null;
    }
  }

  /// Update user's current household ID
  Future<void> _updateUserCurrentHousehold(String userId, String householdId) async {
    await _firestore.collection('users').doc(userId).set({
      'current_household_id': householdId,
    }, SetOptions(merge: true));
  }

  /// Get current user's active household ID
  Future<String?> getCurrentHouseholdId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['current_household_id'] ?? 'house_${user.uid}';
  }
}
