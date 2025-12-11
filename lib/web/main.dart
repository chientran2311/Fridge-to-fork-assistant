import 'package:flutter/material.dart';
import 'theme/app_color.dart';
import 'widgets/sidebar.dart';
import 'screens/dashboard.dart';
import 'screens/user.dart';
import 'screens/api.dart';
import 'screens/user_ingredients.dart';
import 'screens/statistic.dart';
void main() {
  runApp(const BepTroLyApp());
}

class BepTroLyApp extends StatelessWidget {
  const BepTroLyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bếp Trợ Lý Admin',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.white,
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Danh sách các màn hình (80% bên phải)
  final List<Widget> _screens = [
    const DashboardScreen(),        // Index 0: Dashboard (Import từ file dashboard_screen.dart)
    const UserManagementScreen(), // Index 1
    const ApiScreen(),        // Index 2
    const InventoryScreen(),        // Index 3
    const StatisticScreen(),    // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PHẦN 20%: SIDEBAR ---
          SizedBox(
            width: 250, // Cố định chiều rộng sidebar
            child: SidebarWidget(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          
          // --- PHẦN 80%: NỘI DUNG (MAIN CONTENT) ---
          Expanded(
            child: Container(
              color: AppColors.bgLightPink, // Màu nền chung
              // IndexedStack giúp giữ trạng thái màn hình khi chuyển tab
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ),
        ],
      ),
    );
  }
}