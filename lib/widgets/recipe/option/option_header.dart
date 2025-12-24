import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionHeader extends StatelessWidget {
  const OptionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36); // Xanh rêu đậm

    return Column(
      children: [
        Text(
          "Recipe Options",
          style: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Select an action for this recipe",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
