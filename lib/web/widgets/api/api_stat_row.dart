import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class ApiStatsRow extends StatelessWidget {
  const ApiStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildApiCard("Spoonacular API", "Connected", "1,240 / 5,000 pts", 0.25,
              AppColors.spoonacularGreen, Icons.show_chart),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildApiCard("OpenAI (GPT-4)", "Connected", "\$42.50 (Tháng này)", 0.4,
              AppColors.openAIBlue, Icons.pie_chart),
        ),
        const SizedBox(width: 20),
        const Expanded(child: CacheStatCard()),
      ],
    );
  }

  Widget _buildApiCard(String title, String status, String metricLabel,
      double progress, Color color, IconData chartIcon) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(chartIcon, color: color.withOpacity(0.5), size: 28)
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text("Trạng thái:",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const Spacer(),
              Text(status,
                  style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.contains("Spoonacular") ? "Quota hôm nay" : "Chi phí",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
              Text(metricLabel,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}

class CacheStatCard extends StatelessWidget {
  const CacheStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // 1. Thay height: 160 bằng constraints để thẻ có thể dài ra nếu cần
      constraints: const BoxConstraints(minHeight: 160), 
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // 2. Dùng mainAxisSize.min để Column chỉ chiếm chiều cao vừa đủ nội dung
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Text("Tổng công thức đã lưu (Cached)",
              style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 8),
          const Text("12,543",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 4), // Thêm khoảng cách nhỏ
          Row(
            children: const [
              Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4),
              Text("+125",
                  style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold)),
              Text(" mới trong 24h qua",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
          
          // 3. Thay Spacer() bằng SizedBox cụ thể để tránh lỗi layout khi bỏ fixed height
          const SizedBox(height: 16), 
          const Divider(),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Cache Hit Rate", "84%"),
              _buildMiniStat("Avg. Latency", "240ms"),
            ],
          )
        ],
      ),
    );
  }

 Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
