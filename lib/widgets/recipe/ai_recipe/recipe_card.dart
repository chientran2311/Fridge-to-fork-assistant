import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Import đúng file model HouseholdRecipe của bạn
// (Hãy đảm bảo đường dẫn import này đúng với cấu trúc thư mục của bạn)
import '../../../models/household_recipe.dart'; 
import '../../../screens/recipe/detail_recipe.dart';

class RecipeCard extends StatelessWidget {
  // 2. Thay đổi kiểu dữ liệu thành HouseholdRecipe
  final HouseholdRecipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // --- SETUP MÀU SẮC & BADGE ---
    final mainColor = const Color(0xFF1B3B36);
    
    String matchTag;
    IconData tagIcon;
    Color badgeColor;
    Color badgeBgColor;

    // Sử dụng field missedIngredientCount có sẵn trong HouseholdRecipe
    if (recipe.missedIngredientCount == 0) {
      matchTag = "Đủ nguyên liệu";
      tagIcon = Icons.check_circle_outline;
      badgeColor = const Color(0xFF0FBD3B); // Xanh lá
      badgeBgColor = const Color(0xFFE7F9EC);
    } else {
      matchTag = "Thiếu ${recipe.missedIngredientCount} món";
      tagIcon = Icons.shopping_basket_outlined;
      badgeColor = const Color(0xFFF2994A); // Cam
      badgeBgColor = const Color(0xFFFEF5EA);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Truyền ID hoặc cả object sang màn hình chi tiết
            builder: (context) => const RecipeDetailScreen(), 
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ẢNH MÓN ĂN ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    // 3. XỬ LÝ IMAGE URL (Vì trong model nó là String?)
                    child: (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                        ? Image.network(
                            recipe.imageUrl!, // Dấu ! để khẳng định nó không null
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(color: Colors.grey[100]);
                            },
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(), // Nếu null thì hiện ảnh giữ chỗ
                  ),
                ),
                
                // Badge Match
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(tagIcon, size: 14, color: badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          matchTag,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
                        ),
                      ],
                    ),
                  ),
                ),

                // Icon Tim
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),

            // --- THÔNG TIN ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title, // Field title là required nên an tâm dùng
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMiniChip(
                        icon: Icons.kitchen,
                        text: "Có ${recipe.usedIngredientCount} món",
                        color: Colors.blueGrey,
                        bgColor: Colors.blueGrey.withOpacity(0.1),
                      ),

                      if (recipe.missedIngredientCount > 0)
                        _buildMiniChip(
                          icon: Icons.shopping_cart_outlined,
                          text: "Mua ${recipe.missedIngredientCount} món",
                          color: const Color(0xFFF2994A),
                          bgColor: const Color(0xFFFEF5EA),
                        ),
                        
                      // Nếu có calo thì hiện thêm (Vì field này nullable)
                      if (recipe.calories != null)
                         _buildMiniChip(
                          icon: Icons.local_fire_department,
                          text: "${recipe.calories!.toInt()} Kcal",
                          color: Colors.redAccent,
                          bgColor: Colors.red.withOpacity(0.1),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị ảnh giữ chỗ nếu không có ảnh hoặc lỗi ảnh
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fastfood, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text("Không có ảnh", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniChip({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}