import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class StatisticHeader extends StatelessWidget {
  const StatisticHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Quản trị / Trung tâm Dữ liệu",
                style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            SizedBox(height: 8),
            Text("Báo cáo Hiệu quả Dự án",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            Text(
                "Dữ liệu chi tiết về hành vi người dùng và tác động của 'Bếp Trợ Lý'.",
                style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
        // Date Filter Buttons
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              _buildFilterBtn("Tuần này", true),
              _buildFilterBtn("Tháng này", false),
              _buildFilterBtn("Năm 2025", false),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.download, size: 20))
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFilterBtn(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isActive
          ? BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6))
          : null,
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
    );
  }
}