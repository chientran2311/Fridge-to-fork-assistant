/// ============================================
/// INSTRUCTIONS SECTION WIDGET
/// ============================================
/// 
/// Displays step-by-step cooking instructions with:
/// - Numbered steps in circular indicators
/// - Clear text formatting for each step
/// - Responsive spacing and layout
/// 
/// UI Components:
/// - Section title "Instructions"
/// - Numbered step indicators (circular)
/// - Step description text with proper wrapping
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget displaying cooking instructions as numbered steps
class InstructionsSection extends StatelessWidget {
  /// List of instruction step strings
  final List<String> instructions;
  
  /// Primary theme color for step indicators
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
        // Section header
        Text(
          "Instructions",
          style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: mainColor),
        ),
        const SizedBox(height: 16),
        // Generate numbered step list
        ...List.generate(instructions.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number indicator
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
                // Step description
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
