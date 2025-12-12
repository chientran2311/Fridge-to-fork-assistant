import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BigTitle extends StatelessWidget {
  const BigTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Find Your Next\nFavorite Dish\nWith 3tocom",
      textAlign: TextAlign.center,
      style: GoogleFonts.newsreader(
        fontSize: 50,
        fontWeight: FontWeight.w300,
        height: 1.2,
        color: Colors.white,
      ),
    );
  }
}
