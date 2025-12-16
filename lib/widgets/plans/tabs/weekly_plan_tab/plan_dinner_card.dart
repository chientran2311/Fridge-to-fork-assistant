import 'package:flutter/material.dart';
import '../../../../utils/responsive_ui.dart';


//
// ---------------- PLAN DINNER CARD ----------------
//

class PlanDinnerCard extends StatelessWidget {
  const PlanDinnerCard();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return AspectRatio(
      aspectRatio: isDesktop ? 2.6 : 1.8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(height: 8),
            Text(
              "Plan Dinner",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Use ingredients expiring soon\nor get AI suggestions.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: null,
              child: Text("+ Add Meal"),
            ),
          ],
        ),
      ),
    );
  }
}