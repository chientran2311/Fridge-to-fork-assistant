import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/screens/recipe/filter_modal.dart';

class AIRecipeHeader extends StatelessWidget {
  const AIRecipeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36); // Xanh rêu đậm

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Chef AI Suggestions",
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              // Nút Filter Icon
              GestureDetector(
                onTap: () {
                  FilterModal.show(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(Icons.tune, size: 20, color: mainColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Green Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2EFE5), // Màu xanh nhạt nền banner
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(Icons.eco_outlined, color: mainColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: mainColor, fontSize: 13, height: 1.4),
                      children: const [
                        TextSpan(
                            text:
                                "Found 3 recipes to rescue your expiring ingredients. "),
                        TextSpan(
                          text: "You saved 250g of food this week!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
