import 'package:flutter/material.dart';
import '../../widgets/settings/setting_item.dart';
import '../../web/main.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Định nghĩa màu sắc theo yêu cầu
  final Color backgroundColor = const Color(0xFFF0F1F1);
  final Color darkGreenColor = const Color(0xFF1B3B36); // Màu xanh đậm của text/icon
  final Color dividerColor = const Color(0xFFE7EAE9);
  final Color redColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình để tính toán padding 10%
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Header (Nút Back và Text Setting) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: darkGreenColor),
                    onPressed: () => Navigator.pop(context), // Quay lại màn hình trước
                  ),
                  const SizedBox(width: 8), // Khoảng cách giữa icon và text
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: darkGreenColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Serif', // Bỏ comment nếu bạn muốn dùng font Serif giống ảnh
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. List các chức năng ---
            Expanded(
              child: ListView(
                children: [
                  SettingItem(
                    icon: Icons.language,
                    title: "Language",
                    textColor: darkGreenColor,
                    onTap: () {
                      
                    },
                  ),
                  SettingItem(
                    icon: Icons.notifications_outlined,
                    title: "Notification",
                    textColor: darkGreenColor,
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.share_outlined,
                    title: "Invite friend",
                    textColor: darkGreenColor,
                    onTap: () {},
                  ),
                  SettingItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: "Web admin",
                    textColor: darkGreenColor,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BepTroLyApp(),
                        ),
                       );
                    },
                  ),
                  SettingItem(
                    icon: Icons.logout,
                    title: "Log out",
                    textColor: darkGreenColor,
                    onTap: () {
                      // Logic đăng xuất
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- 3. Dòng kẻ phân cách (Divider) ---
                  // Padding left & right 10% so với chiều rộng màn hình
                  Divider(
                    color: dividerColor,
                    thickness: 1.5,
                    indent: screenWidth * 0.10,    // Cách trái 10%
                    endIndent: screenWidth * 0.10, // Cách phải 10%
                  ),

                  const SizedBox(height: 10),

                  // --- 4. Delete Account (Màu đỏ) ---
                  SettingItem(
                    icon: Icons.delete_outline,
                    title: "Delete account",
                    textColor: redColor, // Chữ và Icon màu đỏ
                    isBold: true,
                    onTap: () {
                      // Logic xóa tài khoản
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget chung để tạo từng dòng setting (Giúp code gọn hơn)
}