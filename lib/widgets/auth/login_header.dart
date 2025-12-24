import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginHeader extends StatelessWidget {
  final Color mainColor;

  const LoginHeader({super.key, required this.mainColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Logo Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1), // Màu xanh nhạt nền icon
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.kitchen, size: 40, color: mainColor),
        ),
        const SizedBox(height: 24),

        // 2. Welcome Text
        Text(
          "Welcome Back!",
          style: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's get cooking with what you have.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
