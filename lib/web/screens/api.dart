import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/header_bar.dart';
import '../widgets/api/api_page_header.dart';
import '../widgets/api/api_stat_row.dart';
import '../widgets/api/recipe_data_table.dart';

class ApiScreen extends StatelessWidget {
  const ApiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Không cần Scaffold hay Row Sidebar ở đây vì MainLayout đã bao bọc
    return Column(
      children: [
        // Header (Breadcrumb & Notifications)
        const HeaderBar(),
        
        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Title & Actions
                ApiPageHeader(),
                SizedBox(height: 24),
                
                // API Status Cards
                ApiStatsRow(),
                SizedBox(height: 24),
                
                // Data Table Section
                RecipeDataTable(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}