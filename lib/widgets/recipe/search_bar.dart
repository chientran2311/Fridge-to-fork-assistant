import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/recipe/filter_modal.dart';
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  const SearchBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF214130);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.merriweather(color: textColor),
            decoration: InputDecoration(
              hintText: "type ingredients...",
              hintStyle: GoogleFonts.merriweather(
                fontSize: 15,
                color: textColor.withOpacity(0.6),
              ),

              // 🔍 Prefix icon như search bar chuẩn
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: textColor.withOpacity(0.7),
              ),

              filled: true,
              fillColor: Colors.white,

              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: textColor.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: textColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // FILTER BUTTON
        // Thay thế widget Container cũ bằng đoạn này
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true, // Cho phép click ra ngoài để tắt
              barrierColor:
                  Colors.black.withOpacity(0.3), // Màu nền mờ khi hiện modal
              builder: (context) => const FilterModal(),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Giả sử textColor là biến bạn đang có sẵn
              color: Colors.white, // Màu nền mờ 10%
            ),
            child: const Icon(Icons.filter_list, size: 22, color: textColor),
          ),
        )
      ],
    );
  }
}
