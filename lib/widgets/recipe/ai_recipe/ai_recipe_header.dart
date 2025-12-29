import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:fridge_to_fork_assistant/screens/recipe/filter_modal.dart';

// Import các Provider chứa dữ liệu
import 'package:fridge_to_fork_assistant/providers/recipe_provider.dart';
import 'package:fridge_to_fork_assistant/providers/inventory_provider.dart';

class AIRecipeHeader extends StatelessWidget {
  const AIRecipeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Row (Giữ nguyên) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trợ lý Công Thức AI",
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  FilterModal.show(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(Icons.tune, size: 20, color: mainColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Green Summary Banner (ĐÃ CẬP NHẬT DYNAMIC DATA) ---
          Consumer2<RecipeProvider, InventoryProvider>(
            builder: (context, recipeProvider, inventoryProvider, child) {
              // 1. Lấy số lượng công thức AI đã tìm thấy
              final int recipeCount = recipeProvider.recipes.length;
              
              // 2. Lấy số lượng nguyên liệu thực tế đang có trong tủ lạnh
              final int ingredientCount = inventoryProvider.items.length;

              // Logic hiển thị văn bản
              String titleText = "Found $recipeCount recipes";
              if (recipeProvider.isLoading) {
                 titleText = "Searching for recipes...";
              } else if (recipeCount == 0 && !recipeProvider.isLoading) {
                 titleText = "No recipes found yet.";
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EFE5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(Icons.eco_outlined, color: mainColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: mainColor, fontSize: 13, height: 1.4),
                          children: [
                            TextSpan(
                                text: "$titleText to rescue your ingredients. "),
                            // Hiển thị số nguyên liệu thật đang được sử dụng/có sẵn
                            if (ingredientCount > 0)
                              TextSpan(
                                text: "Ready to cook with $ingredientCount items from your fridge!",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )
                            else
                              const TextSpan(
                                text: "Add items to your fridge to start!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}