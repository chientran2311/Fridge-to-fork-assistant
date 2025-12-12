import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class SidebarWidget extends StatelessWidget {
  final int selectedIndex;
  // Callback để báo cho cha biết khi user click menu
  final Function(int) onItemSelected;

  const SidebarWidget({
    super.key, 
    this.selectedIndex = 0,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text("3tocom", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          
          // Menu Items
          _buildMenuItem(0, "Tổng quan", Icons.dashboard),
          _buildMenuItem(1, "Người dùng", Icons.people_outline),
          _buildMenuItem(2, "API", Icons.storage_outlined),
          _buildMenuItem(3, "Kho Nguyên liệu", Icons.kitchen_outlined),
          _buildMenuItem(4, "Báo cáo & Thống kê", Icons.bar_chart),
          
          const Spacer(),
          
          // User Profile Bottom
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Admin User", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Super Admin", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final bool isActive = index == selectedIndex;
    
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: AppColors.primaryGreen, width: 4)))
            : null,
        child: ListTile(
          leading: Icon(icon, color: isActive ? AppColors.primaryGreen : AppColors.textGrey),
          title: Text(title,
              style: TextStyle(
                  color: isActive ? AppColors.primaryGreen : AppColors.textGrey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}