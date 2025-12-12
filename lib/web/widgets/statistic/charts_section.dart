import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class ChartsSection extends StatelessWidget {
  const ChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart 1: Bar Chart
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 350,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Khung giờ nấu ăn cao điểm",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar("6h", 0.2, AppColors.primaryGreen.withOpacity(0.3)),
                    _buildBar("9h", 0.4, AppColors.primaryGreen.withOpacity(0.3)),
                    _buildBar("12h", 0.6, AppColors.primaryGreen),
                    _buildBar("15h", 0.3, AppColors.primaryGreen.withOpacity(0.3)),
                    _buildBar("18h", 0.9, AppColors.primaryGreen),
                    _buildBar("21h", 0.5, AppColors.primaryGreen),
                  ],
                ),
                const SizedBox(height: 10),
                const Center(
                    child: Text(
                        "Insight: Người dùng chủ yếu nấu ăn vào bữa tối (18h-19h).",
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)))
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Chart 2: Top Products
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 350,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Top thực phẩm trong tủ lạnh",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                _buildProgressItem("Trứng gà", 0.85, AppColors.chartAmber),
                _buildProgressItem("Cà chua", 0.62, AppColors.chartRed),
                _buildProgressItem("Thịt heo", 0.54, AppColors.chartPink),
                _buildProgressItem("Hành tây", 0.40, AppColors.chartPurple),
                _buildProgressItem("Sữa tươi", 0.35, AppColors.chartBlue),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBar(String label, double pct, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 200 * pct, // Chiều cao mô phỏng
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey))
      ],
    );
  }

  Widget _buildProgressItem(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${(pct * 100).toInt()}% user có",
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade100,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          )
        ],
      ),
    );
  }
}