import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlannerDetailScreen extends StatefulWidget {
  final String recipeId; // ✅ Recipe ID từ meal_card
  final String householdId; // ✅ Household ID
  final String mealPlanDate; // ✅ Ngày meal plan
  final String mealType; // ✅ Meal type để tính thứ tự
  final int mealPlanServings; // ✅ Servings từ meal_plan
  final VoidCallback? onDeleted; // ✅ Callback when meal plan is deleted

  const PlannerDetailScreen({
    super.key,
    required this.recipeId,
    required this.householdId,
    required this.mealPlanDate,
    required this.mealType,
    this.mealPlanServings = 1,
    this.onDeleted,
  });

  @override
  State<PlannerDetailScreen> createState() => _PlannerDetailScreenState();
}

class _PlannerDetailScreenState extends State<PlannerDetailScreen> {
  int servings = 2;
  int originalServings = 2; // ✅ Store original servings from recipe
  DateTime? selectedDate; // 👈 ngày được chọn

  // ✅ Biến lưu dữ liệu từ Firebase
  Map<String, dynamic>? recipeData;
  List<Map<String, dynamic>> ingredients = [];
  List<String> instructions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
  }

  // ✅ Calculate remaining inventory after subtracting ingredients from previous meal plans
  Future<Map<String, double>> _calculateRemainingInventory() async {
    try {
      // 1. Fetch current inventory
      final inventorySnapshot = await FirebaseFirestore.instance
          .collection('households')
          .doc(widget.householdId)
          .collection('inventory')
          .get();

      // Build inventory map: ingredient_name (lowercase) -> quantity
      final inventoryMap = <String, double>{};
      for (var doc in inventorySnapshot.docs) {
        final name = (doc.data()['name'] ?? '').toString().toLowerCase().trim();
        final quantity = (doc.data()['quantity'] ?? 0).toDouble();
        if (name.isNotEmpty) {
          inventoryMap[name] = (inventoryMap[name] ?? 0) + quantity;
        }
      }

      debugPrint('📦 Initial inventory: $inventoryMap');

      // 2. Fetch all meal plans for the same date
      final dateTimestamp =
          Timestamp.fromDate(DateTime.parse(widget.mealPlanDate));

      final mealPlansSnapshot = await FirebaseFirestore.instance
          .collection('households')
          .doc(widget.householdId)
          .collection('meal_plans')
          .where('date', isEqualTo: dateTimestamp)
          .get();

      debugPrint(
          '🍽️ Found ${mealPlansSnapshot.docs.length} meal plans for ${widget.mealPlanDate}');

      // 3. Define meal type order
      const mealTypeOrder = {
        'Breakfast': 0,
        'breakfast': 0,
        'Lunch': 1,
        'lunch': 1,
        'Dinner': 2,
        'dinner': 2,
        'Snack': 3,
        'snack': 3,
      };

      final currentMealOrder = mealTypeOrder[widget.mealType] ?? 99;
      debugPrint(
          '🔢 Current meal type: ${widget.mealType} (order: $currentMealOrder)');

      // 4. Subtract ingredients from previous meal plans (earlier meal types)
      for (var mealPlanDoc in mealPlansSnapshot.docs) {
        final mealPlanData = mealPlanDoc.data();
        final mealType = mealPlanData['meal_type'] ?? '';
        final recipeId = mealPlanData['local_recipe_id'] ?? '';

        final mealOrder = mealTypeOrder[mealType] ?? 99;

        // Skip this meal and later meals
        if (mealOrder >= currentMealOrder) {
          debugPrint(
              '⏭️ Skipping $mealType (order: $mealOrder >= $currentMealOrder)');
          continue;
        }

        debugPrint(
            '⏮️ Processing previous meal: $mealType (order: $mealOrder)');

        // Fetch recipe to get ingredients
        final recipeDoc = await FirebaseFirestore.instance
            .collection('households')
            .doc(widget.householdId)
            .collection('household_recipes')
            .doc(recipeId)
            .get();

        if (!recipeDoc.exists) {
          debugPrint('⚠️ Recipe $recipeId not found');
          continue;
        }

        final recipeData = recipeDoc.data() as Map<String, dynamic>;
        final ingredients = recipeData['ingredients'] as List<dynamic>? ?? [];

        // Subtract ingredients from inventory
        for (var ing in ingredients) {
          final name = (ing['name'] ?? '').toString().toLowerCase().trim();
          final amount = (ing['amount'] ?? 0).toDouble();

          if (name.isEmpty) continue;

          // Find matching inventory item (partial match)
          for (var invKey in inventoryMap.keys.toList()) {
            if (invKey.contains(name) || name.contains(invKey)) {
              final remaining = inventoryMap[invKey]! - amount;
              inventoryMap[invKey] = remaining > 0 ? remaining : 0;
              debugPrint(
                  '   ➖ $name: ${inventoryMap[invKey]! + amount} - $amount = ${inventoryMap[invKey]}');
              break;
            }
          }
        }
      }

      debugPrint('');
      debugPrint('📊 Remaining inventory after previous meals:');
      inventoryMap.forEach((key, value) {
        debugPrint('   $key: $value');
      });
      debugPrint('');

      return inventoryMap;
    } catch (e) {
      debugPrint('❌ Error calculating remaining inventory: $e');
      return {};
    }
  }

  // ✅ Fetch recipe từ Firebase và load ingredient names từ master collection
  Future<void> _fetchRecipeData() async {
    try {
      debugPrint('');
      debugPrint('🔍 ========== DETAIL SCREEN: FETCHING RECIPE ==========');
      debugPrint('   Recipe ID: ${widget.recipeId}');
      debugPrint('   Household ID: ${widget.householdId}');
      debugPrint(
          '   Path: households/${widget.householdId}/household_recipes/${widget.recipeId}');
      debugPrint('======================================================');
      debugPrint('');

      final recipeDoc = await FirebaseFirestore.instance
          .collection('households')
          .doc(widget
              .householdId) // ✅ Use widget.householdId instead of hardcoded
          .collection('household_recipes')
          .doc(widget.recipeId)
          .get();

      if (!recipeDoc.exists) {
        debugPrint('❌ Recipe document does not exist in Firestore');
        throw Exception('Recipe not found');
      }

      final data = recipeDoc.data() as Map<String, dynamic>;

      // ✅ Calculate remaining inventory after previous meal plans
      debugPrint(
          '🔍 Calculating remaining inventory after previous meal plans...');
      final remainingInventory = await _calculateRemainingInventory();
      debugPrint('🧊 Remaining inventory: ${remainingInventory.length} items');

      // ✅ Parse ingredients - check if name exists directly, otherwise fetch from master collection
      final ingredientsList = <Map<String, dynamic>>[];
      final rawIngredients = data['ingredients'] as List<dynamic>? ?? [];

      for (var ing in rawIngredients) {
        final amount = (ing['amount'] ?? 0).toDouble();
        final unit = ing['unit'] ?? '';

        // ✅ Check if ingredient has 'name' field directly (from seeder)
        String ingredientName = ing['name'] ?? '';

        // ✅ If no direct name, try to fetch from master ingredients collection using ingredient_id
        if (ingredientName.isEmpty) {
          final ingredientId = ing['ingredient_id'] ?? '';
          if (ingredientId.isNotEmpty) {
            try {
              final ingDoc = await FirebaseFirestore.instance
                  .collection('ingredients')
                  .doc(ingredientId)
                  .get();

              if (ingDoc.exists) {
                ingredientName = ingDoc.data()?['name'] ?? 'Unknown';
              } else {
                ingredientName = 'Unknown (ID: $ingredientId)';
              }
            } catch (e) {
              debugPrint('⚠️ Error fetching ingredient $ingredientId: $e');
              ingredientName = 'Unknown';
            }
          } else {
            ingredientName = 'Unknown';
          }
        }

        // ✅ Check remaining quantity in inventory (case-insensitive partial match)
        final nameLower = ingredientName.toLowerCase().trim();
        double availableQty = 0;

        for (var entry in remainingInventory.entries) {
          if (entry.key.contains(nameLower) || nameLower.contains(entry.key)) {
            availableQty += entry.value;
          }
        }

        final bool hasEnough = availableQty >= amount;
        final bool inFridge = availableQty > 0;

        if (hasEnough) {
          debugPrint(
              '✅ "$ingredientName" OK (need: $amount, have: $availableQty)');
        } else if (inFridge) {
          debugPrint(
              '⚠️ "$ingredientName" NOT ENOUGH (need: $amount, have: $availableQty, missing: ${amount - availableQty})');
        } else {
          debugPrint('❌ "$ingredientName" NOT IN FRIDGE (need: $amount)');
        }

        ingredientsList.add({
          'name': ingredientName,
          'amount': amount,
          'unit': unit,
          'checked': hasEnough, // ✅ Check only if have enough
          'inFridge': inFridge, // ✅ Mark as in fridge if any amount available
          'availableQty': availableQty, // ✅ Store available quantity
          'hasEnough': hasEnough, // ✅ Mark if sufficient quantity
        });
      }

      // ✅ Parse instructions - nếu là string, split by newline; nếu là array, convert to list
      final instructionsList = <String>[];
      final rawInstructions = data['instructions'];

      debugPrint('');
      debugPrint('📋 ========== INSTRUCTIONS DEBUG ==========');
      debugPrint('   Raw instructions type: ${rawInstructions.runtimeType}');
      debugPrint('   Raw instructions value: $rawInstructions');
      debugPrint('   Is null? ${rawInstructions == null}');
      debugPrint('   Is empty? ${rawInstructions == ""}');

      if (rawInstructions is String) {
        debugPrint('   Processing as String...');
        final lines = rawInstructions.split('\n');
        debugPrint('   Split into ${lines.length} lines');

        // Filter empty lines
        final filtered = lines.where((s) => s.trim().isNotEmpty).toList();
        debugPrint('   After filtering: ${filtered.length} non-empty lines');

        instructionsList.addAll(filtered);
      } else if (rawInstructions is List<dynamic>) {
        debugPrint('   Processing as List...');
        debugPrint('   List length: ${rawInstructions.length}');

        instructionsList.addAll(rawInstructions.map((inst) => inst.toString()));
      } else {
        debugPrint('   ⚠️ Unknown type or null!');
      }

      debugPrint('   Final instructions count: ${instructionsList.length}');
      if (instructionsList.isNotEmpty) {
        debugPrint('   First instruction: ${instructionsList.first}');
      }
      debugPrint('==========================================');
      debugPrint('');

      // ✅ Get original servings from recipe
      final recipeServings = (data['servings'] as num?)?.toInt() ?? 1;

      setState(() {
        recipeData = data;
        ingredients = ingredientsList;
        instructions = instructionsList;
        // ✅ Use mealPlanServings from meal_plan instead of recipe default
        servings = widget.mealPlanServings > 0 ? widget.mealPlanServings : 1;
        originalServings = recipeServings > 0
            ? recipeServings
            : 1; // Store original for calculations
        isLoading = false;
      });

      debugPrint('✅ Recipe loaded: ${data['title']}');
      debugPrint('✅ Original servings: $originalServings');
      debugPrint('✅ Meal plan servings: ${widget.mealPlanServings}');
      debugPrint('✅ Ingredients parsed: ${ingredients.length} items');
      debugPrint('✅ Instructions parsed: ${instructionsList.length} steps');
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading recipe: ${e.toString()}';
        isLoading = false;
      });
      debugPrint('❌ Error fetching recipe: $e');
    }
  }

  // ================= UPDATE SERVINGS IN MEAL PLAN =================
  Future<void> _updateMealPlanServings(int newServings) async {
    try {
      debugPrint('🔄 Updating meal plan servings to $newServings');

      // Find the meal plan document using date range query
      final startOfDay = DateTime.parse(widget.mealPlanDate);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startTimestamp = Timestamp.fromDate(startOfDay);
      final endTimestamp = Timestamp.fromDate(endOfDay);

      final mealPlanSnapshot = await FirebaseFirestore.instance
          .collection('households')
          .doc(widget.householdId)
          .collection('meal_plans')
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThan: endTimestamp)
          .get();

      // Filter by meal_type and recipe_id in code
      final matchingDocs = mealPlanSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['meal_type'] == widget.mealType &&
            data['local_recipe_id'] == widget.recipeId;
      }).toList();

      if (matchingDocs.isNotEmpty) {
        await matchingDocs.first.reference.update({'servings': newServings});
        debugPrint('✅ Updated meal plan servings to $newServings');
      } else {
        debugPrint('⚠️ No matching meal plan found to update servings');
      }
    } catch (e) {
      debugPrint('❌ Error updating servings: $e');
    }
  }

  // ================= ADD TO CALENDAR LOGIC =================
  Future<void> _addToCalendar() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });

    // DEMO: hiển thị kết quả
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Meal added to ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
        ),
        backgroundColor: const Color(0xFF214130),
      ),
    );

    // 👉 Ở đây trong app thật:
    // - Add meal vào planner list
    // - Gọi provider / bloc / database
  }

  // ================= DELETE MEAL PLAN LOGIC =================
  Future<void> _showDeleteDialog() async {
    debugPrint('🔴 Delete button clicked!');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan'),
        content: const Text(
            'Are you sure you want to remove this meal from your plan?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteMealPlan();
    }
  }

  Future<void> _deleteMealPlan() async {
    try {
      debugPrint('🗑️ ========== DELETE MEAL PLAN START ==========');
      debugPrint('   Recipe ID: ${widget.recipeId}');
      debugPrint('   Household ID: ${widget.householdId}');
      debugPrint('   Meal Plan Date: ${widget.mealPlanDate}');
      debugPrint('   Meal Type: ${widget.mealType}');

      // Find and delete the meal plan document
      // Use date range only in query, filter other fields in code to avoid index requirement
      final startOfDay = DateTime.parse(widget.mealPlanDate);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startTimestamp = Timestamp.fromDate(startOfDay);
      final endTimestamp = Timestamp.fromDate(endOfDay);

      debugPrint('   Start: $startTimestamp');
      debugPrint('   End: $endTimestamp');

      final mealPlanSnapshot = await FirebaseFirestore.instance
          .collection('households')
          .doc(widget.householdId)
          .collection('meal_plans')
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThan: endTimestamp)
          .get();

      debugPrint(
          '   Found ${mealPlanSnapshot.docs.length} meal plans on this date');

      // Filter by meal_type and recipe_id in code
      final matchingDocs = mealPlanSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['meal_type'] == widget.mealType &&
            data['local_recipe_id'] == widget.recipeId;
      }).toList();

      debugPrint(
          '   Found ${matchingDocs.length} meal plans matching all criteria');

      if (matchingDocs.isEmpty) {
        debugPrint('⚠️ No meal plan found with these criteria');

        debugPrint(
            '   Total meal plans on this date: ${mealPlanSnapshot.docs.length}');
        for (var doc in mealPlanSnapshot.docs) {
          final data = doc.data();
          debugPrint('   - Doc ID: ${doc.id}');
          debugPrint('     meal_type: ${data['meal_type']}');
          debugPrint('     local_recipe_id: ${data['local_recipe_id']}');
          debugPrint('     date: ${data['date']}');
        }

        // Check ALL meal plans in this household (no date filter)
        final allMealPlansInHousehold = await FirebaseFirestore.instance
            .collection('households')
            .doc(widget.householdId)
            .collection('meal_plans')
            .get();

        debugPrint(
            '   🏠 Total meal plans in entire household: ${allMealPlansInHousehold.docs.length}');
        for (var doc in allMealPlansInHousehold.docs) {
          final data = doc.data();
          debugPrint('   - Doc ID: ${doc.id}');
          debugPrint('     meal_type: ${data['meal_type']}');
          debugPrint('     local_recipe_id: ${data['local_recipe_id']}');
          debugPrint('     date: ${data['date']}');
        }
      }

      for (var doc in matchingDocs) {
        await doc.reference.delete();
        debugPrint('✅ Deleted meal plan: ${doc.id}');
      }

      debugPrint('🗑️ ========== DELETE MEAL PLAN END ==========');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(matchingDocs.isEmpty
                ? 'Meal plan not found'
                : 'Meal plan deleted'),
            backgroundColor:
                matchingDocs.isEmpty ? Colors.orange : const Color(0xFF214130),
          ),
        );
        // ✅ Call callback to refresh parent screen
        widget.onDeleted?.call();
        Navigator.pop(context); // Go back to previous screen
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting meal plan: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting meal plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Hiển thị loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.pop(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Hiển thị error state
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.pop(context))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Hiển thị detail với data từ Firebase
    final title = recipeData?['title'] ?? 'Unknown Recipe';
    final readyInMinutes = recipeData?['ready_in_minutes'] ?? 0;
    final difficulty = recipeData?['difficulty'] ?? 'Medium';
    final calories = recipeData?['calories'] ?? 0;
    final imageUrl = recipeData?['image_url'] ??
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= IMAGE HEADER =================
          SizedBox(
            height: 320,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),

          // ================= TOP BUTTONS =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  _CircleButton(
                    icon: Icons.delete_outline,
                    onTap: () {
                      debugPrint('🔵 Delete icon tapped');
                      _showDeleteDialog();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ================= CONTENT SHEET =================
          DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.72,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= TITLE =================
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= TAGS =================
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.schedule,
                            text: "$readyInMinutes Mins",
                            bgColor: const Color(0xFFE9F5EC),
                            textColor: const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.flash_on,
                            text: difficulty,
                            bgColor: const Color(0xFFFFF1E6),
                            textColor: const Color(0xFFF57C00),
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.local_fire_department,
                            text: "${(calories * servings).toInt()} Kcal",
                            bgColor: const Color(0xFFE8F0FE),
                            textColor: const Color(0xFF1A73E8),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ================= INGREDIENTS =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (servings > 1) {
                                    setState(() => servings--);
                                    // ✅ Call after setState to use updated value
                                    _updateMealPlanServings(servings);
                                  }
                                },
                              ),
                              Text("$servings Servings"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() => servings++);
                                  // ✅ Call after setState to use updated value
                                  _updateMealPlanServings(servings);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ...ingredients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        // ✅ Calculate scaled amount based on servings
                        final originalAmount = item["amount"] as double;
                        final scaledAmount =
                            (originalAmount * servings / originalServings);
                        final displayAmount = scaledAmount % 1 == 0
                            ? scaledAmount.toInt().toString()
                            : scaledAmount.toStringAsFixed(1);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item["checked"],
                                activeColor: const Color(0xFF214130),
                                onChanged: (val) {
                                  setState(() {
                                    ingredients[index]["checked"] = val;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  '$displayAmount ${item["unit"]} ${item["name"]}',
                                ),
                              ),
                              if (item["inFridge"])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9F5EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "In Fridge",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ================= INSTRUCTIONS =================
                      const Text(
                        "Instructions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...instructions.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _InstructionStep(
                                number: e.key + 1,
                                text: e.value,
                              ),
                            ),
                          ),

                      const SizedBox(height: 100), // space for button
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//

// ======================= SMALL WIDGETS =======================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF214130),
            shape: BoxShape.circle,
          ),
          child: Text(
            "$number",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(height: 1.5),
          ),
        ),
      ],
    );
  }
}
