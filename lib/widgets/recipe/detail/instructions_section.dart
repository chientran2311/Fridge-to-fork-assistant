import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructionsSection extends StatelessWidget {
  final List<String> instructions;
  final Color mainColor;

  const InstructionsSection({
    super.key,
    required this.instructions,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Instructions",
          style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: mainColor),
        ),
        const SizedBox(height: 16),
        ...List.generate(instructions.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    instructions[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
