import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_home.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/recipe/ai_recipe.dart';
import '../../screens/meal&plan/shopping_plan_screen.dart';
class BottomNav extends StatelessWidget {
  final Color textColor;

  const BottomNav({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    // Không dùng navigatorColor cũ nữa, dùng màu trắng opacity như mẫu thiết kế mới
    return Container(
      // Tạo hiệu ứng nổi (Floating) cách lề dưới và 2 bên
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      // Padding bên trong để các nút không bị dính sát mép
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90), // Tăng opacity nhẹ để rõ hơn trên nền tạp
        borderRadius: BorderRadius.circular(40), // Bo tròn thành hình viên thuốc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Bóng đổ nhẹ nhàng
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều khoảng cách giữa các nút
        children: [
          AnimatedNavButton(
            icon: Icons.kitchen,
            label: "Fridge",
            color: textColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FridgeHomeScreen(),
                ),
              );
            },
          ),
          AnimatedNavButton(
            icon: Icons.menu_book_rounded,
            label: "AI Recipe",
            color: textColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiRecipeScreen(),
                ),
              );
            },
          ),
          AnimatedNavButton(
            icon: Icons.shopping_bag_outlined,
            label: "Plan&Shop",
            color: textColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShoppingPlanScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnimatedNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AnimatedNavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<AnimatedNavButton> createState() => _AnimatedNavButtonState();
}

class _AnimatedNavButtonState extends State<AnimatedNavButton> {
  double scale = 1.0;

  void _animate() async {
    setState(() => scale = 0.85); // Thu nhỏ nhẹ khi nhấn
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => scale = 1.0); // Trở về bình thường
    widget.onTap(); // Thực hiện hành động
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animate,
      behavior: HitTestBehavior.translucent, // Giúp vùng bấm nhạy hơn
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 28, // Kích thước icon chuẩn theo mẫu mới
              color: widget.color,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: GoogleFonts.merriweather(
                fontSize: 11, // Chữ nhỏ gọn gàng
                fontWeight: FontWeight.w500,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}