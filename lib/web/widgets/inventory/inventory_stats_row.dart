import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class InventoryStatsRow extends StatelessWidget {
  const InventoryStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
            "TỔNG ITEMS", "842", Icons.all_inclusive, Colors.purpleAccent),
        const SizedBox(width: 20),
        _buildStatItem("DANH MỤC", "16", Icons.category, Colors.blueAccent),
        const SizedBox(width: 20),
        _buildStatItem("CẦN CẬP NHẬT ẢNH", "24", Icons.image_not_supported,
            Colors.orangeAccent),
        const SizedBox(width: 20),
        _buildStatItem("THIẾU BARCODE", "5", Icons.qr_code_scanner,
            AppColors.errorRed),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Text(count,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
              ],
            ),
            Icon(icon, color: color.withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }
}