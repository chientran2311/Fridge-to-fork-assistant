import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//
// ---------------- SHOPPING LIST ----------------
//

class ShoppingList extends StatefulWidget {
  final VoidCallback? onViewAllTap;

  const ShoppingList({super.key, this.onViewAllTap});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _householdId;
  List<Map<String, dynamic>> _shoppingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    try {
      // ✅ Lấy user hiện tại
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      
      final userId = currentUser.uid;
      
      // ✅ Lấy household_id từ user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists || userDoc.data()?['current_household_id'] == null) {
        debugPrint('❌ User document not found or no current_household_id');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      
      _householdId = userDoc.data()!['current_household_id'] as String;

      debugPrint('📦 Loading shopping list for household: $_householdId');

      // Fetch shopping list items
      final snapshot = await _firestore
          .collection('households')
          .doc(_householdId!)
          .collection('shopping_list')
          .get();

      debugPrint('📦 Found ${snapshot.docs.length} shopping items');

      // Map dữ liệu từ Firestore
      final items = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final itemName = data['name'];
          
          if (itemName == null || itemName.toString().isEmpty) {
            debugPrint('⚠️ Skipping item ${doc.id}: name is null or empty');
            continue;
          }
          
          debugPrint('📝 Item: $itemName | Qty: ${data['quantity']} ${data['unit']}');

          items.add({
            'item_id': doc.id,
            'ingredient_name': itemName,
            'quantity': data['quantity'] ?? 0,
            'unit': data['unit'] ?? '',
            'category': 'Shopping', // ✅ Default category vì shopping_list không có category
            'is_checked': data['is_checked'] ?? false,
            'note': data['note'] ?? '',
          });
        } catch (e) {
          debugPrint('⚠️ Error parsing shopping item ${doc.id}: $e');
        }
      }

      // ✅ Check if widget is still mounted before setState
      if (mounted) {
        setState(() {
          _shoppingItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading shopping list: $e');
      // ✅ Check if widget is still mounted before setState
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleItem(String itemId, bool newValue) async {
    try {
      if (_householdId == null) {
        debugPrint('❌ Cannot toggle item: householdId is null');
        return;
      }
      
      await _firestore
          .collection('households')
          .doc(_householdId!)
          .collection('shopping_list')
          .doc(itemId)
          .update({'is_checked': newValue});

      // Update local state
      final index = _shoppingItems.indexWhere((item) => item['item_id'] == itemId);
      if (index != -1 && mounted) { // ✅ Check mounted
        setState(() {
          _shoppingItems[index]['is_checked'] = newValue;
        });
      }
    } catch (e) {
      debugPrint('❌ Error updating item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today Shopping List",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: widget.onViewAllTap,
              child: const Text("View All", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_shoppingItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('No shopping items', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ..._shoppingItems.take(5).map((item) {
            return ListTile(
              leading: Checkbox(
                value: item['is_checked'] as bool,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _toggleItem(item['item_id'], newValue);
                  }
                },
              ),
              title: Text(item['ingredient_name']),
              subtitle: Text("${item['category']} • ${item['quantity']}${item['unit']}"),
            );
          }).toList(),
      ],
    );
  }
}