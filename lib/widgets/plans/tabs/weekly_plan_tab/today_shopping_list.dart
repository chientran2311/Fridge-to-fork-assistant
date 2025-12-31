import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late String _householdId;
  List<Map<String, dynamic>> _shoppingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    try {
      // ✅ Hardcode household ID từ seeder
      const householdId = 'house_01';
      _householdId = householdId;

      // Fetch shopping list items
      final snapshot = await _firestore
          .collection('households')
          .doc(_householdId)
          .collection('shopping_list')
          .get();

      debugPrint('📦 Found ${snapshot.docs.length} shopping items');

      // Map dữ liệu từ Firestore
      final items = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        debugPrint('📝 Item: ${data['ingredient_id']} | Qty: ${data['quantity']} ${data['unit']}');

        // Fetch ingredient name từ ingredients collection
        final ingredientDoc = await _firestore
            .collection('ingredients')
            .doc(data['ingredient_id'])
            .get();

        final ingredientName = ingredientDoc.data()?['name'] ?? 'Unknown';
        final category = ingredientDoc.data()?['category'] ?? 'Other';

        items.add({
          'item_id': doc.id,
          'ingredient_name': ingredientName,
          'quantity': data['quantity'],
          'unit': data['unit'],
          'category': category,
          'is_checked': data['is_checked'] ?? false,
        });
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
      await _firestore
          .collection('households')
          .doc(_householdId)
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