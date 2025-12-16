import 'package:flutter/material.dart';
// Import các widget và màn hình con
import '../widgets/recipe/bottom_nav.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_home.dart';
import 'package:fridge_to_fork_assistant/screens/recipe/ai_recipe.dart';
import 'package:fridge_to_fork_assistant/screens/meal&plan/planner_screen.dart';

// Màn hình Plan tạm thời (nếu chưa có)
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Plan Screen")));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Mặc định index = 0 là Fridge Home sẽ hiện ra đầu tiên sau khi Login
  int _currentIndex = 0;

  // Danh sách các màn hình con
  final List<Widget> _pages = [
    const FridgeHomeScreen(), // Index 0: Tủ lạnh
    const AIRecipeScreen(),   // Index 1: Công thức AI
    const PlannerScreen(),       // Index 2: Plan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giữ trạng thái của các màn hình con (không bị load lại khi chuyển tab)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // BottomNav nằm cố định ở MainScreen
      bottomNavigationBar: BottomNav(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}