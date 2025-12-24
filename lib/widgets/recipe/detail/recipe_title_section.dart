import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeTitleSection extends StatelessWidget {
  final String title;
  final String author;
  final Color mainColor;

  const RecipeTitleSection({
    super.key,
    required this.title,
    required this.author,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
            margin: const EdgeInsets.only(bottom: 20),
          ),
        ),
        Text(
          title,
          style: GoogleFonts.merriweather(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          author,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
