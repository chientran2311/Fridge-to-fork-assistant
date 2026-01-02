import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _householdId;
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
    _loadShoppingListByDate();
  }

  // ✅ Mới: Load shopping list dựa trên meal_plans + inventory (từ hôm nay trở đi)
  Future<void> _loadShoppingListByDate() async {
    // ✅ Guard: Nếu data đã load, bỏ qua (trừ khi là pull-to-refresh)
    if (_hasLoadedData && _isLoading == false) {
      debugPrint('⏭️  Skipping _loadShoppingListByDate() - data already loaded');
      return;
    }

    try {
      // ✅ Lấy user hiện tại
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        setState(() {
          _isLoading = false;
          _hasLoadedData = true;
        });
        return;
      }
      
      final userId = currentUser.uid;
      
      // ✅ Lấy household_id từ user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists || userDoc.data()?['current_household_id'] == null) {
        debugPrint('❌ User document not found or no current_household_id');
        setState(() {
          _isLoading = false;
          _hasLoadedData = true;
        });
        return;
      }
      
      _householdId = userDoc.data()!['current_household_id'] as String;
      final houseRef = _firestore.collection('households').doc(_householdId!);

      debugPrint('🔄 Loading meal plans + ingredients for household: $_householdId');

      // ✅ Lấy ngày hôm nay (00:00:00) để filter meal plans
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      debugPrint('📅 Today start: $todayStart');

      // 1. Fetch meal_plans từ hôm nay trở đi
      final mealPlansSnapshot = await houseRef
          .collection('meal_plans')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();
      
      debugPrint('📋 Found ${mealPlansSnapshot.docs.length} meal plans from today onwards');

      // 2. Fetch inventory (để check ingredient nào đã có)
      final inventorySnapshot = await houseRef.collection('inventory').get();
      
      // ✅ Create Set of inventory names (lowercase for comparison)
      final inventoryNames = <String>{};
      for (var doc in inventorySnapshot.docs) {
        final name = (doc.data()['name'] ?? '').toString().toLowerCase().trim();
        if (name.isNotEmpty) {
          inventoryNames.add(name);
        }
      }
      debugPrint('📦 Inventory has: ${inventoryNames.length} items');

      // 3. Build shopping list từ meal_plans
      final itemsByDate = <String, List<Map<String, dynamic>>>{};

      for (var mealPlanDoc in mealPlansSnapshot.docs) {
        final mealPlanData = mealPlanDoc.data();
        final date = (mealPlanData['date'] as Timestamp).toDate();
        final dateKey = _formatDateKey(date);
        final recipeId = mealPlanData['local_recipe_id'] ?? '';
        
        if (recipeId.isEmpty) {
          debugPrint('⚠️ Meal plan ${mealPlanDoc.id} has no recipe ID');
          continue;
        }
        
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

        if (ingredients == null || ingredients.isEmpty) {
          debugPrint('⚠️ Recipe $recipeId has no ingredients');
          continue;
        }

        debugPrint('📝 Recipe has ${ingredients.length} ingredients');

        // Với mỗi ingredient trong recipe
        for (var ingData in ingredients) {
          final ingredientName = (ingData['name'] ?? 'Unknown').toString();
          final amount = ingData['amount'] ?? 0;
          final unit = ingData['unit'] ?? '';

          // ✅ Check if ingredient exists in inventory (case-insensitive partial match)
          final nameLower = ingredientName.toLowerCase().trim();
          final inFridge = inventoryNames.any((invName) => 
            invName.contains(nameLower) || nameLower.contains(invName)
          );

          // ✅ Only add to shopping list if NOT in fridge
          if (!inFridge) {
            debugPrint('🛒 Need to buy: $ingredientName ($amount $unit)');
            
            final item = {
              'item_id': '$dateKey-${ingredientName.hashCode}', // ✅ Use hash for unique ID
              'ingredient_name': ingredientName,
              'quantity': amount,
              'unit': unit,
              'category': 'other', // ✅ Default category
              'is_checked': false,
              'date': dateKey,
              'recipe_title': recipeData['title'] ?? 'Unknown Recipe',
            };

            if (!itemsByDate.containsKey(dateKey)) {
              itemsByDate[dateKey] = [];
            }
            
            // ✅ Avoid duplicates by name
            final existingIndex = itemsByDate[dateKey]!.indexWhere(
              (it) => it['ingredient_name'].toString().toLowerCase() == nameLower
            );
            
            if (existingIndex == -1) {
              itemsByDate[dateKey]!.add(item);
            } else {
              // ✅ If already exists, sum quantities
              final existing = itemsByDate[dateKey]![existingIndex];
              existing['quantity'] = (existing['quantity'] ?? 0) + amount;
              debugPrint('   ➕ Updated quantity for $ingredientName to ${existing['quantity']}');
            }
          } else {
            debugPrint('✅ Already in fridge: $ingredientName');
          }
        }
      }

      debugPrint('');
      debugPrint('🎯 ========== SHOPPING LIST SUMMARY ==========');
      debugPrint('   Total dates with missing ingredients: ${itemsByDate.length}');
      for (var entry in itemsByDate.entries) {
        debugPrint('   📅 ${entry.key}: ${entry.value.length} items');
      }
      debugPrint('=============================================');
      debugPrint('');
      
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
    // ✅ Check if dateKey is today
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);
    
    if (dateKey == todayKey) {
      return 'Today';
    }
    
    // ✅ Check if dateKey is tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowKey = _formatDateKey(tomorrow);
    
    if (dateKey == tomorrowKey) {
      return 'Tomorrow';
    }
    
    // ✅ Otherwise, show formatted date
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Date header - left aligned, no box
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 0),
                      child: Text(
                        _formatDisplayDate(dateKey),
                        textAlign: TextAlign.start,
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
                      householdId: _householdId!,
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

