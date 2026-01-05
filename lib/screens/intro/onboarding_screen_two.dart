import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_ui.dart';

/// Widget nội dung cho trang onboarding 2 (dùng trong PageView)
/// Không có Scaffold, SafeArea, top bar hay pagination dots
class OnboardingContentTwo extends StatelessWidget {
  const OnboardingContentTwo({super.key});

  // --- MÀU SẮC THEME ---
  static const Color kPrimaryColor = Color(0xFF1B5E20);
  static const Color kTextColor = Color(0xFF1B3B36);
  static const Color kCardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // HERO SECTION: RECIPE CARD
          Expanded(
            flex: 8,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _buildRecipeCard(context),

                // Nút Magic Icon trôi nổi góc trên phải
                Positioned(
                  top: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: kPrimaryColor, size: 24),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // TEXT SECTION
          Text(
            "Đầu Bếp AI Riêng\nCủa Bạn",
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
            width: context.percentWidth(85),
            child: Text(
              "Không biết ăn gì? Nhận ngay gợi ý công thức nấu ăn dựa trên những gì bạn có sẵn.",
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

  // --- WIDGET CON: RECIPE CARD ---
  Widget _buildRecipeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
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
        children: [
          // 1. Ảnh món ăn (Nửa trên)
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Ảnh nền (Placeholder từ Unsplash hoặc Container màu)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    image: DecorationImage(
                      // Dùng ảnh mì ý bơ mẫu
                      image: NetworkImage(
                          "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?auto=format&fit=crop&w=800&q=80"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Badge "100% PHÙ HỢP"
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "100% PHÙ HỢP",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Thông tin món ăn (Nửa dưới)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mì Ý Sốt Bơ",
                        style: GoogleFonts.merriweather(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                      // Nút Bookmark
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9), // Xanh rất nhạt
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bookmark,
                            color: kPrimaryColor, size: 18),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Metadata: Thời gian & Độ khó
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Text("15 phút",
                          style: GoogleFonts.inter(
                              color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.bar_chart_rounded,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Text("Dễ",
                          style: GoogleFonts.inter(
                              color: Colors.grey[600], fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
