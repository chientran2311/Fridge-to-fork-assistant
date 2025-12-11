import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/header_bar.dart'; // Tái sử dụng HeaderBar chung
import '../widgets/inventory/inventory_page_header.dart';
import '../widgets/inventory/inventory_stats_row.dart';
import '../widgets/inventory/filter_section.dart';
import '../widgets/inventory/inventory_data_table.dart';
import '../widgets/inventory/pagination_footer.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Không dùng Scaffold hay Sidebar ở đây vì MainLayout đã xử lý.
    return Column(
      children: [
        // 1. Header Chung
        const HeaderBar(),
        
        // 2. Nội dung chính (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Actions
                const InventoryPageHeader(),
                const SizedBox(height: 24),
                
                // Stats Rows
                const InventoryStatsRow(),
                const SizedBox(height: 24),
                
                // Filter & Table Section Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      // Filter Section (Search + Chips)
                      FilterSection(),
                      Divider(height: 1, color: AppColors.bgLightPink),
                      // Table
                      InventoryDataTable(),
                      // Pagination
                      PaginationFooter(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}