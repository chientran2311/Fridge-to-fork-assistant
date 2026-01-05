/// ============================================
/// AI RECIPE HEADER WIDGET
/// ============================================
/// 
/// Header component for AI Recipe screen with search and filter.
/// 
/// Features:
/// - Title and subtitle display
/// - Filter button to open FilterModal
/// - Active filter indicator
/// - Search trigger functionality
/// 
/// Interactions:
/// - Tap filter icon: Opens FilterModal
/// - Apply filter: Updates RecipeProvider and triggers search
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../screens/recipe/filter_modal.dart';
import '../../../models/RecipeFilter.dart';
import '../../../providers/recipe_provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Header widget with filter functionality for AI Recipe screen
class AIRecipeHeader extends StatelessWidget {
  const AIRecipeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);
    final s = AppLocalizations.of(context)!;
    
    /// Open filter modal and apply selected filters
    Future<void> _openFilterModal() async {
      final recipeProvider =
          Provider.of<RecipeProvider>(context, listen: false);

      // Open modal with current filter state
      final RecipeFilter? result =
          await FilterModal.show(context, recipeProvider.currentFilter);

      // Apply filter if user confirmed
      if (result != null) {
        recipeProvider.updateFilter(result);
      }
    }

    // Get current filter from Provider
    final currentFilter =
        context.select<RecipeProvider, RecipeFilter>((p) => p.currentFilter);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.recipeTab,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _openFilterModal();
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

          // --- Green Summary Banner (Giữ nguyên logic của bạn) ---
          Consumer2<RecipeProvider, InventoryProvider>(
            builder: (context, recipeProvider, inventoryProvider, child) {
              final int recipeCount = recipeProvider.recipes.length;
              final int ingredientCount = inventoryProvider.items.length;

              // ✅ Sử dụng localization
              String titleText = s.foundRecipes(recipeCount);
              if (recipeProvider.isLoading) {
                titleText = s.searchingRecipes;
              } else if (recipeCount == 0 && !recipeProvider.isLoading) {
                titleText = s.noRecipesFound;
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
                          style: GoogleFonts.merriweather(
                              color: mainColor, fontSize: 13, height: 1.4),
                          children: [
                            TextSpan(text: "$titleText${s.rescueIngredients}"),
                            if (ingredientCount > 0)
                              TextSpan(
                                text: s.readyToCook(ingredientCount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            else
                              TextSpan(
                                text: s.addItemsToStart,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
