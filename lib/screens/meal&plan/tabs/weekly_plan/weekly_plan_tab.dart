import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../widgets/plans/tabs/weekly_plan_tab/meal_card.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/quick_shopping_list.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/day_item.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/plan_dinner_card.dart';
import '../../../../utils/firebase_seeder.dart';

class WeeklyPlanContent extends StatefulWidget {
  const WeeklyPlanContent({super.key});

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

    // ✅ Fetch household ID and meal plans ONLY on first load
    _loadMealPlans();
  }

  // Helper function để format date key một cách nhất quán (YYYY-MM-DD)
  String _formatDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  Future<void> _loadMealPlans() async {
    // ✅ Guard: Nếu data đã load, bỏ qua (trừ khi là pull-to-refresh)
    // Pull-to-refresh sẽ reset flag trong RefreshIndicator callback
    if (_hasLoadedData && _isLoading == false) {
      debugPrint('⏭️  Skipping _loadMealPlans() - data already loaded');
      return;
    }

    try {
      debugPrint('🔄 Loading meal plans...');
      
      // ✅ Hardcode lấy dữ liệu từ seeder user (user_01)
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

  List<Map<String, dynamic>> _getMealPlansForDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    return _mealPlansByDate[dateKey] ?? [];
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ Call super for AutomaticKeepAliveClientMixin
    
    return RefreshIndicator(
      onRefresh: () async {
        // ✅ Reset flag when user pulls to refresh
        _hasLoadedData = false;
        await _loadMealPlans();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // ✅ Allow refresh even when empty
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          key: const ValueKey('weekly'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- DEBUG BUTTON ----------
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8),
            //   child: ElevatedButton.icon(
            //     onPressed: _runSeeder,
            //     icon: const Icon(Icons.refresh),
            //     label: const Text('Run Seeder (Debug)'),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.orange,
            //     ),
            //   ),
            // ),

            // ---------- DAY SELECTOR ----------
            SizedBox(
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
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedDayIndex = index);
                      },
                      child: DayItem(
                        day: _weekdayLabel(date),
                        date: date.day.toString(),
                        active: isActive,
                        hasMealPlan: hasMealPlan,
                      ),
                    ),
                  );
                },
              ),
            ),

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
                    final totalCalories = (baseCalories * servings).toInt();

                    return MealCard(
                      label: mealType.toUpperCase(),
                      title: recipe['title'] ?? 'Untitled',
                      kcal: totalCalories,
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
        const ShoppingList(),
      ],
    );
  }
}
