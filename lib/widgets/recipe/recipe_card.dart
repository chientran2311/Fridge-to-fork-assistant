import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF214130);
    // Lấy chiều rộng màn hình để tính toán tỷ lệ ảnh nếu cần
    final screenWidth = MediaQuery.of(context).size.width;
    // Nếu màn hình quá nhỏ (<380), giảm kích thước ảnh xuống 120, ngược lại giữ 160
    final double imageWidth = screenWidth < 380 ? 120 : 160;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEE9),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn hàng đầu
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Suggested.png',
              width: imageWidth, // ⭐ Dùng chiều rộng linh hoạt
              height: 100,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc tương đối
              children: [
                const SizedBox(height: 4), // Padding top nhẹ
                Text(
                  "Braised pork",
                  style: GoogleFonts.merriweather(
                    fontSize: 18, // Giảm nhẹ xuống 18 cho an toàn
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1, // Giới hạn 1 dòng cho tiêu đề
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Text(
                  "pork, boiled eggs, Thit kho Tau sauce, onion,...",
                  maxLines: 3, // Cho phép tối đa 3 dòng mô tả
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.merriweather(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    height: 1.4, // Tăng khoảng cách dòng cho dễ đọc
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}