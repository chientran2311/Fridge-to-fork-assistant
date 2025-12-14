
import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'add_item_overlay.dart';
import 'weekly_plan_tab.dart';
import 'shopping_list_tab.dart';

const _bgColor = Color(0xFFF4F6F4);
const _primaryColor = Color(0xFF214130);

/// 🔑 ENUM TAB
enum PlannerTab { weeklyPlan, shoppingList }

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  PlannerTab _currentTab = PlannerTab.weeklyPlan;

  void _onTabChanged(PlannerTab tab) {
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: _bgColor,

      appBar: isDesktop
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: _bgColor,
              title: const Text(
                "Planner",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: const [
                Icon(Icons.settings, color: Colors.black),
                SizedBox(width: 8),
              ],
            ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 TABS
                _Tabs(
                  currentTab: _currentTab,
                  onChanged: _onTabChanged,
                ),

                const SizedBox(height: 24),

                /// 🔥 SWITCH CONTENT (KHÔNG PUSH SCREEN)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _currentTab == PlannerTab.weeklyPlan
                      ? const WeeklyPlanContent()
                      : const ShoppingListTab(),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: isDesktop ? null : const _BottomNav(),
      floatingActionButton: isDesktop ? null : const _FloatingAddButton(),
    );
  }
}
class _Tabs extends StatelessWidget {
  final PlannerTab currentTab;
  final ValueChanged<PlannerTab> onChanged;

  const _Tabs({
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


class _BottomNav extends StatelessWidget {
  const _BottomNav();

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

class _FloatingAddButton extends StatelessWidget {
  const _FloatingAddButton();

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


