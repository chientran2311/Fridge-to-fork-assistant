import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareHeader extends StatelessWidget {
  const ShareHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Share Recipe",
              style: GoogleFonts.merriweather(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Share this meal with friends",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          color: Colors.grey,
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
