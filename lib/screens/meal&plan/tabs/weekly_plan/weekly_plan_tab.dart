import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../widgets/plans/tabs/weekly_plan_tab/meal_card.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/today_shopping_list.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/day_item.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/plan_dinner_card.dart';
import '../../../../utils/firebase_seeder.dart';

class WeeklyPlanContent extends StatefulWidget {
  final Function(int)? onTabChange;

  const WeeklyPlanContent({super.key, this.onTabChange});

  @override
  State<WeeklyPlanContent> createState() => _WeeklyPlanContentState();
}

class _WeeklyPlanContentState extends State<WeeklyPlanContent>
    with AutomaticKeepAliveClientMixin {
  late List<DateTime> weekDays;
  late int selectedDayIndex;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _householdId;
  Map<String, List<Map<String, dynamic>>> _mealPlansByDate = {};
  bool _isLoading = true;
  bool _hasLoadedData = false; // ✅ Track if data already loaded
  List<Map<String, dynamic>> _availableRecipes = []; // ✅ Store available recipes

  @override
  bool get wantKeepAlive => true; // ✅ Keep state when switching tabs

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    // Monday of current week
    final monday =
        today.subtract(Duration(days: today.weekday - DateTime.monday));

    // Generate 7 days (Mon → Sun)
    weekDays = List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );

    // Select today automatically
    selectedDayIndex = weekDays.indexWhere(
      (d) =>
          d.year == today.year &&
          d.month == today.month &&
          d.day == today.day,
    );

    if (selectedDayIndex == -1) {
      selectedDayIndex = 0;
    }

    // ✅ Fetch household ID and meal plans + recipes
    _initializeData();
  }

  // ✅ Load both meal plans and recipes - ensures recipes are ready before showing UI
  Future<void> _initializeData() async {
    try {
      debugPrint('🚀 _initializeData() START');
      debugPrint('   Step 1: Loading recipes...');
      await _loadAvailableRecipes(); // Load recipes FIRST (needs to complete)
      debugPrint('   ✅ Recipes loaded: ${_availableRecipes.length} recipes');
      
      debugPrint('   Step 2: Loading meal plans...');
      await _loadMealPlans();         // Then load meal plans
      debugPrint('🚀 _initializeData() COMPLETE');
    } catch (e) {
      debugPrint('❌ Error during initialization: $e');
    }
  }

  // Helper function để format date key một cách nhất quán (YYYY-MM-DD)
  String _formatDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  Future<void> _loadMealPlans() async {
    // ✅ Guard: During initialization, only load once
    if (_hasLoadedData && mounted) {
      debugPrint('⏭️  Skipping _loadMealPlans() - data already loaded');
      return;
    }

    try {
      debugPrint('🔄 Loading meal plans...');
      
      // ✅ Hardcode lấy dữ liệu từ seeder user (user_seed_01)
      const userId = 'user_01';
      const householdId = 'house_01';
      
      _householdId = householdId;

      debugPrint('🏠 Household ID (Demo): $_householdId');
      debugPrint('👤 User ID (Demo): $userId');

      // Fetch ALL meal plans từ household
      final mealPlansSnapshot = await _firestore
          .collection('households')
          .doc(_householdId)
          .collection('meal_plans')
          .get();

      debugPrint('');
      debugPrint('🔍 ========== FETCH DEBUG ==========');
      debugPrint('   Collection Path: households/$_householdId/meal_plans');
      debugPrint('   Snapshot Docs Count: ${mealPlansSnapshot.docs.length}');
      debugPrint('   Snapshot Empty: ${mealPlansSnapshot.docs.isEmpty}');
      if (mealPlansSnapshot.docs.isNotEmpty) {
        debugPrint('   First Doc: ${mealPlansSnapshot.docs.first.id}');
        debugPrint('   First Doc Data: ${mealPlansSnapshot.docs.first.data()}');
      }
      debugPrint('=====================================');
      debugPrint('');

      debugPrint('📋 Found ${mealPlansSnapshot.docs.length} meal plans');

      // Group meal plans by date
      _mealPlansByDate.clear();
      for (var doc in mealPlansSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();
        
        debugPrint('');
        debugPrint('📅 ========== MEAL PLAN DEBUG ==========');
        debugPrint('   Doc ID: ${doc.id}');
        debugPrint('   Raw Timestamp: $timestamp');
        debugPrint('   DateTime (toDate): $date');
        debugPrint('   DateTime ISO String: ${date.toIso8601String()}');
        final dateKey = _formatDateKey(date);
        debugPrint('   Final DateKey: $dateKey');
        debugPrint('   Meal Type: ${data['meal_type']}');
        debugPrint('========================================');
        debugPrint('');
        
        if (_mealPlansByDate[dateKey] == null) {
          _mealPlansByDate[dateKey] = [];
        }
        _mealPlansByDate[dateKey]!.add(data);
      }

      // Debug: in ra week days
      debugPrint('');
      debugPrint('📋 ========== WEEK DAYS DEBUG ==========');
      for (int i = 0; i < weekDays.length; i++) {
        final d = weekDays[i];
        final key = _formatDateKey(d);
        final hasMeal = _mealPlansByDate.containsKey(key);
        debugPrint('   [$i] ${d.toIso8601String()} => Key: $key | Has Meal: $hasMeal');
      }
      debugPrint('========================================');
      debugPrint('');

      debugPrint('✅ Grouped meal plans: ${_mealPlansByDate.keys.toList()}');
      setState(() {
        _isLoading = false;
        _hasLoadedData = true; // ✅ Mark data as loaded
      });
    } catch (e) {
      debugPrint('❌ Error loading meal plans: $e');
      setState(() {
        _isLoading = false;
        _hasLoadedData = true; // ✅ Mark as attempted load
      });
    }
  }

  bool _hasMealPlan(DateTime date) {
    final dateKey = _formatDateKey(date);
    return _mealPlansByDate.containsKey(dateKey) && _mealPlansByDate[dateKey]!.isNotEmpty;
  }

  // ✅ Add meal plan to Firebase when recipe is dropped on a day
  Future<void> _addMealPlan(DateTime date, String recipeId, String mealType, {int servings = 1}) async {
    try {
      const householdId = 'house_01';
      const userId = 'user_01';
      
      final newDocRef = _firestore
          .collection('households')
          .doc(householdId)
          .collection('meal_plans')
          .doc();

      await newDocRef.set({
        'plan_id': newDocRef.id,
        'date': Timestamp.fromDate(date),
        'meal_type': mealType,
        'local_recipe_id': recipeId,
        'servings': servings,
        'created_at': Timestamp.now(),
        'household_id': householdId,
        'is_cooked': false,
        'planned_by_uid': userId,
      });

      // ✅ Reload meal plans to show the new addition
      _loadMealPlans();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Đã thêm vào kế hoạch'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF214130),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error adding meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Lỗi khi thêm công thức'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getMealPlansForDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    return _mealPlansByDate[dateKey] ?? [];
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

  // ✅ Format week date range (e.g., "THÁNG 12 (29/12/2025 - 4/1/2026)")
  String _getWeekRangeText() {
    final firstDay = weekDays.first;
    final lastDay = weekDays.last;
    
    final monthNames = [
      'THÁNG 1', 'THÁNG 2', 'THÁNG 3', 'THÁNG 4', 'THÁNG 5', 'THÁNG 6',
      'THÁNG 7', 'THÁNG 8', 'THÁNG 9', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12'
    ];
    
    final startMonth = monthNames[firstDay.month - 1];
    final startDate = '${firstDay.day}/${firstDay.month}/${firstDay.year}';
    final endDate = '${lastDay.day}/${lastDay.month}/${lastDay.year}';
    
    return '$startMonth ($startDate - $endDate)';
  }

  // ✅ Navigate to previous week
  void _previousWeek() {
    setState(() {
      final monday = weekDays.first.subtract(const Duration(days: 7));
      weekDays = List.generate(
        7,
        (index) => monday.add(Duration(days: index)),
      );
      // Reset selected day to first day of new week if needed
      selectedDayIndex = 0;
    });
  }

  // ✅ Navigate to next week
  void _nextWeek() {
    setState(() {
      final monday = weekDays.first.add(const Duration(days: 7));
      weekDays = List.generate(
        7,
        (index) => monday.add(Duration(days: index)),
      );
      // Reset selected day to first day of new week if needed
      selectedDayIndex = 0;
    });
  }

  // ✅ Show calendar dialog to pick a date
  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = weekDays.first;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chọn ngày',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TableCalendar(
                      focusedDay: selectedDate,
                      firstDay: DateTime(2025, 1, 1),
                      lastDay: DateTime(2027, 12, 31),
                      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setModalState(() {
                          selectedDate = selectedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: const Color(0xFF214130),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF214130).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(color: Colors.white),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Calculate Monday of selected date's week
                        final selectedMonday = selectedDate
                            .subtract(Duration(days: selectedDate.weekday - DateTime.monday));
                        
                        setState(() {
                          weekDays = List.generate(
                            7,
                            (index) => selectedMonday.add(Duration(days: index)),
                          );
                          // Find and select the clicked date
                          selectedDayIndex = weekDays.indexWhere(
                            (d) =>
                                d.year == selectedDate.year &&
                                d.month == selectedDate.month &&
                                d.day == selectedDate.day,
                          );
                          if (selectedDayIndex == -1) {
                            selectedDayIndex = 0;
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF214130),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Function để chạy seeder
  Future<void> _runSeeder() async {
    debugPrint('🚀 Running Seeder...');
    try {
      final seeder = DatabaseSeederV2();
      await seeder.seedDatabase();
      debugPrint('✅ Seeder completed!');
      
      // Reload data sau khi seeder chạy xong
      await Future.delayed(const Duration(milliseconds: 500));
      _loadMealPlans();
    } catch (e) {
      debugPrint('❌ Seeder error: $e');
    }
  }

  // ✅ Load available recipes from favorite_recipes + household_recipes
  Future<void> _loadAvailableRecipes() async {
    try {
      const householdId = 'house_01';
      const userId = 'user_01';
      
      debugPrint('');
      debugPrint('🔄 _loadAvailableRecipes() START');
      debugPrint('   Loading from:');
      debugPrint('   - users/$userId/favorite_recipes');
      debugPrint('   - households/$householdId/household_recipes');
      
      // 1️⃣ Load favorite recipes
      List<Map<String, dynamic>> favoriteRecipes = [];
      try {
        final favoriteSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorite_recipes')
            .get();

        debugPrint('   Favorite recipes found: ${favoriteSnapshot.docs.length}');
        
        favoriteRecipes = favoriteSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc['title'] ?? 'Untitled',
                  'image': doc['image'] ?? '',
                  'calories': doc['calories'] ?? 0,
                  'isFavorite': true,
                })
            .toList();
      } catch (e) {
        debugPrint('⚠️ Error loading favorite recipes: $e');
      }

      // 2️⃣ Load household recipes
      List<Map<String, dynamic>> householdRecipes = [];
      try {
        final householdSnapshot = await _firestore
            .collection('households')
            .doc(householdId)
            .collection('household_recipes')
            .get();

        debugPrint('   Household recipes found: ${householdSnapshot.docs.length}');
        
        for (var doc in householdSnapshot.docs) {
          try {
            final data = doc.data();
            final imageUrl = (data['image_url'] ?? data['image'] ?? '') as String;
            final calories = data['calories'];
            final caloriesInt = calories is int ? calories : (calories as num?)?.toInt() ?? 250;
            
            debugPrint('   ✅ Recipe ${doc.id}: ${data['title']} | Calories: $caloriesInt | Image: ${imageUrl.isNotEmpty}');
            
            householdRecipes.add({
              'id': doc.id,
              'title': data['title'] ?? 'Untitled',
              'image': imageUrl,
              'calories': caloriesInt,
              'isFavorite': false,
            });
          } catch (e) {
            debugPrint('   ⚠️ Error parsing recipe ${doc.id}: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error loading household recipes collection: $e');
      }

      // 3️⃣ Merge: Favorite recipes first, then household recipes (avoiding duplicates)
      final Set<String> favoriteIds = favoriteRecipes.map((r) => r['id']).cast<String>().toSet();
      final filteredHousehold = householdRecipes
          .where((recipe) => !favoriteIds.contains(recipe['id']))
          .toList();

      final allRecipes = [...favoriteRecipes, ...filteredHousehold];

      if (mounted) {
        setState(() {
          _availableRecipes = allRecipes;
        });
      }
      
      debugPrint('✅ Loaded ${favoriteRecipes.length} favorite + ${filteredHousehold.length} household = ${allRecipes.length} total recipes');
      debugPrint('🔄 _loadAvailableRecipes() COMPLETE - _availableRecipes list updated');
      
      if (allRecipes.isEmpty) {
        debugPrint('⚠️ WARNING: No recipes found! Check Firebase paths and data.');
      }
    } catch (e) {
      debugPrint('❌ Error loading recipes: $e');
      setState(() {
        _availableRecipes = [];
      });
    }
  }

  // ✅ Show recipe selection bottom sheet with drag-drop
  void _showRecipeBottomSheet(DateTime selectedDate) {
    debugPrint('🔵 Opening recipe bottom sheet with ${_availableRecipes.length} recipes');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        DateTime pickedDate = selectedDate;
        String selectedMealType = 'breakfast';
        int servings = 1;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // ✅ Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thêm công thức vào kế hoạch',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Calendar + Meal Type Selection
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ✅ DragTarget wrapping Calendar - drop recipes here to add to selected date
                        DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) {
                            return true;
                          },
                          onAccept: (dragData) async {
                            final recipe = dragData['recipe'] as Map<String, dynamic>;
                            // Use the currently selected date and meal type from the bottom sheet state
                            await _addMealPlan(
                              pickedDate, 
                              recipe['id'], 
                              selectedMealType,
                              servings: servings,
                            );
                            
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHovering = candidateData.isNotEmpty;
                            return Container(
                              decoration: BoxDecoration(
                                border: isHovering 
                                  ? Border.all(color: const Color(0xFF214130), width: 2)
                                  : Border.all(color: Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(12),
                                color: isHovering ? const Color(0xFF214130).withOpacity(0.05) : null,
                              ),
                              child: TableCalendar(
                                focusedDay: pickedDate,
                                firstDay: DateTime(2025, 1, 1),
                                lastDay: DateTime(2027, 12, 31),
                                selectedDayPredicate: (day) =>
                                    isSameDay(pickedDate, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setModalState(() {
                                    pickedDate = selectedDay;
                                  });
                                },
                                calendarStyle: CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                    color: const Color(0xFF214130),
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF214130).withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedTextStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // ✅ Meal Type Selection
                        Row(
                          children: [
                            Expanded(
                              child: _mealTypeButton(
                                'Bữa sáng',
                                'breakfast',
                                selectedMealType,
                                () => setModalState(
                                    () => selectedMealType = 'breakfast'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _mealTypeButton(
                                'Bữa trưa',
                                'lunch',
                                selectedMealType,
                                () => setModalState(
                                    () => selectedMealType = 'lunch'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _mealTypeButton(
                                'Bữa tối',
                                'dinner',
                                selectedMealType,
                                () => setModalState(
                                    () => selectedMealType = 'dinner'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // ✅ Servings Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Khẩu phần:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () {
                                      if (servings > 1) setModalState(() => servings--);
                                    },
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Container(
                                    width: 30,
                                    alignment: Alignment.center,
                                    child: Text('$servings', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => setModalState(() => servings++),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // ✅ Draggable Recipe Cards - Display ALL recipes
                  Expanded(
                    child: _availableRecipes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, 
                                  size: 48, 
                                  color: Colors.grey[300]
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Không có công thức nào',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _availableRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _availableRecipes[index];
                              debugPrint('   📋 Recipe [$index]: ${recipe['title']}');
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildDraggableRecipeCard(
                                  recipe,
                                  pickedDate,
                                  selectedMealType,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Build meal type selection button
  Widget _mealTypeButton(String label, String type, String selected,
      VoidCallback onTap) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF214130) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ✅ Build draggable recipe card - requires 1 second hold to drag
  Widget _buildDraggableRecipeCard(
    Map<String, dynamic> recipe,
    DateTime selectedDate,
    String mealType,
  ) {
    final dragData = {
      'recipe': recipe,
      'date': selectedDate,
      'mealType': mealType,
    };
    
    debugPrint('🟣 Building draggable card for: ${recipe['title']} | MealType: $mealType | Date: ${selectedDate.toIso8601String()}');
    
    return LongPressDraggable<Map<String, dynamic>>(
      data: dragData,
      delay: const Duration(milliseconds: 500),
      onDragStarted: () {
        debugPrint('👆 [${recipe['title']}] Drag STARTED (after 0.5s hold)');
        debugPrint('   Data being dragged: $dragData');
      },
      onDraggableCanceled: (velocity, offset) {
        debugPrint('❌ [${recipe['title']}] Drag CANCELLED');
      },
      onDragCompleted: () {
        debugPrint('✨ [${recipe['title']}] Drag COMPLETED');
      },
      feedback: Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if ((recipe['image'] as String).isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe['calories']} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            if ((recipe['image'] as String).isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe['calories']} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Call super for AutomaticKeepAliveClientMixin
    
    return Stack(
      children: [
        Column(
          children: [
            // ---------- WEEK HEADER (Month & Date Range) ----------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous week button
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousWeek,
                    color: const Color(0xFF214130),
                    splashRadius: 20,
                  ),
                  // Week range text (clickable)
                  Expanded(
                    child: GestureDetector(
                      onTap: _showDatePicker,
                      child: Text(
                        _getWeekRangeText(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF214130),
                        ),
                      ),
                    ),
                  ),
                  // Next week button
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWeek,
                    color: const Color(0xFF214130),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // ---------- DAY SELECTOR (FIXED AT TOP) ----------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDays.length,
                  itemBuilder: (context, index) {
                    final date = weekDays[index];

                    final hasMealPlan = _hasMealPlan(date);
                    final isActive = selectedDayIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: DragTarget<Map<String, dynamic>>(
                        onWillAccept: (data) {
                          debugPrint('🟡 [Day ${date.day}] onWillAccept: Hovering over day');
                          return true;
                        },
                        onAccept: (dragData) async {
                          // ✅ Recipe dropped on this day
                          debugPrint('✅ [Day ${date.day}] onAccept: Received drag data!');
                          debugPrint('   Drag Data: $dragData');
                          
                          final recipe = dragData['recipe'] as Map<String, dynamic>;
                          final droppedDate = dragData['date'] as DateTime;
                          final mealType = dragData['mealType'] as String;
                          
                          debugPrint('   Recipe: ${recipe['title']}');
                          debugPrint('   MealType: $mealType');
                          debugPrint('   DropDate: $droppedDate');
                          
                          await _addMealPlan(date, recipe['id'], mealType);
                          debugPrint('✅ Successfully added ${recipe['title']} to ${date.day}/${date.month}');
                        },
                        onLeave: (data) {
                          debugPrint('🔵 [Day ${date.day}] onLeave: Left the day target');
                        },
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedDayIndex = index);
                            },
                            child: DayItem(
                              day: _weekdayLabel(date),
                              date: date.day.toString(),
                              active: isActive,
                              hasMealPlan: hasMealPlan,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // ---------- SCROLLABLE CONTENT ----------
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // ✅ Reset flag when user pulls to refresh
                  _hasLoadedData = false;
                  await _loadMealPlans();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // ---------- TITLE ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Meal Plans",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ---------- DYNAMIC MEAL CARDS ----------
                      _buildMealCardsForSelectedDay(),
                      
                      const SizedBox(height: 40), // ✅ Spacing at bottom for scroll
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // ✅ Floating Action Button
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () {
              final selectedDate = weekDays[selectedDayIndex];
              _showRecipeBottomSheet(selectedDate);
            },
            backgroundColor: const Color(0xFF214130),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCardsForSelectedDay() {
    final selectedDate = weekDays[selectedDayIndex];
    final mealPlans = _getMealPlansForDate(selectedDate);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (mealPlans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No meals planned for this day',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...List.generate(
          mealPlans.length,
          (index) {
            final mealPlan = mealPlans[index];
            final mealType = mealPlan['meal_type'] ?? 'Meal';
            final recipeId = mealPlan['local_recipe_id'] ?? '';
            final servings = mealPlan['servings'] ?? 1;

            return Column(
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore
                      .collection('households')
                      .doc(_householdId)
                      .collection('household_recipes')
                      .doc(recipeId)
                      .get()
                      .timeout(const Duration(seconds: 5), onTimeout: () {
                    throw Exception('Recipe fetch timeout');
                  }),
                  builder: (context, snapshot) {
                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return MealCard(
                        label: 'LOADING',
                        title: 'Loading recipe...',
                        kcal: 0,
                        recipeId: recipeId,
                        householdId: _householdId,
                        mealPlanDate: _formatDateKey(selectedDate),
                      );
                    }

                    // Error state
                    if (snapshot.hasError) {
                      debugPrint('❌ Recipe fetch error: ${snapshot.error}');
                      return MealCard(
                        label: mealType.toUpperCase(),
                        title: 'Error loading recipe',
                        kcal: 0,
                        recipeId: recipeId,
                        householdId: _householdId,
                        mealPlanDate: _formatDateKey(selectedDate),
                      );
                    }

                    // No data
                    if (!snapshot.hasData || snapshot.data?.data() == null) {
                      debugPrint('⚠️ Recipe $recipeId not found');
                      return MealCard(
                        label: mealType.toUpperCase(),
                        title: 'Recipe not found',
                        kcal: 0,
                        recipeId: recipeId,
                        householdId: _householdId,
                        mealPlanDate: _formatDateKey(selectedDate),
                      );
                    }

                    final recipe = snapshot.data!.data() as Map<String, dynamic>?;
                    if (recipe == null) {
                      return const SizedBox.shrink();
                    }

                    debugPrint('✅ Recipe loaded: ${recipe['title']}');

                    // Tính calories dựa trên servings
                    final baseCalories = (recipe['calories'] as num?)?.toInt() ?? 0;
                    

                    return MealCard(
                      label: mealType.toUpperCase(),
                      title: recipe['title'] ?? 'Untitled',
                      kcal: baseCalories,
                      recipeId: recipeId, // ✅ Pass recipe ID
                      householdId: _householdId, // ✅ Pass household ID
                      mealPlanDate: _formatDateKey(selectedDate), // ✅ Pass meal plan date
                    );
                  },
                ),
                if (index < mealPlans.length - 1) const SizedBox(height: 16),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        ShoppingList(
          onViewAllTap: () {
            // Navigate to Shopping List tab (index 1)
            if (widget.onTabChange != null) {
              widget.onTabChange!(1);
            }
          },
        ),
      ],
    );
  }
}
