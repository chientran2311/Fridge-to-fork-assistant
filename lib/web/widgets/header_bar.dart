import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Quản trị / API & Dữ liệu Công thức",
              style: TextStyle(color: AppColors.textGrey)),
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
                          color: Colors.red, shape: BoxShape.circle)))
            ],
          )
        ],
      ),
    );
  }
}