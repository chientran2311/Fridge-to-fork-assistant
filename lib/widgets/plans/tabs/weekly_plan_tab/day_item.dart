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
          : hasMealPlan 
            ? const Color(0xFFE8F5E9) // Xanh lá nhạt báo hiệu có meal plan
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasMealPlan && !active
          ? Border.all(color: const Color(0xFF4CAF50), width: 2)
          : null,
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
          if (hasMealPlan && !active) ...[
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}