import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class InventoryPageHeader extends StatelessWidget {
  const InventoryPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Kho Nguyên liệu Master",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            SizedBox(height: 4),
            Text("Cơ sở dữ liệu chuẩn hóa cho tất cả thực phẩm trong hệ thống.",
                style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text("Nhập CSV"),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                  side: const BorderSide(color: AppColors.borderGrey),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text("Thêm Nguyên liệu",
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