import 'package:flutter/material.dart';

//
// ---------------- TAG ----------------
//

class Tag extends StatelessWidget {
  final String text;
  final bool filled;

  const Tag({
    required this.text,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF214130) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: filled ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
