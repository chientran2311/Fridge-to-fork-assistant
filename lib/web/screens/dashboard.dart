import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/stat_card.dart'; // Import Widget tái sử dụng

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Top Bar Section
        const TopBarSection(),
        
        // 2. Scrollable Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WelcomeSection(),
                const SizedBox(height: 24),
                
                // Sử dụng Row chứa các StatCard tái sử dụng
                const StatsOverviewRow(),
                const SizedBox(height: 24),
                
                const ChartsAreaRow(),
                const SizedBox(height: 24),
                
                const UserListTable(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- SUB-SECTIONS CỦA DASHBOARD ---

class TopBarSection extends StatelessWidget {
  const TopBarSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 300, height: 40,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text("Tìm kiếm user, API...", style: TextStyle(color: Colors.grey, fontSize: 13)))]),
          ),
          const Spacer(),
          Stack(children: [
             const Icon(Icons.notifications_none, color: AppColors.textGrey),
             Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))
          ])
        ],
      ),
    );
  }
}

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Xin chào, Admin! 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Text("Cập nhật: 12:30 PM, 10/12/2025", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}

// Đây là nơi ta dùng lại StatCard 4 lần
class StatsOverviewRow extends StatelessWidget {
  const StatsOverviewRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatCard(title: "Tổng người dùng", value: "5,234", subText: "+12.5% so với tuần trước", icon: Icons.people, color: AppColors.cardBlue, isPositive: true)),
        SizedBox(width: 16),
        Expanded(child: StatCard(title: "Người dùng hoạt động (DAU)", value: "3,105", subText: "+8.2% hôm nay", icon: Icons.check_circle, color: AppColors.cardGreen, isPositive: true)),
        SizedBox(width: 16),
        Expanded(child: StatCard(title: "Công thức đã nấu", value: "12,543", subText: "+23.1% tăng đột biến", icon: Icons.restaurant, color: AppColors.cardOrange, isPositive: true)),
        SizedBox(width: 16),
        Expanded(child: StatCard(title: "Cảnh báo hết hạn", value: "892", subText: "-5.4% ít lãng phí hơn", icon: Icons.warning, color: AppColors.cardRed, isPositive: false)),
      ],
    );
  }
}

class ChartsAreaRow extends StatelessWidget {
  const ChartsAreaRow({super.key});
  @override
  Widget build(BuildContext context) {
    // (Giữ nguyên code biểu đồ cũ của bạn ở đây để file ngắn gọn)
    // Để tiết kiệm không gian hiển thị, tôi dùng Placeholder. 
    // Bạn hãy paste lại widget ChartsAreaRow từ code cũ vào đây nhé.
    return Container(
      height: 300, 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text("Khu vực Biểu đồ (ChartsAreaRow)")),
    ); 
  }
}

class UserListTable extends StatelessWidget {
  const UserListTable({super.key});
  @override
  Widget build(BuildContext context) {
    // (Giữ nguyên code bảng cũ của bạn ở đây)
    return Container(
      height: 300,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text("Khu vực Bảng User (UserListTable)")),
    );
  }
}