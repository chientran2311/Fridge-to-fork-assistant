import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildCard("Thực phẩm đã cứu", "1,240 kg",
                "+12% so với tháng trước", Icons.eco,
                isPrimary: true)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildCard("Món ăn đã nấu", "8,532", "+24.5% tăng trưởng",
                Icons.check_circle_outline)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildCard("Chi phí trung bình/bữa", "45k",
                "↓ 5% tiết kiệm hơn", Icons.attach_money)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildCard("Chi phí API (OpenAI)", "\$120",
                "↑ 8% cần tối ưu cache", Icons.api)),
      ],
    );
  }

  Widget _buildCard(String title, String value, String sub, IconData icon,
      {bool isPrimary = false}) {
    Color bg = isPrimary ? AppColors.primaryGreen : Colors.white;
    Color txtMain = isPrimary ? Colors.white : AppColors.textDark;
    
    // Màu xu hướng (Trend color)
    Color trendColor;
    if (isPrimary) {
      trendColor = Colors.white70;
    } else {
      trendColor = sub.contains("↑") ? AppColors.errorRed : AppColors.primaryGreen;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: isPrimary ? Colors.white : AppColors.textGrey,
                      fontSize: 13)),
              Icon(icon,
                  color: isPrimary ? Colors.white54 : Colors.grey.shade300),
            ],
          ),
          Text(value,
              style: TextStyle(
                  color: txtMain, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(sub,
              style: TextStyle(
                  color: trendColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}