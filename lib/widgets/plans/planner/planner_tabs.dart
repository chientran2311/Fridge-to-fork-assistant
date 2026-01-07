import 'package:flutter/material.dart';

enum PlannerTab { weeklyPlan, shoppingList }


const _primaryColor = Color(0xFF214130);

class Tabs extends StatelessWidget {
  final PlannerTab currentTab;
  final ValueChanged<PlannerTab> onChanged;

  const Tabs({
    required this.currentTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabButton(
            text: "Weekly Plan",
            active: currentTab == PlannerTab.weeklyPlan,
            onTap: () => onChanged(PlannerTab.weeklyPlan),
          ),
          _TabButton(
            text: "Shopping List",
            active: currentTab == PlannerTab.shoppingList,
            onTap: () => onChanged(PlannerTab.shoppingList),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}