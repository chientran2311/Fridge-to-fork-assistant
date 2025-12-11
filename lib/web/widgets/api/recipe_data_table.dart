import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class RecipeDataTable extends StatelessWidget {
  const RecipeDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dữ liệu Công thức (Live Data)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Container(
                    width: 250,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGrey),
                        borderRadius: BorderRadius.circular(4)),
                    child: Row(children: const [
                      Icon(Icons.search, size: 16, color: AppColors.textGrey),
                      SizedBox(width: 8),
                      Text("Tìm ID, tên món...",
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 12))
                    ]),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 16),
                    label: const Text("Lọc Nguồn"),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textGrey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // Table
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              horizontalMargin: 12,
              columnSpacing: 20,
              dataRowHeight: 70,
              columns: const [
                DataColumn(
                    label: Text("MÓN ĂN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(
                    label: Text("NGUỒN (SOURCE)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(
                    label: Text("ĐỘ KHÓ / THỜI GIAN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(
                    label: Text("NGÀY CACHE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(
                    label: Text("TRẠNG THÁI",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(
                    label: Text("HÀNH ĐỘNG",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: [
                _buildRow(
                    "Phở Bò Tái Nạm",
                    "ID: SP-88321",
                    Colors.grey.shade300,
                    "Spoonacular",
                    AppColors.spoonacularGreen,
                    "Trung bình",
                    "45 phút",
                    "10/12/2025\n12:30 PM",
                    Colors.green),
                _buildRow(
                    "Salad Cầu Vồng (AI)",
                    "ID: AI-GEN-002",
                    Colors.grey.shade300,
                    "OpenAI",
                    AppColors.openAIBlue,
                    "Dễ",
                    "15 phút",
                    "10/12/2025\n10:15 AM",
                    Colors.amber),
                _buildRow(
                    "Mỳ Ý Sốt Kem Nấm",
                    "ID: SP-99120",
                    Colors.grey.shade300,
                    "Spoonacular",
                    AppColors.spoonacularGreen,
                    "Khó",
                    "60 phút",
                    "09/12/2025\n08:00 PM",
                    Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Hiển thị 1-10 của 12,543 công thức",
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              Row(
                children: [
                  _buildPageBtn("Trước", false),
                  const SizedBox(width: 4),
                  _buildPageBtn("1", true),
                  const SizedBox(width: 4),
                  _buildPageBtn("2", false),
                  const SizedBox(width: 4),
                  const Text("...", style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(width: 4),
                  _buildPageBtn("Sau", false),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  DataRow _buildRow(
      String name,
      String id,
      Color imgColor,
      String source,
      Color sourceColor,
      String difficulty,
      String time,
      String date,
      Color statusColor) {
    return DataRow(cells: [
      DataCell(Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: imgColor, borderRadius: BorderRadius.circular(6))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textDark)),
              Text(id,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 10)),
            ],
          )
        ],
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: sourceColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(source == "OpenAI" ? Icons.smart_toy : Icons.eco,
                size: 12, color: sourceColor),
            const SizedBox(width: 4),
            Text(source,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sourceColor)),
          ],
        ),
      )),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(difficulty, style: const TextStyle(fontSize: 12)),
          Text(time,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        ],
      )),
      DataCell(Text(date,
          style: const TextStyle(fontSize: 11, color: AppColors.textGrey))),
      DataCell(Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle))),
      const DataCell(Icon(Icons.description_outlined,
          size: 18, color: AppColors.textGrey)),
    ]);
  }

  Widget _buildPageBtn(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.white,
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.white : AppColors.textGrey)),
    );
  }
}