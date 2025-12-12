import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/stat_card_horizontal.dart'; // Import Widget thẻ ngang

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Không dùng Scaffold ở đây nữa, chỉ trả về nội dung
    return Column(
      children: [
        // Header Bar
        const HeaderBar(),
        
        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Actions
                const TitleSection(),
                const SizedBox(height: 20),
                
                // Stats Cards Row (Sử dụng Widget tái sử dụng)
                const UserStatsRow(),
                const SizedBox(height: 20),
                
                // Filter & Search Bar
                const FilterSection(),
                
                // Table Section
                const UserTableSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- SUB-WIDGETS (Header, Title, Filter, Table) ---
// Bạn có thể tách tiếp các widget này ra file riêng nếu muốn, 
// nhưng để ở đây cho tiện quản lý logic của trang User cũng được.

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Quản trị / Danh sách người dùng", style: TextStyle(color: AppColors.textGrey)),
          Stack(children: [
             const Icon(Icons.notifications_none, color: AppColors.textGrey),
             Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))
          ])
        ],
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Quản lý Người dùng", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            SizedBox(height: 4),
            Text("Quản lý tài khoản, phân quyền và theo dõi trạng thái.", style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {}, icon: const Icon(Icons.download, size: 16), label: const Text("Xuất Excel"),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.textGrey, side: const BorderSide(color: AppColors.borderGrey)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {}, icon: const Icon(Icons.add, size: 16, color: Colors.white), label: const Text("Thêm mới", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            )
          ],
        )
      ],
    );
  }
}

class UserStatsRow extends StatelessWidget {
  const UserStatsRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatCardHorizontal(label: "TỔNG USERS", count: "5,234", icon: Icons.people, color: Colors.blue)),
        SizedBox(width: 16),
        Expanded(child: StatCardHorizontal(label: "ĐANG HOẠT ĐỘNG", count: "4,890", icon: Icons.check_circle, color: AppColors.activeGreen)),
        SizedBox(width: 16),
        Expanded(child: StatCardHorizontal(label: "TÀI KHOẢN PREMIUM", count: "1,205", icon: Icons.star, color: AppColors.premiumGold)),
        SizedBox(width: 16),
        Expanded(child: StatCardHorizontal(label: "BỊ KHÓA / SPAM", count: "45", icon: Icons.block, color: AppColors.lockedRed)),
      ],
    );
  }
}

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: AppColors.bgLightPink, width: 1))
      ),
      child: Row(
        children: [
          Container(
            width: 300, height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(4)),
            child: Row(children: const [Icon(Icons.search, size: 18, color: AppColors.textGrey), SizedBox(width: 8), Expanded(child: Text("Tìm tên, email...", style: TextStyle(color: AppColors.textGrey, fontSize: 13)))]),
          ),
          const SizedBox(width: 16),
          _buildDropdown("Tất cả trạng thái"),
          const SizedBox(width: 16),
          _buildDropdown("Tất cả Gói"),
        ],
      ),
    );
  }
  Widget _buildDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textDark)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textGrey)]),
    );
  }
}

class UserTableSection extends StatelessWidget {
  const UserTableSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              horizontalMargin: 24, columnSpacing: 20, dataRowHeight: 80,
              columns: const [
                DataColumn(label: Icon(Icons.check_box_outline_blank, size: 18, color: AppColors.textGrey)),
                DataColumn(label: Text("THÔNG TIN USER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text("GÓI DỊCH VỤ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text("TRẠNG THÁI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text("NGÀY THAM GIA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text("ĐĂNG NHẬP CUỐI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text("HÀNH ĐỘNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: [
                _buildRow("Nguyễn Văn A", "anv@gmail.com", "A", Colors.green.shade100, Colors.green, "Free Plan", false, "Hoạt động", AppColors.activeGreen, "12/05/2023", "2 giờ trước"),
                _buildRow("Trần Thị B", "bnb@gmail.com", "B", Colors.orange.shade100, Colors.orange.shade800, "Premium", true, "Hoạt động", AppColors.activeGreen, "20/08/2023", "1 ngày trước"),
                _buildRow("Lê Văn C", "cvl@gmail.com", "L", Colors.grey.shade200, Colors.grey, "Free Plan", false, "Đã khóa", AppColors.lockedRed, "01/01/2023", "1 tháng trước"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Simple Pagination (Simplified for brevity)
          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Hiển thị 1-10 của 5,234 tài khoản", style: TextStyle(color: AppColors.textGrey, fontSize: 12))),
        ],
      ),
    );
  }

  DataRow _buildRow(String name, String email, String char, Color bgChar, Color txtChar, String plan, bool isPremium, String status, Color statusColor, String date, String lastLogin) {
    return DataRow(cells: [
      const DataCell(Icon(Icons.check_box_outline_blank, size: 18, color: AppColors.textGrey)),
      DataCell(Row(children: [
        CircleAvatar(backgroundColor: bgChar, radius: 18, child: Text(char, style: TextStyle(color: txtChar, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(email, style: const TextStyle(color: AppColors.textGrey, fontSize: 11))])
      ])),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: isPremium ? AppColors.premiumGold.withOpacity(0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16), border: isPremium ? Border.all(color: AppColors.premiumGold.withOpacity(0.3)) : null),
        child: Row(mainAxisSize: MainAxisSize.min, children: [if(isPremium) const Icon(Icons.star, size: 10, color: AppColors.premiumGold), Text(plan, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPremium ? AppColors.premiumGold : AppColors.textGrey))]),
      )),
      DataCell(Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)), const SizedBox(width: 6), Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12))])),
      DataCell(Text(date)), DataCell(Text(lastLogin)), const DataCell(Icon(Icons.more_horiz, color: AppColors.textGrey)),
    ]);
  }
}