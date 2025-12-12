import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class ApiPageHeader extends StatelessWidget {
  const ApiPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Quản lý API & Dữ liệu",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            SizedBox(height: 4),
            Text("Theo dõi kết nối dịch vụ và quản lý kho công thức.",
                style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings, size: 16),
              label: const Text("Cấu hình Key"),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                  side: const BorderSide(color: AppColors.borderGrey)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.sync, size: 16, color: Colors.white),
              label: const Text("Sync thủ công",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen),
            )
          ],
        )
      ],
    );
  }
}