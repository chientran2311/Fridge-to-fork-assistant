import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/recipe/bottom_nav.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  // --- LOGIC MỚI: Kiểm tra xem có nên hiện BottomBar không ---
  bool _shouldShowBottomNav(BuildContext context) {
    // Lấy đường dẫn hiện tại từ GoRouter
    final String location = GoRouterState.of(context).uri.path;

    // Danh sách các đường dẫn "Gốc" (Root paths) mà bạn muốn hiện Menu
    // Bạn hãy thay thế bằng các path thực tế bạn đã config trong GoRouter
    const List<String> mainPaths = [
  '/fridge', 
  '/recipes', 
  '/planner', // Router bạn đặt là /planner nên ở đây cũng phải là /planner
  '/',     
];

    // Chỉ trả về true nếu đường dẫn hiện tại nằm trong danh sách mainPaths
    // Lưu ý: Nếu bạn vào chi tiết (ví dụ /recipes/detail), logic này trả về false -> Ẩn Nav
    return mainPaths.contains(location);
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán việc hiển thị trước
    final bool showBottomNav = _shouldShowBottomNav(context);

    return Scaffold(
      // Body vẫn giữ nguyên
      body: navigationShell,
      
      // Nếu showBottomNav là true thì vẽ BottomNav, ngược lại thì null (ẩn đi)
      bottomNavigationBar: showBottomNav 
          ? BottomNav(
              selectedIndex: navigationShell.currentIndex,
              onItemTapped: _onItemTapped,
            )
          : null, // Khi null, Scaffold sẽ tự động kéo body tràn xuống dưới
    );
  }
}