import 'package:flutter/material.dart';



//
// ---------------- SHOPPING LIST ----------------
//

class ShoppingList extends StatelessWidget {
  const ShoppingList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quick Shopping List",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("View All", style: TextStyle(color: Colors.grey)),
          ],
        ),
        SizedBox(height: 12),
        ListTile(
          leading: Checkbox(value: true, onChanged: null),
          title: Text("Spinach"),
          subtitle: Text("Produce • 2x"),
        ),
        ListTile(
          leading: Checkbox(value: false, onChanged: null),
          title: Text("Pasta"),
          subtitle: Text("Dairy • 1x"),
        ),
      ],
    );
  }
}