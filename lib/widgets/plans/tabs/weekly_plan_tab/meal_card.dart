import 'package:flutter/material.dart';
import 'tag.dart';
import '../../../../screens/meal&plan/planner/planner_detail_screen.dart';
//
// ---------------- MEAL CARD ----------------
//

class MealCard extends StatelessWidget {
  final String label;
  final String title;
  final double kcal;
  final String recipeId; // ✅ Thêm recipe ID
  final String householdId; // ✅ Thêm household ID
  final String mealPlanDate; // ✅ Thêm ngày meal plan
  final String mealType; // ✅ Thêm meal type để biết thứ tự
  final String? imageUrl; // ✅ Thêm image URL
  final int mealPlanServings; // ✅ Servings từ meal_plan
  final VoidCallback? onDeleted; // ✅ Callback when deleted

  const MealCard({
    required this.label,
    required this.title,
    required this.kcal,
    required this.recipeId,
    required this.householdId,
    required this.mealPlanDate,
    required this.mealType,
    this.imageUrl,
    this.mealPlanServings = 1,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // ✅ Sử dụng ROOT Navigator để ẩn bottom navigation bar
        Navigator.of(context, rootNavigator: true)
            .push(
          MaterialPageRoute(
            builder: (_) => PlannerDetailScreen(
              recipeId: recipeId,
              householdId: householdId,
              mealPlanDate: mealPlanDate,
              mealType: mealType,
              mealPlanServings:
                  mealPlanServings, // ✅ Pass servings from meal_plan
              onDeleted: onDeleted, // ✅ Pass callback
            ),
          ),
        )
            .then((_) {
          // ✅ Refresh when returning from detail screen
          if (onDeleted != null) {
            onDeleted!();
          }
        });
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl ??
                        "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 130,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Tag(text: label),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${kcal.toInt()} kcal / serving",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
