import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_home.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_barcode_scan.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/icon_box.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/search_bar_with_filter.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/category_chips.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/ingredient_list_item.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/filter_modal.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/add_ingredient_sheet.dart';

class FridgeAddIngredients extends StatefulWidget {
  const FridgeAddIngredients({super.key});

  @override
  State<FridgeAddIngredients> createState() => _FridgeAddIngredientsState();
}

class _FridgeAddIngredientsState extends State<FridgeAddIngredients> {
  final mainColor = const Color(0xFF214130);

  final items = [
    'Orange',
    'Pork',
    'Beef',
    'Milk',
    'Chicken egg',
    'Shrimp',
    'Cheese',
    'Tangerine',
  ];

  final categories = ['Dairy', 'Vegetable', 'Protein', 'Fruit', 'Flour'];

  final filterCategories = [
    'Dairy',
    'Vegetable',
    'Protein',
    'Carbs',
    'Alcohol',
    'Oil',
    'Fruits',
    'Drinks',
    'Snacks',
    'Sauce',
  ];

  Set<String> selectedFilters = {};

  void showFilterModal() async {
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (BuildContext context) {
        return FilterModal(
          filterCategories: filterCategories,
          initialSelectedFilters: selectedFilters,
          mainColor: mainColor,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedFilters = result;
      });
    }
  }

  void showAddIngredientSheet(String itemName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddIngredientSheet(
          itemName: itemName,
          mainColor: mainColor,
          onSuccess: showSuccessSnackbar,
        );
      },
    );
  }

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Item added successfully!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with back and QR icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconBox(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FridgeHomeScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: mainColor,
                      ),
                    ),
                  ),
                  // QR scan code button
                  IconBox(
                    child: TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FridgeBarcodeScanScreen(),
                          ),
                        );

                        if (result != null) {
                          print("Barcode scanned: $result");

                          // Chuyển sang Add Ingredients Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FridgeAddIngredients(),
                            ),
                          );
                        }
                      },
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 20,
                        color: mainColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Search + Filter row
              SearchBarWithFilter(
                onFilterPressed: showFilterModal,
                mainColor: mainColor,
              ),

              const SizedBox(height: 12),

              // Categories chips
              CategoryChips(categories: categories),

              const SizedBox(height: 12),

              // Ingredients list
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final name = items[index];
                    return IngredientListItem(
                      name: name,
                      mainColor: mainColor,
                      onAddPressed: () => showAddIngredientSheet(name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}