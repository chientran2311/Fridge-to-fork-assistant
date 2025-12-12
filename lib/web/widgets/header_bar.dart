import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class HeaderBar extends StatelessWidget {
  // 1. Khai báo biến để nhận nội dung text
  final String title;

  // 2. Yêu cầu truyền 'title' khi khởi tạo Widget
  const HeaderBar({
    super.key, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 3. Sử dụng biến 'title' thay cho text cứng
          Text(
            title, 
            style: const TextStyle(color: AppColors.textGrey),
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: AppColors.textGrey),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red, 
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}