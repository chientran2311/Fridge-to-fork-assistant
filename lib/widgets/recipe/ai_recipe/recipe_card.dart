import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/household_recipe.dart';
import '../../../l10n/app_localizations.dart';
class RecipeCard extends StatelessWidget {
  final HouseholdRecipe recipe;
  
  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Xác định phần trăm match (Logic giả định: ít nguyên liệu thiếu = match cao)
    // Bạn có thể tùy chỉnh logic này
    final bool isFullMatch = recipe.missedIngredientCount == 0;
    
    return GestureDetector(
      onTap: () {
        context.go('/recipes/detail', extra: recipe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Bo góc lớn giống ảnh
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
            // --- PHẦN 1: HÌNH ẢNH + BADGE ---
            Stack(
              children: [
                // Ảnh món ăn
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10, // Tỷ lệ ảnh
                    child: Image.network(
                      recipe.imageUrl ?? "https://via.placeholder.com/400",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                    ),
                  ),
                ),

                // Badge "100% Match" (Góc trái trên)
                if (isFullMatch)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            "100% Match",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Nút Tim (Góc phải trên)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),

            // --- PHẦN 2: THÔNG TIN CHI TIẾT ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên món ăn
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B3B36), // Màu xanh đậm
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Mô tả ngắn (Nếu có description thì hiện, không thì hiện text mặc định)
                  Text(
                    "Món ngon hấp dẫn từ nguyên liệu có sẵn trong tủ lạnh của bạn.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),

                  const SizedBox(height: 16),

                  // Các Chips thông tin (Time, Calo, Missing)
                  Row(
                    children: [
                      // Chip 1: Thời gian
                      _buildInfoChip(
                        Icons.access_time, 
                        "${recipe.readyInMinutes ?? 30} min"
                      ),
                      
                      const SizedBox(width: 8),

                      // Chip 2: Calories
                      if (recipe.calories != null)
                        _buildInfoChip(
                          Icons.local_fire_department_outlined, 
                          "${recipe.calories!.toInt()} kcal"
                        ),

                      const SizedBox(width: 8),

                      // Chip 3: Missing Ingredients
                      if (recipe.missedIngredientCount > 0)
                        _buildInfoChip(
                          Icons.shopping_bag_outlined, 
                          "Missing: ${recipe.missedIngredientCount}",
                          isHighlight: true, // Highlight nếu thiếu đồ
                        )
                      else 
                        // Chip Match nếu đủ đồ
                         _buildInfoChip(
                          Icons.check, 
                          "Đủ đồ",
                          isSuccess: true,
                        ),
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

  // Helper Widget để vẽ các Chip nhỏ (Time, Kcal...)
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