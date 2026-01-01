import 'package:flutter/material.dart';


//
// ---------------- DAY ITEM ----------------
//

class DayItem extends StatelessWidget {
  final String day;
  final String date;
  final bool active;
  final bool hasMealPlan;

  const DayItem({
    required this.day,
    required this.date,
    this.active = false,
    this.hasMealPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active 
          ? const Color(0xFF214130) 
          : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // ✅ Green dot indicator for meal plan (always shown at bottom)
          if (hasMealPlan)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 6, height: 6), // ✅ Keep spacing consistent
        ],
      ),
    );
  }
}