import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/recipe/bottom_nav.dart'; // Đảm bảo import đúng

class MainScreen extends StatelessWidget {
  // Nhận navigationShell từ GoRouter truyền vào
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  // Hàm xử lý khi bấm vào BottomBar
  void _onItemTapped(int index) {
    // goBranch: Chuyển sang branch tương ứng (0, 1, 2)
    // initialLocation: index == current ? true : false -> Bấm lại tab đang đứng để reset về đầu trang
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body chính là navigationShell (Nó tự động render Fridge/Recipe/Plan tùy theo index)
      body: navigationShell, 
      
      // BottomNav của bạn
      bottomNavigationBar: BottomNav(
        selectedIndex: navigationShell.currentIndex, // Lấy index hiện tại từ Shell
        onItemTapped: _onItemTapped,
      ),
    );
  }
}