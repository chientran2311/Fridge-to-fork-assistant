import 'package:flutter/material.dart';
import '../tabs/weekly_plan_tab/add_item_overlay.dart';


const _primaryColor = Color(0xFF214130);

class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: _primaryColor,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 🔴 rất quan trọng
          backgroundColor: Colors.transparent,
          builder: (_) => const AddItemBottomSheet(),
        );
      },
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }
}
