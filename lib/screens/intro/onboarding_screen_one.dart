import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_ui.dart';

/// Widget nội dung cho trang onboarding 1 (dùng trong PageView)
/// Không có Scaffold, SafeArea, top bar hay pagination dots
class OnboardingContentOne extends StatelessWidget {
  const OnboardingContentOne({super.key});

  // --- MÀU SẮC THEME ---
  static const Color kPrimaryColor = Color(0xFF1B5E20);
  static const Color kTextColor = Color(0xFF1B3B36);
  static const Color kCardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // HERO SECTION: CARD MÔ PHỎNG TỦ LẠNH
          _buildVirtualFridgeCard(context),

          const SizedBox(height: 24),

          // TEXT SECTION: TIÊU ĐỀ & MÔ TẢ
          Text(
            "Tủ Lạnh Ảo\nThông Minh",
            textAlign: TextAlign.center,
            style: GoogleFonts.merriweather(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: context.percentWidth(80),
            child: Text(
              "Theo dõi nguyên liệu dễ dàng. Biết chính xác bạn đang có gì mà không cần mở tủ lạnh.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- WIDGET CON: CARD MÔ PHỎNG ---
  Widget _buildVirtualFridgeCard(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight, // Để đặt nút + ở góc
      children: [
        // Container chính của Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
              bottom: 20, left: 10, right: 10), // Chừa chỗ cho nút +
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Co lại vừa nội dung
            children: [
              // Mock Handle Bar (Thanh ngang nhỏ trang trí)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header nhỏ trong Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tủ của tôi",
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  Text(
                    "...",
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
              Text(
                "12 NGUYÊN LIỆU",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 20),

              // Danh sách Item giả lập
              _buildMockItem(
                  icon: Icons.water_drop,
                  iconColor: Colors.blueAccent,
                  bgIconColor: Colors.blue[50]!,
                  name: "Sữa tươi",
                  quantity: "1 L"),
              const SizedBox(height: 12),
              _buildMockItem(
                  icon: Icons.eco, // Dùng tạm icon Eco thay cho quả bơ
                  iconColor: Colors.green,
                  bgIconColor: Colors.green[50]!,
                  name: "Bơ sáp",
                  quantity: "3 Quả"),
              const SizedBox(height: 12),
              _buildMockItem(
                  icon: Icons.egg_rounded,
                  iconColor: Colors.orange,
                  bgIconColor: Colors.orange[50]!,
                  name: "Trứng gà",
                  quantity: "12 Quả"),
            ],
          ),
        ),

        // Nút Floating Action Button giả lập
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  // --- WIDGET CON: ITEM TRONG LIST ---
  Widget _buildMockItem({
    required IconData icon,
    required Color iconColor,
    required Color bgIconColor,
    required String name,
    required String quantity,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7), // Màu nền xám rất nhạt cho item
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon tròn
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),

          // Tên món
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.merriweather(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextColor,
              ),
            ),
          ),

          // Số lượng (Chip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              quantity,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
