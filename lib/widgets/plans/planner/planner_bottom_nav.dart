import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: "Fridge"),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Recipes"),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Plan",
        ),
      ],
    );
  }
}