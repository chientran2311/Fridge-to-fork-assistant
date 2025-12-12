import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Hiển thị 1-10 của 842 items",
              style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          Row(
            children: [
              _buildPageBtn("Trước", false),
              const SizedBox(width: 4),
              _buildPageBtn("1", true),
              const SizedBox(width: 4),
              _buildPageBtn("2", false),
              const SizedBox(width: 4),
              _buildPageBtn("3", false),
              const SizedBox(width: 4),
              const Text("...", style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(width: 4),
              _buildPageBtn("Sau", false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPageBtn(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.white,
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.white : AppColors.textGrey)),
    );
  }
}