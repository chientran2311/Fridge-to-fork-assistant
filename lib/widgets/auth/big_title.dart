// lib/widgets/auth/big_title.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_layout.dart'; // Import file ở bước 1

class BigTitle extends StatelessWidget {
  const BigTitle({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic: Nếu là mobile thì chữ 40, Desktop thì 60, Tablet thì 50
    double fontSize = ResponsiveLayout.isMobile(context) ? 40 : 60;

    return Text(
      "Find Your Next\nFavorite Dish\nWith 3tocom",
      textAlign: TextAlign.center,
      style: GoogleFonts.newsreader(
        fontSize: fontSize, 
        fontWeight: FontWeight.w300,
        height: 1.2,
        color: Colors.white,
      ),
    );
  }
}