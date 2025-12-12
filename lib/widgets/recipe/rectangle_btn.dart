import 'package:flutter/material.dart';

class RectangleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap; // Hàm callback để xử lý sự kiện click

  const RectangleBtn({
    super.key,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Gắn sự kiện click vào đây
      borderRadius: BorderRadius.circular(12), // Hiệu ứng ripple bo tròn theo nút
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white, // Màu nền mờ 10%
        ),
        child: Icon(
          icon, 
          size: 22, 
          color: color,
        ),
      ),
    );
  }
}