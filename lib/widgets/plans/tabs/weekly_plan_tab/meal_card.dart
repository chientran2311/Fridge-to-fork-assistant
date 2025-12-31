import 'package:flutter/material.dart';
import 'tag.dart';
import '../../../../screens/meal&plan/planner/planner_detail_screen.dart';
//
// ---------------- MEAL CARD ----------------
//

class MealCard extends StatelessWidget {
  final String label;
  final String title;
  final int kcal;
  final String recipeId; // ✅ Thêm recipe ID
  final String householdId; // ✅ Thêm household ID
  final String mealPlanDate; // ✅ Thêm ngày meal plan

  const MealCard({
    required this.label,
    required this.title,
    required this.kcal,
    required this.recipeId,
    required this.householdId,
    required this.mealPlanDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlannerDetailScreen(
              recipeId: recipeId,
              householdId: householdId,
              mealPlanDate: mealPlanDate,
            ),
          ),
        );
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
                    "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Tag(text: label),
                ),
                const Positioned(
                  bottom: 12,
                  right: 12,
                  child: Tag(text: "High Waste", filled: true),
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
                          "$kcal kcal",
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
