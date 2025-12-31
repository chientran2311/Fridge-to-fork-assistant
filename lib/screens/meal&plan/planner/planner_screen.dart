
import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/recipe/favorite_recipes.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../../widgets/plans/tabs/weekly_plan_tab/add_item_overlay.dart';
import '../tabs/weekly_plan/weekly_plan_tab.dart';
import '../tabs/shopping_list/shopping_list_tab.dart';

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
    debugPrint('📱 PlannerScreen: Tab switched to ${tab.name}');
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️  PlannerScreen: build() called | currentTab: ${_currentTab.name}');
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
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoriteRecipesScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(Icons.favorite_border_outlined, size: 20, color: _primaryColor),
                  ),
                ),
              ],
            ),

      body: Column(
        children: [
          // ✅ Fixed tab bar at top (not scrollable)
          Container(
            color: _bgColor,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _Tabs(
                  currentTab: _currentTab,
                  onChanged: _onTabChanged,
                ),
              ),
            ),
          ),

          // ✅ Expandable scrollable content area
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IndexedStack(
                    index: _currentTab == PlannerTab.weeklyPlan ? 0 : 1,
                    children: [
                      WeeklyPlanContent(
                        key: const ValueKey('weekly'),
                        onTabChange: (tabIndex) {
                          if (tabIndex == 1) {
                            _onTabChanged(PlannerTab.shoppingList);
                          } else if (tabIndex == 0) {
                            _onTabChanged(PlannerTab.weeklyPlan);
                          }
                        },
                      ),
                      ShoppingListTab(key: const ValueKey('shopping')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      
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
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddItemBottomSheet(),
        );
      },
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }
}


