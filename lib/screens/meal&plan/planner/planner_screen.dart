import 'package:flutter/material.dart';

import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/screens/meal&plan/tabs/weekly_plan/weekly_plan_tab.dart';
import 'package:fridge_to_fork_assistant/screens/meal&plan/tabs/shopping_list/shopping_list_tab.dart';
import 'package:go_router/go_router.dart';
// Import Localization
import 'package:fridge_to_fork_assistant/l10n/app_localizations.dart';

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
    // ✅ 1. Lấy ngôn ngữ (Safe Mode)
    final s = AppLocalizations.of(context);

    // Chuẩn bị text an toàn
    final titleText = s?.planTab ?? "Planner";
    final weeklyPlanText = s?.weeklyPlan ?? "Weekly Plan";
    final shoppingListText = s?.shoppingList ?? "Shopping List";

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: isDesktop
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: _bgColor,
              title: Text(
                titleText, // ✅ Dùng biến đa ngôn ngữ
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    context.push('/recipes/favorites');
                  },
                  color: const Color(0xFFE63946),
                  tooltip: 'Favorite Recipes',
                ),
              ],
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 TABS (Fixed at top)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _Tabs(
                  currentTab: _currentTab,
                  onChanged: _onTabChanged,
                  weeklyPlanText: weeklyPlanText,
                  shoppingListText: shoppingListText,
                ),
              ),

              const SizedBox(height: 24),

              // 🔥 SWITCH CONTENT (Takes remaining space)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _currentTab == PlannerTab.weeklyPlan
                      ? const WeeklyPlanContent()
                      : ShoppingListTab(key: shoppingListGlobalKey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final PlannerTab currentTab;
  final ValueChanged<PlannerTab> onChanged;

  // ✅ Nhận text từ cha
  final String weeklyPlanText;
  final String shoppingListText;

  const _Tabs({
    required this.currentTab,
    required this.onChanged,
    required this.weeklyPlanText,
    required this.shoppingListText,
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
            text: weeklyPlanText, // ✅ Hiển thị text
            active: currentTab == PlannerTab.weeklyPlan,
            onTap: () => onChanged(PlannerTab.weeklyPlan),
          ),
          _TabButton(
            text: shoppingListText, // ✅ Hiển thị text
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

