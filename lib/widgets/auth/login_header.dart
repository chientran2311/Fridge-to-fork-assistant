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
            shape: BoxShape.circle,
            border: Border.all(color: mainColor, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_icon.jpeg',
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ Lỗi load ảnh: $error');
                return Container(
                  color: mainColor.withOpacity(0.1),
                  child: Icon(Icons.kitchen, size: 40, color: mainColor),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Welcome Text
        Text(
          "An3tocom!",
          style: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Hãy nấu ăn với những gì bạn có.",
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
