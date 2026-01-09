import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../widgets/plans/tabs/shopping_list_tab/shopping_item.dart';
import '../../../../models/shopping_item.dart';
import '../../../../l10n/app_localizations.dart';

// ✅ Global key to access ShoppingListTab state from outside
final GlobalKey<_ShoppingListTabState> shoppingListGlobalKey = GlobalKey();

// ✅ Public helper function to trigger recalculation (accessible from other files)
Future<void> triggerShoppingListRecalculation() async {
  final state = shoppingListGlobalKey.currentState;
  if (state != null && state.mounted) {
    debugPrint(
        '🔄 Triggering shopping list recalculation from meal plan change');
    state._hasLoadedData = false;
    await state._recalculateShoppingList();
  }
}

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

  // ✅ NEW: Use ShoppingItem model instead of plain Map
  Map<String, List<ShoppingItem>> _itemsByDate = {};

  bool _isLoading = true;
  bool _hasLoadedData = false;

  // ✅ NEW: Track deleted items to prevent auto-adding them back
  Set<String> _deletedItemKeys = {};
  
  // ✅ Filter by category - use ID instead of display text
  String _selectedCategory = 'all';

  @override
  bool get wantKeepAlive => true; // ✅ Keep state when switching tabs

  @override
  void initState() {
    super.initState();
    debugPrint('📱 ShoppingListTab: initState() called');
    _initializeShoppingList();
  }

  // ✅ NEW: Initialize by loading from local storage first, then recalculate
  Future<void> _initializeShoppingList() async {
    await _loadDeletedItems();
    await _recalculateShoppingList();
  }

  // ✅ NEW: Save shopping list to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};

      _itemsByDate.forEach((dateKey, items) {
        data[dateKey] = items.map((item) => item.toJson()).toList();
      });

      await prefs.setString('shopping_list_v2', jsonEncode(data));
      await prefs.setString(
          'shopping_list_last_sync', DateTime.now().toIso8601String());
      debugPrint('💾 Saved shopping list to local storage');
    } catch (e) {
      debugPrint('❌ Error saving to local storage: $e');
    }
  }

  // ✅ NEW: Load shopping list from local storage
  Future<Map<String, List<ShoppingItem>>> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('shopping_list_v2');

      if (dataStr == null || dataStr.isEmpty) {
        debugPrint('📂 No shopping list in local storage');
        return {};
      }

      final Map<String, dynamic> data = jsonDecode(dataStr);
      final Map<String, List<ShoppingItem>> result = {};

      data.forEach((dateKey, itemsList) {
        result[dateKey] = (itemsList as List)
            .map((itemJson) => ShoppingItem.fromJson(itemJson))
            .toList();
      });

      debugPrint(
          '📂 Loaded shopping list from local storage: ${result.length} dates');
      return result;
    } catch (e) {
      debugPrint('❌ Error loading from local storage: $e');
      return {};
    }
  }

  // ✅ NEW: Save deleted items
  Future<void> _saveDeletedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'deleted_shopping_items', jsonEncode(_deletedItemKeys.toList()));
    } catch (e) {
      debugPrint('❌ Error saving deleted items: $e');
    }
  }

  // ✅ NEW: Load deleted items
  Future<void> _loadDeletedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('deleted_shopping_items');
      if (dataStr != null && dataStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(dataStr);
        _deletedItemKeys = list.map((e) => e.toString()).toSet();
        debugPrint('📂 Loaded ${_deletedItemKeys.length} deleted items');
      }
    } catch (e) {
      debugPrint('❌ Error loading deleted items: $e');
    }
  }

  // ✅ NEW: Recalculate shopping list từ meal_plans while preserving user adjustments
  Future<void> _recalculateShoppingList() async {
    // ✅ Guard: Nếu data đã load, bỏ qua (trừ khi là pull-to-refresh)
    if (_hasLoadedData && _isLoading == false) {
      debugPrint(
          '⏭️  Skipping _recalculateShoppingList() - data already loaded');
      return;
    }

    try {
      debugPrint('🔵 ========== SHOPPING LIST RECALCULATION START ==========');

      // Load existing shopping list từ local storage
      final existingItems = await _loadFromLocalStorage();
      debugPrint('📂 Loaded ${existingItems.length} dates from local storage');

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

      debugPrint(
          '🔄 Calculating system quantities for household: $_householdId');

      // ✅ Lấy ngày hôm nay (00:00:00) để filter meal plans
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      // 1. Fetch meal_plans từ hôm nay trở đi
      final mealPlansSnapshot = await houseRef
          .collection('meal_plans')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      debugPrint(
          '📋 Found ${mealPlansSnapshot.docs.length} meal plans from today onwards');

      // 2. Fetch inventory (để check ingredient nào đã có)
      final inventorySnapshot = await houseRef.collection('inventory').get();

      final inventoryNames = <String>{};
      for (var doc in inventorySnapshot.docs) {
        final name = (doc.data()['name'] ?? '').toString().toLowerCase().trim();
        if (name.isNotEmpty) {
          inventoryNames.add(name);
        }
      }
      debugPrint('📦 Inventory has: ${inventoryNames.length} items');

      // 3. Calculate system quantities from meal_plans
      final Map<String, ShoppingItem> calculatedItems = {};

      for (var mealPlanDoc in mealPlansSnapshot.docs) {
        final mealPlanData = mealPlanDoc.data();
        final date = (mealPlanData['date'] as Timestamp).toDate();
        final dateKey = _formatDateKey(date);
        final recipeId = mealPlanData['local_recipe_id'] ?? '';

        if (recipeId.isEmpty) continue;

        // Fetch recipe để lấy ingredients
        final recipeDoc =
            await houseRef.collection('household_recipes').doc(recipeId).get();

        if (!recipeDoc.exists) continue;

        final recipeData = recipeDoc.data() as Map<String, dynamic>;
        final ingredients = recipeData['ingredients'] as List<dynamic>?;

        final mealPlanServings =
            (mealPlanData['servings'] as num?)?.toInt() ?? 1;
        final recipeServings = (recipeData['servings'] as num?)?.toInt() ?? 1;

        if (ingredients == null || ingredients.isEmpty) continue;

        // Process each ingredient
        for (var ingData in ingredients) {
          try {
            final ingredientName = (ingData['name'] ?? 'Unknown').toString();
            final amount = (ingData['amount'] as num?)?.toDouble() ?? 0.0;
            final scaledAmount = (amount * mealPlanServings / recipeServings);
            final unit = ingData['unit'] ?? '';

            // Check if in inventory
            final nameLower = ingredientName.toLowerCase().trim();
            final inFridge = inventoryNames.any((invName) =>
                invName.contains(nameLower) || nameLower.contains(invName));

            // Only add if NOT in fridge
            if (!inFridge) {
              final itemKey =
                  '${dateKey}_${ingredientName.toLowerCase().trim()}';

              // ✅ Skip if user deleted this item
              if (_deletedItemKeys.contains(itemKey)) {
                debugPrint('⏭️  Skipping deleted item: $ingredientName');
                continue;
              }

              if (calculatedItems.containsKey(itemKey)) {
                // Sum quantities for duplicate ingredients
                calculatedItems[itemKey]!.systemQuantity += scaledAmount;
              } else {
                calculatedItems[itemKey] = ShoppingItem(
                  itemId: itemKey,
                  ingredientName: ingredientName,
                  systemQuantity: scaledAmount,
                  userAdjustment: 0.0,
                  finalQuantity: scaledAmount,
                  unit: unit,
                  category: _classifyIngredient(ingredientName),
                  date: dateKey,
                  isChecked: false,
                  isUserEdited: false,
                  recipeTitle: recipeData['title'] ?? 'Unknown Recipe',
                );
              }
            }
          } catch (ingError) {
            debugPrint('❌ Error processing ingredient: $ingError');
          }
        }
      }

      debugPrint('📊 Calculated ${calculatedItems.length} system items');

      // 4. ✅ Merge with existing items (preserve user adjustments)
      final Map<String, List<ShoppingItem>> finalItemsByDate = {};

      calculatedItems.forEach((itemKey, calculatedItem) {
        final dateKey = calculatedItem.date;

        // Check if this item exists in local storage
        bool foundInStorage = false;

        for (var existingDateItems in existingItems.values) {
          for (var existingItem in existingDateItems) {
            if (existingItem.itemId == itemKey) {
              foundInStorage = true;

              if (existingItem.isUserEdited) {
                // ✅ Preserve user adjustment
                debugPrint(
                    '🔧 Preserving adjustment for ${existingItem.ingredientName}');
                debugPrint(
                    '   Old system: ${existingItem.systemQuantity}, New system: ${calculatedItem.systemQuantity}');
                debugPrint(
                    '   User adjustment: ${existingItem.userAdjustment}');

                existingItem
                    .updateSystemQuantity(calculatedItem.systemQuantity);
                calculatedItem.systemQuantity = existingItem.systemQuantity;
                calculatedItem.userAdjustment = existingItem.userAdjustment;
                calculatedItem.finalQuantity = existingItem.finalQuantity;
                calculatedItem.isUserEdited = true;
                calculatedItem.isChecked = existingItem.isChecked;
              } else {
                // No user edit, just update system quantity
                calculatedItem.isChecked = existingItem.isChecked;
              }
              break;
            }
          }
          if (foundInStorage) break;
        }

        // Add to final list
        if (!finalItemsByDate.containsKey(dateKey)) {
          finalItemsByDate[dateKey] = [];
        }
        finalItemsByDate[dateKey]!.add(calculatedItem);
      });

      debugPrint('');
      debugPrint('🎯 ========== SHOPPING LIST SUMMARY ==========');
      debugPrint('   Total dates: ${finalItemsByDate.length}');
      for (var entry in finalItemsByDate.entries) {
        debugPrint('   📅 ${entry.key}: ${entry.value.length} items');
      }
      debugPrint('=============================================');
      debugPrint('🟢 ========== SHOPPING LIST RECALCULATION END ==========');

      setState(() {
        _itemsByDate = finalItemsByDate;
        _isLoading = false;
        _hasLoadedData = true;
      });

      // Save to local storage
      await _saveToLocalStorage();
    } catch (e, stackTrace) {
      debugPrint('❌ ========== ERROR IN SHOPPING LIST ==========');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('=============================================');
      setState(() {
        _isLoading = false;
        _hasLoadedData = true;
      });
    }
  }

  String _formatDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  // ✅ Classify ingredient into category based on name
  String _classifyIngredient(String ingredientName) {
    final nameLower = ingredientName.toLowerCase();

    // Protein/Meat
    if (nameLower.contains('chicken') ||
        nameLower.contains('beef') ||
        nameLower.contains('pork') ||
        nameLower.contains('fish') ||
        nameLower.contains('meat') ||
        nameLower.contains('bacon') ||
        nameLower.contains('sausage') ||
        nameLower.contains('ham') ||
        nameLower.contains('turkey') ||
        nameLower.contains('duck')) {
      return 'protein';
    }

    // Dairy
    if (nameLower.contains('milk') ||
        nameLower.contains('cheese') ||
        nameLower.contains('butter') ||
        nameLower.contains('cream') ||
        nameLower.contains('yogurt') ||
        nameLower.contains('egg')) {
      return 'dairy';
    }

    // Vegetables
    if (nameLower.contains('tomato') ||
        nameLower.contains('onion') ||
        nameLower.contains('carrot') ||
        nameLower.contains('potato') ||
        nameLower.contains('lettuce') ||
        nameLower.contains('spinach') ||
        nameLower.contains('pepper') ||
        nameLower.contains('broccoli') ||
        nameLower.contains('cabbage') ||
        nameLower.contains('celery')) {
      return 'vegetables';
    }

    // Fruits
    if (nameLower.contains('apple') ||
        nameLower.contains('banana') ||
        nameLower.contains('orange') ||
        nameLower.contains('lemon') ||
        nameLower.contains('lime') ||
        nameLower.contains('berry') ||
        nameLower.contains('grape') ||
        nameLower.contains('peach')) {
      return 'fruits';
    }

    // Grains/Carbs
    if (nameLower.contains('bread') ||
        nameLower.contains('rice') ||
        nameLower.contains('pasta') ||
        nameLower.contains('flour') ||
        nameLower.contains('cereal') ||
        nameLower.contains('oat') ||
        nameLower.contains('bun')) {
      return 'grains';
    }

    // Condiments/Sauces
    if (nameLower.contains('sauce') ||
        nameLower.contains('oil') ||
        nameLower.contains('vinegar') ||
        nameLower.contains('salt') ||
        nameLower.contains('pepper') ||
        nameLower.contains('spice')) {
      return 'condiments';
    }

    return 'other';
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
    // ✅ Update item in memory and save to local storage
    for (var dateKey in _itemsByDate.keys) {
      final index =
          _itemsByDate[dateKey]!.indexWhere((item) => item.itemId == itemId);
      if (index != -1) {
        setState(() {
          _itemsByDate[dateKey]![index].isChecked = newValue;
        });
        await _saveToLocalStorage();
        return;
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    // ✅ Add to deleted items set and save
    _deletedItemKeys.add(itemId);
    await _saveDeletedItems();

    // ✅ Delete from local state
    for (var dateKey in _itemsByDate.keys.toList()) {
      _itemsByDate[dateKey]!.removeWhere((item) => item.itemId == itemId);
      if (_itemsByDate[dateKey]!.isEmpty) {
        _itemsByDate.remove(dateKey);
      }
    }

    setState(() {});
    await _saveToLocalStorage();
  }

  Future<void> _onQuantityChange(String itemId, double newQuantity) async {
    // ✅ User edited quantity - track adjustment
    for (var dateKey in _itemsByDate.keys) {
      final index =
          _itemsByDate[dateKey]!.indexWhere((item) => item.itemId == itemId);
      if (index != -1) {
        setState(() {
          _itemsByDate[dateKey]![index].updateUserQuantity(newQuantity);
        });
        await _saveToLocalStorage();
        debugPrint(
            '✏️ User edited ${_itemsByDate[dateKey]![index].ingredientName}:');
        debugPrint(
            '   System: ${_itemsByDate[dateKey]![index].systemQuantity}');
        debugPrint(
            '   Adjustment: ${_itemsByDate[dateKey]![index].userAdjustment}');
        debugPrint('   Final: ${_itemsByDate[dateKey]![index].finalQuantity}');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Call super for AutomaticKeepAliveClientMixin

    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dates = _itemsByDate.keys.toList()..sort(); // ✅ Sort by date

    return Stack(
      children: [
        // Scrollable content
        RefreshIndicator(
          onRefresh: () async {
            // ✅ Reset flag when user pulls to refresh and recalculate
            _hasLoadedData = false;
            await _recalculateShoppingList();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. Category Filter Buttons
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryButton('all', AppLocalizations.of(context)?.allItems ?? 'All Items'),
                        const SizedBox(width: 8),
                        _buildCategoryButton('produce', AppLocalizations.of(context)?.produce ?? 'Produce'),
                        const SizedBox(width: 8),
                        _buildCategoryButton('dairy', AppLocalizations.of(context)?.dairy ?? 'Dairy'),
                        const SizedBox(width: 8),
                        _buildCategoryButton('pantry', AppLocalizations.of(context)?.pantry ?? 'Pantry'),
                        const SizedBox(width: 8),
                        _buildCategoryButton('other', AppLocalizations.of(context)?.other ?? 'Other'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Shopping Items by Date
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shopping Items by Date
                if (_itemsByDate.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                          AppLocalizations.of(context)?.noItemsNeeded ??
                              'No items needed for upcoming meals\n\nPull to refresh',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...dates.map((dateKey) {
                    final items = _itemsByDate[dateKey]!;
                    // ✅ Filter items by selected category
                    final filteredItems = _selectedCategory == 'all'
                        ? items
                        : items.where((item) {
                            final itemCategory = item.category.toLowerCase();
                            final selectedCat = _selectedCategory.toLowerCase();
                            return itemCategory == selectedCat;
                          }).toList();
                    
                    // ✅ Skip this date if no items match the filter
                    if (filteredItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Date header - left aligned, no box
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8, bottom: 12, left: 0),
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
                        ...filteredItems
                            .map((item) => EditableShoppingItem(
                                  itemId: item.itemId,
                                  title: item.ingredientName,
                                  category: item.category,
                                  quantity:
                                      item.finalQuantity, // ✅ Show final quantity
                                  unit: item.unit,
                                  isChecked: item.isChecked,
                                  onDelete: () => _deleteItem(item.itemId),
                                  onToggleCheck: (newValue) =>
                                      _toggleItem(item.itemId, newValue),
                                  onQuantityChange: (newQty) =>
                                      _onQuantityChange(item.itemId, newQty),
                                  householdId: _householdId!,
                                ))
                            .toList(),

                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),

                      // Extra space at bottom
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // ✅ Floating Action Button to add custom item (Fridge-style)
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: 'shopping_list_fab',
            onPressed: _showAddItemDialog,
            shape: const CircleBorder(),
            backgroundColor: const Color.fromARGB(255, 36, 75, 45),
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ✅ Build category filter button
  Widget _buildCategoryButton(String categoryId, String categoryLabel) {
    final isSelected = _selectedCategory == categoryId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF214130) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF214130) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          categoryLabel,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ✅ Show bottom sheet to add custom item (Fridge-style UI)
  void _showAddItemDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => _AddItemBottomSheet(
        onAdd: _addCustomItem,
      ),
    );
  }

  // ✅ Add custom item to shopping list
  Future<void> _addCustomItem(
      String name, double quantity, String unit, String category) async {
    final today = DateTime.now();
    final dateKey = _formatDateKey(today);
    final itemKey = '${dateKey}_${name.toLowerCase().trim()}_custom';

    final newItem = ShoppingItem(
      itemId: itemKey,
      ingredientName: name,
      systemQuantity: 0.0, // Custom items have no system quantity
      userAdjustment: quantity, // All quantity is user adjustment
      finalQuantity: quantity,
      unit: unit,
      category: category,
      date: dateKey,
      isChecked: false,
      isUserEdited: true,
      recipeTitle: 'Manual entry',
    );

    setState(() {
      if (!_itemsByDate.containsKey(dateKey)) {
        _itemsByDate[dateKey] = [];
      }
      _itemsByDate[dateKey]!.add(newItem);
    });

    await _saveToLocalStorage();

    if (mounted) {
      final s = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s?.addedToShoppingList(name) ??
              'Added $name to shopping list'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ✅ Fridge-style bottom sheet for adding custom items
class _AddItemBottomSheet extends StatefulWidget {
  final Function(String name, double quantity, String unit, String category)
      onAdd;

  const _AddItemBottomSheet({required this.onAdd});

  @override
  State<_AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<_AddItemBottomSheet> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUnit = 'g';
  String _selectedCategory = 'other';

  final List<String> _units = ['g', 'kg', 'ml', 'l', 'cup', 'tbsp', 'tsp', 'piece'];
  
  List<Map<String, String>> _getCategories(BuildContext context) {
    final s = AppLocalizations.of(context);
    return [
      {'id': 'protein', 'label': s?.protein ?? 'Protein'},
      {'id': 'dairy', 'label': s?.dairy ?? 'Dairy'},
      {'id': 'vegetables', 'label': s?.vegetables ?? 'Vegetables'},
      {'id': 'fruits', 'label': s?.fruits ?? 'Fruits'},
      {'id': 'grains', 'label': s?.grains ?? 'Grains'},
      {'id': 'condiments', 'label': s?.condiments ?? 'Condiments'},
      {'id': 'other', 'label': s?.other ?? 'Other'},
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final quantityStr = _quantityController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter item name')),
      );
      return;
    }

    if (quantityStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }

    final quantity = double.tryParse(quantityStr);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    widget.onAdd(name, quantity, _selectedUnit, _selectedCategory);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ✅ Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s?.addCustomItem ?? 'Add Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF214130),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Drag handle (visual indicator)
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: s?.itemName ?? 'Item Name',
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Quantity and Unit row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: s?.quantity ?? 'Quantity',
                      filled: true,
                      fillColor: const Color(0xFFF6F8F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        items: _units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedUnit = value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Category selector
            Text(
              s?.category ?? 'Category',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF214130),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getCategories(context).map((category) {
                final isSelected = _selectedCategory == category['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category['id']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE6F4EA)
                          : const Color(0xFFF6F8F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF214130)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      category['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF214130)
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ✅ Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF214130),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  s?.addItemButton ?? 'Add Item',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}