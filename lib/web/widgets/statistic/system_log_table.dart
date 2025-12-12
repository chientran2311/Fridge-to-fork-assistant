import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class SystemLogTable extends StatelessWidget {
  const SystemLogTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nhật ký Hệ thống gần đây",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                  onPressed: () {},
                  child: const Text("Xem tất cả",
                      style: TextStyle(color: AppColors.primaryGreen)))
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                  fontSize: 11),
              columns: const [
                DataColumn(label: Text("THỜI GIAN")),
                DataColumn(label: Text("LOẠI SỰ KIỆN")),
                DataColumn(label: Text("MÔ TẢ")),
                DataColumn(label: Text("USER LIÊN QUAN")),
                DataColumn(label: Text("TRẠNG THÁI")),
              ],
              rows: [
                _buildRow(
                    "10:42 AM",
                    "New User",
                    Colors.blue.shade100,
                    Colors.blue,
                    "Đăng ký tài khoản qua Google",
                    "minh.le@gmail.com",
                    "Success",
                    Colors.green),
                _buildRow(
                    "10:30 AM",
                    "API Sync",
                    Colors.orange.shade100,
                    Colors.orange,
                    "Đồng bộ 50 công thức Spoonacular",
                    "System",
                    "Success",
                    Colors.green),
                _buildRow(
                    "10:15 AM",
                    "Error",
                    Colors.red.shade100,
                    Colors.red,
                    "Lỗi gửi thông báo (FCM invalid)",
                    "hoa.nguyen@...",
                    "Failed",
                    Colors.red),
                _buildRow(
                    "09:55 AM",
                    "Recipe",
                    Colors.purple.shade100,
                    Colors.purple,
                    "User hoàn thành món 'Phở Bò'",
                    "thanh.tran@...",
                    "Logged",
                    AppColors.primaryGreen),
              ],
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildRow(String time, String type, Color bgType, Color txtType,
      String desc, String user, String status, Color statusColor) {
    return DataRow(cells: [
      DataCell(Text(time, style: const TextStyle(color: AppColors.textGrey))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: bgType, borderRadius: BorderRadius.circular(4)),
        child: Text(type,
            style: TextStyle(
                color: txtType, fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(desc)),
      DataCell(Text(user, style: const TextStyle(color: AppColors.textGrey))),
      DataCell(Text(status,
          style: TextStyle(
              color: statusColor, fontWeight: FontWeight.bold, fontSize: 12))),
    ]);
  }
}