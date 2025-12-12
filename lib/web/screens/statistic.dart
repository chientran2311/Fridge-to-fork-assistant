import 'package:flutter/material.dart';
import '../widgets/header_bar.dart'; // Import HeaderBar chung
import '../widgets/statistic/statistic_page_header.dart'; // Import Header mới
import '../widgets/statistic/stats_row.dart';
import '../widgets/statistic/charts_section.dart';
import '../widgets/statistic/system_log_table.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Column để chứa HeaderBar cố định ở trên và nội dung cuộn ở dưới
    return Column(
      children: [
        // 1. Header Bar (Breadcrumb & Notification)
       const HeaderBar(title: "Quản trị / Trung tâm Dữ liệu"),

        // 2. Nội dung chính (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Page Header (Title & Action Buttons)
                StatisticPageHeader(),
                
                SizedBox(height: 24),
                
                // Stats Cards
                StatsRow(),
                
                SizedBox(height: 24),
                
                // Charts Section
                ChartsSection(),
                
                SizedBox(height: 24),
                
                // Table Section
                SystemLogTable(),

                SizedBox(height: 40), // Khoảng trống dưới cùng
              ],
            ),
          ),
        ),
      ],
    );
  }
}