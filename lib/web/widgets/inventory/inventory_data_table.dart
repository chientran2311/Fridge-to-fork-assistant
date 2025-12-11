import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class InventoryDataTable extends StatelessWidget {
  const InventoryDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
        horizontalMargin: 24,
        columnSpacing: 20,
        dataRowHeight: 70,
        columns: const [
          DataColumn(
              label: Text("TÊN NGUYÊN LIỆU",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(
              label: Text("DANH MỤC",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(
              label: Text("ĐƠN VỊ CHUẨN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(
              label: Text("HẠN DÙNG TB",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(
              label: Text("MÃ BARCODE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          DataColumn(
              label: Text("HÀNH ĐỘNG",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        ],
        rows: [
          _buildRow(
              "Cà rốt Đà Lạt",
              "Carrot",
              Colors.orange.shade100,
              "Rau củ",
              AppColors.catVegBg,
              AppColors.catVegTxt,
              "Gram (g)",
              "14 ngày",
              "893456789012",
              false),
          _buildRow(
              "Thịt Bò Thăn",
              "Beef Tenderloin",
              Colors.red.shade100,
              "Thịt & Cá",
              AppColors.catMeatBg,
              AppColors.catMeatTxt,
              "Kilogram (kg)",
              "3 ngày",
              "893112233445",
              false),
          _buildRow(
              "Sữa Tươi Không Đường",
              "Fresh Milk",
              Colors.blue.shade100,
              "Bơ Sữa",
              AppColors.catDairyBg,
              AppColors.catDairyTxt,
              "Lít (l)",
              "7 ngày",
              "",
              true),
        ],
      ),
    );
  }

  DataRow _buildRow(
      String nameVi,
      String nameEn,
      Color imgPlaceholderColor,
      String category,
      Color catBg,
      Color catTxt,
      String unit,
      String expiry,
      String barcode,
      bool isMissing) {
    return DataRow(cells: [
      // Col 1: Name & Image
      DataCell(Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: imgPlaceholderColor,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(nameVi,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textDark)),
              Text(nameEn,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 11)),
            ],
          )
        ],
      )),
      // Col 2: Category Badge
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: catBg, borderRadius: BorderRadius.circular(16)),
        child: Text(category,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: catTxt)),
      )),
      // Col 3: Unit
      DataCell(Text(unit,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
      // Col 4: Expiry
      DataCell(Row(
        children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 4),
          Text(expiry,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
        ],
      )),
      // Col 5: Barcode / Missing
      DataCell(isMissing
          ? Row(children: const [
              Icon(Icons.error_outline, size: 14, color: AppColors.errorRed),
              SizedBox(width: 4),
              Text("Missing",
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.bold))
            ])
          : Text(barcode,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  fontFamily: 'RobotoMono'))),
      // Col 6: Actions
      DataCell(Row(
        children: const [
          Icon(Icons.edit_outlined, size: 18, color: AppColors.textGrey),
          SizedBox(width: 12),
          Icon(Icons.delete_outline, size: 18, color: AppColors.textGrey),
        ],
      )),
    ]);
  }
}