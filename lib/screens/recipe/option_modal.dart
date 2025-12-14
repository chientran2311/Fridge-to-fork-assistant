import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'share_recipe_modal.dart';
class OptionModal extends StatelessWidget {
  const OptionModal({super.key});

  // --- HÀM STATIC GỌI MODAL RESPONSIVE ---
  static void show(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      // WEB: Hiện Dialog giữa màn hình
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => const Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 400, // Chiều rộng cố định cho Web
            child: OptionModal(),
          ),
        ),
      );
    } else {
      // MOBILE: Hiện BottomSheet từ dưới lên
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => const OptionModal(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final Color mainColor = const Color(0xFF1B3B36); // Xanh rêu đậm
    final Color bgGrey = const Color(0xFFF8F9FA); // Màu nền xám nhạt của nút

    // Bo góc tùy theo thiết bị
    final BorderRadius borderRadius = isDesktop
        ? BorderRadius.circular(24)
        : const BorderRadius.vertical(top: Radius.circular(24));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tự co lại theo nội dung
        children: [
          // 1. Handle Bar (Chỉ hiện trên Mobile)
          if (!isDesktop)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // 2. Title & Subtitle
          Text(
            "Recipe Options",
            style: GoogleFonts.merriweather(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select an action for this recipe",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Option Buttons
          _buildOptionButton(
            icon: Icons.ios_share,
            title: "Share Recipe",
            subtitle: "Send to friends or family",
            mainColor: mainColor,
            bgColor: bgGrey,
            onTap: () {
              // 1. Đóng Option Modal trước
              Navigator.pop(context);

              // 2. Mở Share Modal ngay sau đó
              // (Dùng Future.delayed nhỏ để animation mượt hơn nếu cần, hoặc gọi luôn)
              Future.delayed(const Duration(milliseconds: 100), () {
                ShareModal.show(context,
                    url: "https://fridge2fork.app/recipe/creamy-pesto");
              });
            },
          ),
          const SizedBox(height: 16),
          _buildOptionButton(
            icon: Icons.favorite_border,
            title: "Save to favorite recipe",
            subtitle: "Access quickly from plan",
            mainColor: mainColor,
            bgColor: bgGrey,
            onTap: () {
              // Logic Save
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 32),

          // 4. Cancel Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: bgGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // --- Widget Con: Nút chức năng ---
  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color mainColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Icon Circle
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: mainColor, size: 22),
            ),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
