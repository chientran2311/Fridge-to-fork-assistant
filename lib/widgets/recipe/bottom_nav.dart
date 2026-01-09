import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  // Biến để xác định tab nào đang được chọn (0: Fridge, 1: Recipes, 2: Plan)
  final int selectedIndex;
  // Hàm callback để xử lý khi bấm vào icon
  final Function(int) onItemTapped;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF1B3B36); // Màu xanh rêu đậm
    final Color inactiveColor = Colors.grey.shade400;  // Màu xám nhạt
    final s = AppLocalizations.of(context);

    return Container(
      // Trang trí nền trắng và viền mỏng phía trên
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200, // Đường kẻ mảnh màu xám
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // Không cần safe area ở trên
        child: Container(
          height: 65, // Chiều cao chuẩn của thanh nav
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Căn đều khoảng cách
            children: [
              // --- Tab 1: Fridge ---
              _buildNavItem(
                index: 0,
                icon: Icons.kitchen_outlined, // Icon tủ lạnh
                label: s?.fridge ?? "Fridge",
                isActive: selectedIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),

              // --- Tab 2: Recipes (Dao dĩa chéo nhau) ---
              _buildNavItem(
                index: 1,
                icon: Icons.restaurant_menu, // Icon dao dĩa chéo (Chuẩn y hệt ảnh)
                label: s?.recipes ?? "Recipes",
                isActive: selectedIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),

              // --- Tab 3: Plan (Lịch) ---
              _buildNavItem(
                index: 2,
                icon: Icons.calendar_today_outlined, // Icon lịch
                label: s?.plan ?? "Plan",
                isActive: selectedIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget con: Từng mục điều hướng ---
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(12), // Hiệu ứng bấm tròn nhẹ
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26, // Kích thước icon vừa vặn
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4), // Khoảng cách giữa icon và chữ
            Text(
              label,
              style: GoogleFonts.inter( // Dùng font Inter hoặc Merriweather tùy ý
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}