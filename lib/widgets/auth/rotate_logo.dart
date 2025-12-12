import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RotatedLogo extends StatelessWidget {
  const RotatedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -20 * 3.1415926535 / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.4),
          borderRadius: const BorderRadius.all(
            Radius.elliptical(100, 60),
          ),
        ),
        child: Text(
          "3tocom",
          style: GoogleFonts.merriweather(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
