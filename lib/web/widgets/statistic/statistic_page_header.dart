import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class StatisticPageHeader extends StatelessWidget {
  const StatisticPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Báo cáo Hiệu quả Dự án",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            SizedBox(height: 4),
            Text("Dữ liệu chi tiết về hành vi người dùng và hiệu suất hệ thống.",
                style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list_alt, size: 16),
              label: const Text("Bộ lọc"),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                  side: const BorderSide(color: AppColors.borderGrey),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16, color: Colors.white),
              label: const Text("Xuất Báo cáo",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16)),
            )
          ],
        )
      ],
    );
  }
}