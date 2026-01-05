/// ============================================
/// RECIPE CARD WIDGET - RECIPE DISPLAY COMPONENT
/// ============================================
/// 
/// Displays a single recipe in card format for AI Recipe screen.
/// 
/// Features:
/// - Recipe image with gradient overlay
/// - Title and cooking time display
/// - Ingredient match indicator (full match badge)
/// - Favorite toggle button
/// - Tap to view recipe details
/// 
/// Visual States:
/// - Full match: Green "Full Match" badge
/// - Partial match: Shows missing ingredient count
/// - Favorite: Filled heart icon
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/household_recipe.dart';
import '../../../providers/recipe_provider.dart';

/// Card widget displaying recipe information
class RecipeCard extends StatelessWidget {
  final HouseholdRecipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Check if all ingredients are available
    final bool isFullMatch = recipe.missedIngredientCount == 0;

    // Listen to favorite state changes
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final isFavorite = recipeProvider.isFavorite(recipe.apiRecipeId);

    return GestureDetector(
      onTap: () {
        // Navigate to recipe detail screen
        context.go('/recipes/detail', extra: recipe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Ảnh món ăn
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      recipe.imageUrl ?? "https://via.placeholder.com/400",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                    ),
                  ),
                ),

                // Badge Match
                if (isFullMatch)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text("100% Match", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800])),
                        ],
                      ),
                    ),
                  ),

                // --- [CẬP NHẬT] NÚT TIM ---
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () {
                      // Gọi hàm toggle trong Provider
                      recipeProvider.toggleFavorite(recipe, context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // ... (Phần nội dung bên dưới giữ nguyên) ...
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B3B36),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ... Các widget con khác giữ nguyên ...
                   Row(
                    children: [
                      _buildInfoChip(Icons.access_time, "${recipe.readyInMinutes ?? 30} min"),
                      const SizedBox(width: 8),
                      if (recipe.missedIngredientCount > 0)
                        _buildInfoChip(
                          Icons.shopping_bag_outlined, 
                          "Thiếu: ${recipe.missedIngredientCount}",
                          isHighlight: true,
                        )
                      else 
                         _buildInfoChip(Icons.check, "Đủ đồ", isSuccess: true),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ... Helper _buildInfoChip giữ nguyên ...
   Widget _buildInfoChip(IconData icon, String text, {bool isHighlight = false, bool isSuccess = false}) {
    Color bgColor = Colors.grey[100]!;
    Color textColor = Colors.grey[800]!;
    Color iconColor = Colors.grey[600]!;

    if (isHighlight) {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange[800]!;
      iconColor = Colors.orange[800]!;
    } else if (isSuccess) {
      bgColor = Colors.green[50]!;
      textColor = Colors.green[800]!;
      iconColor = Colors.green[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }
}