import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Input
          Container(
            width: 300,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGrey),
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: const [
                Icon(Icons.search, size: 18, color: AppColors.textGrey),
                SizedBox(width: 8),
                Expanded(
                    child: Text("Tìm nguyên liệu, mã vạch...",
                        style: TextStyle(
                            color: AppColors.textGrey, fontSize: 13))),
              ],
            ),
          ),
          // Filter Chips/Buttons
          Row(
            children: [
              _buildFilterButton("Tất cả", null, isActive: true),
              const SizedBox(width: 8),
              _buildFilterButton("Rau củ", Icons.grass),
              const SizedBox(width: 8),
              _buildFilterButton("Thịt & Cá", Icons.set_meal),
              const SizedBox(width: 8),
              _buildFilterButton("Gia vị", Icons.soup_kitchen),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData? icon,
      {bool isActive = false}) {
    return ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.primaryGreen : Colors.white,
          foregroundColor: isActive ? Colors.white : AppColors.textGrey,
          elevation: 0,
          side: isActive ? null : const BorderSide(color: AppColors.borderGrey),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(text),
    );
  }
}