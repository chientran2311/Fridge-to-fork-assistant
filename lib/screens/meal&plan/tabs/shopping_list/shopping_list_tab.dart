import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../widgets/plans/tabs/shopping_list_tab/section_header.dart';
import '../../../../widgets/plans/tabs/shopping_list_tab/shopping_filter.dart';
import '../../../../widgets/plans/tabs/shopping_list_tab/shopping_item.dart';


class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab>
    with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _householdId;
  Map<String, List<Map<String, dynamic>>> _itemsByDate = {}; // ✅ Changed: group by date
  bool _isLoading = true;
  String _selectedCategory = 'all';
  bool _hasLoadedData = false; // ✅ Track if data already loaded

  @override
  bool get wantKeepAlive => true; // ✅ Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    debugPrint('📱 ShoppingListTab: initState() called');
    _householdId = 'house_01';
    _loadShoppingListByDate();
  }

  // ✅ Mới: Load shopping list dựa trên meal_plans + inventory
  Future<void> _loadShoppingListByDate() async {
    // ✅ Guard: Nếu data đã load, bỏ qua (trừ khi là pull-to-refresh)
    if (_hasLoadedData && _isLoading == false) {
      debugPrint('⏭️  Skipping _loadShoppingListByDate() - data already loaded');
      return;
    }

    try {
      const householdId = 'house_01';
      _householdId = householdId;
      final houseRef = _firestore.collection('households').doc(_householdId);

      debugPrint('🔄 Loading meal plans + ingredients...');

      // 1. Fetch tất cả meal_plans
      final mealPlansSnapshot = await houseRef.collection('meal_plans').get();
      debugPrint('📋 Found ${mealPlansSnapshot.docs.length} meal plans');

      // 2. Fetch inventory (để check stock)
      final inventorySnapshot = await houseRef.collection('inventory').get();
      final inventoryMap = <String, int>{}; // ingredient_id -> quantity
      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        inventoryMap[data['ingredient_id']] = data['quantity'] ?? 0;
      }
      debugPrint('📦 Inventory: ${inventoryMap.length} items');

      // 3. Build shopping list từ meal_plans
      final itemsByDate = <String, List<Map<String, dynamic>>>{};

      for (var mealPlanDoc in mealPlansSnapshot.docs) {
        final mealPlanData = mealPlanDoc.data();
        final date = (mealPlanData['date'] as Timestamp).toDate();
        final dateKey = _formatDateKey(date);
        final recipeId = mealPlanData['local_recipe_id'];
        
        debugPrint('🍽️ Meal plan on $dateKey: Recipe $recipeId');

        // Fetch recipe để lấy ingredients
        final recipeDoc = await houseRef
            .collection('household_recipes')
            .doc(recipeId)
            .get();

        if (!recipeDoc.exists) {
          debugPrint('⚠️ Recipe $recipeId not found');
          continue;
        }

        final recipeData = recipeDoc.data() as Map<String, dynamic>;
        final ingredients = recipeData['ingredients'] as List<dynamic>?;

        if (ingredients == null) continue;

        // Untuk mỗi ingredient trong recipe
        for (var ingData in ingredients) {
          final ingredientId = ingData['ingredient_id'];
          final requiredQty = (ingData['amount'] as num).toInt();

          // Check inventory
          final availableQty = inventoryMap[ingredientId] ?? 0;
          final neededQty = requiredQty - availableQty;

          if (neededQty > 0) {
            // Fetch ingredient details
            final ingredientDoc = await _firestore
                .collection('ingredients')
                .doc(ingredientId)
                .get();

            final ingredientData = ingredientDoc.data();
            final ingredientName = ingredientData?['name'] ?? 'Unknown';
            final category = ingredientData?['category'] ?? 'other';

            final item = {
              'item_id': '$dateKey-$ingredientId',
              'ingredient_name': ingredientName,
              'ingredient_id': ingredientId,
              'quantity': neededQty,
              'unit': ingData['unit'] ?? 'pcs',
              'category': category,
              'is_checked': false,
            };

            if (!itemsByDate.containsKey(dateKey)) {
              itemsByDate[dateKey] = [];
            }
            
            // Avoid duplicates
            if (!itemsByDate[dateKey]!.any((it) => it['ingredient_id'] == ingredientId)) {
              itemsByDate[dateKey]!.add(item);
            }
          }
        }
      }

      debugPrint('✅ Shopping list by date: ${itemsByDate.keys.toList()}');
      setState(() {
        _itemsByDate = itemsByDate;
        _isLoading = false;
        _hasLoadedData = true; // ✅ Mark data as loaded
      });
    } catch (e) {
      debugPrint('❌ Error loading shopping list: $e');
      setState(() {
        _isLoading = false;
        _hasLoadedData = true; // ✅ Mark as attempted load
      });
    }
  }

  String _formatDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  String _formatDisplayDate(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length == 3) {
      return 'Day ${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return dateKey;
  }

  Future<void> _toggleItem(String itemId, bool newValue) async {
    // ✅ Update local state only
    for (var dateKey in _itemsByDate.keys) {
      final index =
          _itemsByDate[dateKey]!.indexWhere((item) => item['item_id'] == itemId);
      if (index != -1) {
        setState(() {
          _itemsByDate[dateKey]![index]['is_checked'] = newValue;
        });
        return;
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    // ✅ Delete from local state only
    for (var dateKey in _itemsByDate.keys.toList()) {
      _itemsByDate[dateKey]!.removeWhere((item) => item['item_id'] == itemId);
      if (_itemsByDate[dateKey]!.isEmpty) {
        _itemsByDate.remove(dateKey);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Call super for AutomaticKeepAliveClientMixin
    
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dates = _itemsByDate.keys.toList()..sort(); // ✅ Sort by date

    return RefreshIndicator(
      onRefresh: () async {
        // ✅ Reset flag when user pulls to refresh
        _hasLoadedData = false;
        await _loadShoppingListByDate();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 16,
          vertical: 16,
        ),
        physics: const AlwaysScrollableScrollPhysics(), // ✅ Allow refresh even when empty
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
            ),
            
            

            // 2. Shopping Items by Date
            if (_itemsByDate.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('No items needed for upcoming meals\n\nPull to refresh', 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...dates.map((dateKey) {
                final items = _itemsByDate[dateKey]!;
                return Column(
                  children: [
                    // ✅ Date header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF214130).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDisplayDate(dateKey),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF214130),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // ✅ Items for this date
                    ...items.map((item) => EditableShoppingItem(
                      itemId: item['item_id'],
                      title: item['ingredient_name'],
                      category: item['category'],
                      quantity: item['quantity'],
                      unit: item['unit'],
                      isChecked: item['is_checked'] as bool,
                      onDelete: () => _deleteItem(item['item_id']),
                      onToggleCheck: (newValue) => _toggleItem(item['item_id'], newValue),
                      onQuantityChange: (newQty) {
                        setState(() {
                          item['quantity'] = newQty;
                        });
                      },
                      householdId: _householdId,
                    )).toList(),
                    
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),

            // Extra space at bottom
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

