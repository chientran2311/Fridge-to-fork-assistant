import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionModal extends StatelessWidget {
  const OptionModal({super.key});

  @override
  Widget build(BuildContext context) {
    // Màu sắc theo style của dự án
    final Color darkGreen = const Color(0xFF1B3B36);
    final Color bgLight = const Color(0xFFE7EAE9); // Màu nền giống BottomBar

    return Stack(
      children: [
        // Dùng Positioned để đặt modal ở góc trên bên phải (dưới nút more)
        Positioned(
          top: 80, // Khoảng cách từ đỉnh màn hình xuống (áng chừng chiều cao Header)
          right: 15, // Khoảng cách lề phải (căn thẳng với nút more)
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 180, // Chiều rộng cố định cho menu nhỏ
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Tự co lại theo nội dung
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOptionItem("Share recipe", darkGreen, () {
                    print("Share tapped");
                    Navigator.pop(context);
                  }),
                  
                  // Đường kẻ mảnh phân cách
                  Divider(height: 1, thickness: 1, color: darkGreen.withOpacity(0.2)),
                  
                  _buildOptionItem("Add to calendar", darkGreen, () {
                     print("Calendar tapped");
                     Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem(String text, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Bo tròn hiệu ứng ripple khi bấm
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity, // Để vùng bấm full chiều ngang
          child: Text(
            text,
            style: GoogleFonts.merriweather(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}