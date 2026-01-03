import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/plans/tabs/weekly_plan_tab/meal_card.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/day_item.dart';
import '../../../../providers/recipe_provider.dart';
import '../weekly_plan/add_recipe_screen.dart';
import '../../../../data/services/spoonacular_service.dart';

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
  String? _userId; // ✅ User ID từ FirebaseAuth
  String? _householdId; // ✅ Household ID từ user document
  Map<String, List<Map<String, dynamic>>> _mealPlansByDate = {};
  bool _isLoading = true;
  bool _hasLoadedData = false; // ✅ Track if data already loaded
  List<Map<String, dynamic>> _availableRecipes =
      []; // ✅ Store available recipes

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
          d.year == today.year && d.month == today.month && d.day == today.day,
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
      await _loadMealPlans(); // Then load meal plans
      debugPrint('🚀 _initializeData() COMPLETE');
    } catch (e) {
      debugPrint('❌ Error during initialization: $e');
    }
  }

  // Helper function để format date key một cách nhất quán (YYYY-MM-DD)
  String _formatDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  Future<void> _loadMealPlans({bool forceReload = false}) async {
    // ✅ Guard: During initialization, only load once (unless force reload)
    if (!forceReload && _hasLoadedData && mounted) {
      debugPrint('⏭️  Skipping _loadMealPlans() - data already loaded');
      return;
    }

    try {
      debugPrint('🔄 Loading meal plans...');

      // ✅ Lấy user hiện tại từ FirebaseAuth
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        setState(() {
          _isLoading = false;
          _hasLoadedData = true;
        });
        return;
      }

      _userId = currentUser.uid;

      debugPrint('👤 Current User ID: $_userId');

      // ✅ Lấy household_id từ user document
      final userDoc = await _firestore.collection('users').doc(_userId).get();

      debugPrint('📄 User document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        debugPrint('📄 User document data: ${userDoc.data()}');
        debugPrint(
            '📄 current_household_id field: ${userDoc.data()?['current_household_id']}');
      }

      if (!userDoc.exists || userDoc.data()?['current_household_id'] == null) {
        debugPrint('❌ User document not found or no current_household_id');
        debugPrint('💡 Tip: Run the database seeder to create user data');
        setState(() {
          _isLoading = false;
          _hasLoadedData = true;
        });
        return;
      }

      _householdId = userDoc.data()!['current_household_id'] as String;

      debugPrint('🏠 Household ID: $_householdId');
      debugPrint('👤 User ID: $_userId');

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
        debugPrint('   🔑 local_recipe_id: ${data['local_recipe_id']}');
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
        debugPrint(
            '   [$i] ${d.toIso8601String()} => Key: $key | Has Meal: $hasMeal');
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

  // ✅ Ensure a recipe exists in household_recipes (for API recipes that haven't been saved yet)
  Future<void> _ensureHouseholdRecipeExists(String recipeId) async {
    if (_householdId == null) return;

    final recipeDocRef = _firestore
        .collection('households')
        .doc(_householdId)
        .collection('household_recipes')
        .doc(recipeId);

    final existing = await recipeDocRef.get();

    // ✅ Check if recipe exists AND has full data (ingredients & instructions)
    if (existing.exists) {
      final existingData = existing.data() as Map<String, dynamic>;
      final hasIngredients = existingData['ingredients'] != null &&
          (existingData['ingredients'] as List).isNotEmpty;
      final hasInstructions = existingData['instructions'] != null &&
          (existingData['instructions'] as String).isNotEmpty;

      if (hasIngredients && hasInstructions) {
        debugPrint(
            '✅ Recipe $recipeId already exists with full data, skipping');
        return; // Recipe đã có đầy đủ dữ liệu
      } else {
        debugPrint(
            '⚠️ Recipe $recipeId exists but missing data. Will update...');
        debugPrint('   - Has ingredients: $hasIngredients');
        debugPrint('   - Has instructions: $hasInstructions');
        // Tiếp tục để fetch và update dữ liệu
      }
    }

    // Try to find recipe data from the in-memory list
    final recipe = _availableRecipes.firstWhere(
      (r) => r['id'] == recipeId,
      orElse: () => {},
    );

    if (recipe.isEmpty) {
      debugPrint(
          '⚠️ Cannot upsert recipe $recipeId because data not found locally');
      return;
    }

    final calories = recipe['calories'];
    final readyInMinutes =
        recipe['ready_in_minutes'] ?? recipe['readyInMinutes'] ?? 0;
    final apiRecipeId = recipe['api_recipe_id'];

    // ✅ Fetch full details from API if this is an API recipe (not from favorites/household_recipes)
    List<dynamic> fullIngredients = recipe['ingredients'] ?? [];
    String fullInstructions = recipe['instructions'] ?? '';

    // ✅ If ingredients or instructions are empty, fetch from API
    if (apiRecipeId != null &&
        (fullIngredients.isEmpty || fullInstructions.isEmpty)) {
      debugPrint(
          '🌐 Fetching full recipe details from API for recipe ID: $apiRecipeId');
      try {
        final apiService = SpoonacularService();
        final fullData = await apiService.getRecipeInformation(apiRecipeId);

        if (fullData != null) {
          // ✅ Parse ingredients
          if (fullData['extendedIngredients'] != null) {
            final List<dynamic> rawIngs = fullData['extendedIngredients'];
            fullIngredients = rawIngs.map((ing) {
              return {
                'name': ing['name'] ?? '',
                'amount': (ing['amount'] as num?)?.toDouble() ?? 0.0,
                'unit': ing['unit'] ?? '',
                'original': ing['original'] ?? '',
              };
            }).toList();
            debugPrint(
                '   ✅ Loaded ${fullIngredients.length} ingredients from API');
          }

          // ✅ Parse instructions
          if (fullData['analyzedInstructions'] != null &&
              (fullData['analyzedInstructions'] as List).isNotEmpty) {
            final List steps = fullData['analyzedInstructions'][0]['steps'];
            fullInstructions =
                steps.map<String>((step) => step['step'].toString()).join('\n');
            debugPrint(
                '   ✅ Loaded ${steps.length} instruction steps from API');
          } else if (fullData['instructions'] != null) {
            fullInstructions = fullData['instructions'].toString();
            debugPrint(
                '   ✅ Loaded raw instructions: ${fullInstructions.length} chars');
          } else {
            debugPrint('   ⚠️ No instructions found in API response');
          }

          debugPrint(
              '   📝 Final instructions to save: ${fullInstructions.length} chars');
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching full recipe details from API: $e');
        // Continue with empty data - better than failing completely
      }
    }

    // Build document with full data
    final docData = {
      'local_recipe_id': recipeId,
      'household_id': _householdId,
      'api_recipe_id': apiRecipeId,
      'title': recipe['title'] ?? 'Untitled',
      'image_url': recipe['image'] ?? '',
      'calories': calories is num ? calories.toInt() : 0,
      'ready_in_minutes': readyInMinutes is num ? readyInMinutes.toInt() : 0,
      'difficulty': recipe['difficulty'],
      'instructions': fullInstructions,
      'ingredients': fullIngredients,
      'servings': recipe['servings'] ?? 1,
      'added_by_uid': _userId,
      'added_at': Timestamp.now(),
    };

    debugPrint('💾 Saving recipe to Firestore:');
    debugPrint('   - Title: ${docData['title']}');
    debugPrint(
        '   - Ingredients count: ${(docData['ingredients'] as List).length}');
    debugPrint(
        '   - Instructions length: ${(docData['instructions'] as String).length} chars');

    await recipeDocRef.set(docData);
    debugPrint(
        '✅ Saved API recipe with full details into household_recipes: $recipeId');
  }

  bool _hasMealPlan(DateTime date) {
    final dateKey = _formatDateKey(date);
    return _mealPlansByDate.containsKey(dateKey) &&
        _mealPlansByDate[dateKey]!.isNotEmpty;
  }

  // ✅ Add meal plan to Firebase when recipe is dropped on a day
  Future<void> _addMealPlan(DateTime date, String recipeId, String mealType,
      {int servings = 1}) async {
    try {
      // ✅ Kiểm tra xem đã có userId và householdId chưa
      if (_userId == null || _householdId == null) {
        debugPrint('❌ Cannot add meal plan: userId or householdId is null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Vui lòng đăng nhập để thêm kế hoạch'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ✅ If recipe is from API and not yet saved, upsert it into household_recipes
      await _ensureHouseholdRecipeExists(recipeId);

      final newDocRef = _firestore
          .collection('households')
          .doc(_householdId)
          .collection('meal_plans')
          .doc();

      await newDocRef.set({
        'plan_id': newDocRef.id,
        'date': Timestamp.fromDate(date),
        'meal_type': mealType,
        'local_recipe_id': recipeId,
        'servings': servings,
        'created_at': Timestamp.now(),
        'household_id': _householdId,
        'is_cooked': false,
        'planned_by_uid': _userId,
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
      'THÁNG 1',
      'THÁNG 2',
      'THÁNG 3',
      'THÁNG 4',
      'THÁNG 5',
      'THÁNG 6',
      'THÁNG 7',
      'THÁNG 8',
      'THÁNG 9',
      'THÁNG 10',
      'THÁNG 11',
      'THÁNG 12'
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
                      selectedDayPredicate: (day) =>
                          isSameDay(selectedDate, day),
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
                        final selectedMonday = selectedDate.subtract(Duration(
                            days: selectedDate.weekday - DateTime.monday));

                        setState(() {
                          weekDays = List.generate(
                            7,
                            (index) =>
                                selectedMonday.add(Duration(days: index)),
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

  // ✅ Load available recipes from favorite_recipes + API + household_recipes
  Future<void> _loadAvailableRecipes() async {
    try {
      // ✅ Lấy user hiện tại
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No user logged in');
        if (mounted) {
          setState(() {
            _availableRecipes = [];
          });
        }
        return;
      }

      final userId = currentUser.uid;

      // ✅ Lấy household_id từ user document nếu chưa có
      String? householdId = _householdId;
      if (householdId == null) {
        final userDoc =
            await _firestore.collection('users').doc(userId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Timeout loading user document');
          },
        );
        if (!userDoc.exists ||
            userDoc.data()?['current_household_id'] == null) {
          debugPrint('❌ User document not found or no current_household_id');
          if (mounted) {
            setState(() {
              _availableRecipes = [];
            });
          }
          return;
        }
        householdId = userDoc.data()!['current_household_id'] as String;
      }

      debugPrint('');
      debugPrint('🔄 _loadAvailableRecipes() START');
      debugPrint('   Loading from:');
      debugPrint('   - households/$householdId/favorite_recipes');
      debugPrint('   - households/$householdId/household_recipes');
      debugPrint('   - API (via RecipeProvider)');

      // 1️⃣ Load favorite recipes from household/favorite_recipes
      List<Map<String, dynamic>> favoriteRecipes = [];
      Set<int> favoriteApiIds = {};
      try {
        final favoriteSnapshot = await _firestore
            .collection('households')
            .doc(householdId)
            .collection('favorite_recipes')
            .get()
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Timeout loading favorite recipes');
          },
        );

        debugPrint(
            '   Favorite recipes found: ${favoriteSnapshot.docs.length}');

        for (var doc in favoriteSnapshot.docs) {
          try {
            final data = doc.data();
            final imageUrl =
                (data['image_url'] ?? data['image'] ?? '') as String;
            final calories = data['calories'];
            final caloriesInt =
                calories is int ? calories : (calories as num?)?.toInt() ?? 250;
            final apiRecipeId = data['api_recipe_id'];

            if (apiRecipeId != null) {
              favoriteApiIds.add(apiRecipeId as int);
            }

            favoriteRecipes.add({
              'id': doc.id,
              'api_recipe_id': apiRecipeId,
              'title': data['title'] ?? 'Untitled',
              'image': imageUrl,
              'calories': caloriesInt,
              'isFavorite': true,
            });
          } catch (e) {
            debugPrint('   ⚠️ Error parsing favorite recipe ${doc.id}: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error loading favorite recipes: $e');
      }

      // 2️⃣ Load recipes from household_recipes (recipes saved from API)
      List<Map<String, dynamic>> householdRecipes = [];
      Set<int> householdApiIds = {};
      try {
        final householdSnapshot = await _firestore
            .collection('households')
            .doc(householdId)
            .collection('household_recipes')
            .get()
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Timeout loading household recipes');
          },
        );

        debugPrint(
            '   Household recipes found: ${householdSnapshot.docs.length}');

        for (var doc in householdSnapshot.docs) {
          try {
            final data = doc.data();
            final imageUrl =
                (data['image_url'] ?? data['image'] ?? '') as String;
            final calories = data['calories'];
            final caloriesInt =
                calories is int ? calories : (calories as num?)?.toInt() ?? 250;
            final apiRecipeId = data['api_recipe_id'];

            if (apiRecipeId != null) {
              householdApiIds.add(apiRecipeId as int);
            }

            // Check if this recipe is in favorites
            final isFav =
                apiRecipeId != null && favoriteApiIds.contains(apiRecipeId);

            householdRecipes.add({
              'id': doc.id,
              'api_recipe_id': apiRecipeId,
              'title': data['title'] ?? 'Untitled',
              'image': imageUrl,
              'calories': caloriesInt,
              'isFavorite': isFav,
            });
          } catch (e) {
            debugPrint('   ⚠️ Error parsing household recipe ${doc.id}: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error loading household recipes: $e');
      }

      // 3️⃣ Load recipes from API via RecipeProvider (currently displayed in Recipe screen)
      List<Map<String, dynamic>> apiRecipes = [];
      try {
        if (mounted && context.mounted) {
          final recipeProvider =
              Provider.of<RecipeProvider>(context, listen: false);

          final recipes = recipeProvider.recipes;
          debugPrint('   API recipes in provider: ${recipes.length}');

          for (var recipe in recipes) {
            final apiId = recipe.apiRecipeId;

            // Skip if this recipe is already in favorites or household collections
            if (apiId != null &&
                (favoriteApiIds.contains(apiId) ||
                    householdApiIds.contains(apiId))) {
              debugPrint(
                  '   ⏭️  Skipping API recipe ${recipe.title} - already saved');
              continue;
            }

            final isFav = apiId != null && favoriteApiIds.contains(apiId);

            final generatedId = recipe.localRecipeId ??
                (apiId != null ? 'api_$apiId' : UniqueKey().toString());

            apiRecipes.add({
              'id': generatedId,
              'api_recipe_id': apiId,
              'title': recipe.title,
              'image': recipe.imageUrl ?? '',
              'calories': recipe.calories ?? 0,
              'ready_in_minutes': recipe.readyInMinutes,
              'difficulty': recipe.difficulty,
              'instructions': recipe.instructions,
              'ingredients': const <Map<String, dynamic>>[],
              'servings': recipe.servings ?? 1,
              'isFavorite': isFav,
              'isFromApi': true, // ✅ Mark as API recipe for filtering
            });
          }
          debugPrint(
              '   ✅ Loaded ${apiRecipes.length} unique API recipes (filtered)');
        }
      } catch (e) {
        debugPrint('⚠️ Error loading API recipes: $e');
      }

      // 4️⃣ Merge: Favorite recipes first, then household recipes, then API recipes
      final allRecipes = [
        ...favoriteRecipes, // Favorites first
        ...householdRecipes.where((r) => !favoriteApiIds
            .contains(r['api_recipe_id'])), // Non-favorite household recipes
        ...apiRecipes, // ✅ API recipes currently displayed in Recipe screen
      ];

      if (mounted) {
        setState(() {
          _availableRecipes = allRecipes;
        });
      }

      debugPrint('✅ Loaded:');
      debugPrint('   - ${favoriteRecipes.length} favorite recipes');
      debugPrint('   - ${householdRecipes.length} household recipes');
      debugPrint('   - ${apiRecipes.length} API recipes (from Recipe screen)');
      debugPrint('   = ${allRecipes.length} total recipes available');
      debugPrint('🔄 _loadAvailableRecipes() COMPLETE');

      if (allRecipes.isEmpty) {
        debugPrint(
            '⚠️ WARNING: No recipes found! Search for recipes in Recipe screen first.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading recipes: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _availableRecipes = [];
        });
      }
    }
  }

  // ✅ Navigate to add recipe screen (hides bottom navigation)
  void _showRecipeBottomSheet(
      DateTime selectedDate, List<Map<String, dynamic>> recipes) {
    debugPrint('🔵 Opening add recipe screen with ${recipes.length} recipes');

    // ✅ Sử dụng ROOT Navigator để mở màn hình BÊN NGOÀI MainScreen
    // Điều này sẽ ẩn bottom navigation bar hoàn toàn
    Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(
          selectedDate: selectedDate,
          recipes: recipes,
          onAddMealPlan: (date, recipeId, mealType, servings) async {
            await _addMealPlan(date, recipeId, mealType, servings: servings);
          },
        ),
      ),
    )
        .then((_) {
      // ✅ Refresh when returning from add_recipe_screen
      debugPrint('🔄 Returned from add_recipe_screen - refreshing meal plans');
      _loadMealPlans(forceReload: true);
    });
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
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 8),
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
                          debugPrint(
                              '🟡 [Day ${date.day}] onWillAccept: Hovering over day');
                          return true;
                        },
                        onAccept: (dragData) async {
                          // ✅ Recipe dropped on this day
                          debugPrint(
                              '✅ [Day ${date.day}] onAccept: Received drag data!');
                          debugPrint('   Drag Data: $dragData');

                          final recipe =
                              dragData['recipe'] as Map<String, dynamic>;
                          final droppedDate = dragData['date'] as DateTime;
                          final mealType = dragData['mealType'] as String;

                          debugPrint('   Recipe: ${recipe['title']}');
                          debugPrint('   MealType: $mealType');
                          debugPrint('   DropDate: $droppedDate');

                          await _addMealPlan(date, recipe['id'], mealType);
                          debugPrint(
                              '✅ Successfully added ${recipe['title']} to ${date.day}/${date.month}');
                        },
                        onLeave: (data) {
                          debugPrint(
                              '🔵 [Day ${date.day}] onLeave: Left the day target');
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

            // ---------- TITLE (FIXED) ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
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
                      const SizedBox(height: 8),

                      // ---------- DYNAMIC MEAL CARDS ----------
                      _buildMealCardsForSelectedDay(),

                      const SizedBox(
                          height: 40), // ✅ Spacing at bottom for scroll
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
            heroTag: 'weekly_plan_fab',
            onPressed: () {
              if (!mounted) return;

              final selectedDate = weekDays[selectedDayIndex];

              // Check if recipes are loaded
              if (_availableRecipes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Không có công thức nào. Hãy tìm kiếm công thức ở tab Recipes.'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // Navigate to add recipe screen immediately
              _showRecipeBottomSheet(selectedDate, _availableRecipes);
            },
            backgroundColor: const Color(0xFF214130),
            shape: const CircleBorder(), // ✅ Ensure circular shape
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

            debugPrint('');
            debugPrint('🔍 ========== PREPARING TO FETCH RECIPE ==========');
            debugPrint('   Recipe ID from meal plan: $recipeId');
            debugPrint('   Meal Type: $mealType');
            debugPrint(
                '   Will fetch from: households/$_householdId/household_recipes/$recipeId');
            debugPrint('==================================================');
            debugPrint('');

            return Column(
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore
                      .collection('households')
                      .doc(_householdId!)
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
                        kcal: 0.0,
                        recipeId: recipeId,
                        householdId: _householdId!,
                        mealPlanDate: _formatDateKey(selectedDate),
                        mealType: mealType,
                      );
                    }

                    // Error state
                    if (snapshot.hasError) {
                      debugPrint('❌ Recipe fetch error: ${snapshot.error}');
                      debugPrint('   Recipe ID: $recipeId');
                      debugPrint('   Household ID: $_householdId');
                      debugPrint(
                          '   Path: households/$_householdId/household_recipes/$recipeId');
                      return MealCard(
                        label: mealType.toUpperCase(),
                        title: 'Error loading recipe',
                        kcal: 0.0,
                        recipeId: recipeId,
                        householdId: _householdId!,
                        mealPlanDate: _formatDateKey(selectedDate),
                        mealType: mealType,
                      );
                    }

                    // No data
                    if (!snapshot.hasData || snapshot.data?.data() == null) {
                      debugPrint('⚠️ Recipe $recipeId not found');
                      debugPrint('   Snapshot has data: ${snapshot.hasData}');
                      debugPrint(
                          '   Document exists: ${snapshot.data?.exists}');
                      debugPrint(
                          '   Path: households/$_householdId/household_recipes/$recipeId');
                      return MealCard(
                        label: mealType.toUpperCase(),
                        title: 'Recipe not found ($recipeId)',
                        kcal: 0.0,
                        recipeId: recipeId,
                        householdId: _householdId!,
                        mealPlanDate: _formatDateKey(selectedDate),
                        mealType: mealType,
                      );
                    }

                    final recipe =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    if (recipe == null) {
                      return const SizedBox.shrink();
                    }

                    debugPrint('✅ Recipe loaded: ${recipe['title']}');

                    // Tính calories dựa trên servings - keep as double
                    final baseCalories =
                        (recipe['calories'] as num?)?.toDouble() ?? 0.0;
                    final imageUrl = recipe['image_url'] as String?;

                    return MealCard(
                      label: mealType.toUpperCase(),
                      title: recipe['title'] ?? 'Untitled',
                      kcal: baseCalories,
                      recipeId: recipeId, // ✅ Pass recipe ID
                      householdId: _householdId!, // ✅ Pass household ID
                      mealPlanDate:
                          _formatDateKey(selectedDate), // ✅ Pass meal plan date
                      mealType: mealType,
                      imageUrl: imageUrl, // ✅ Pass recipe image
                      mealPlanServings:
                          servings, // ✅ Pass servings from meal_plan
                      onDeleted: () {
                        // ✅ Reload meal plans when deleted
                        debugPrint('🔄 Reloading meal plans after deletion');
                        _hasLoadedData = false;
                        _loadMealPlans();
                      },
                    );
                  },
                ),
                if (index < mealPlans.length - 1) const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
    );
  }
}
