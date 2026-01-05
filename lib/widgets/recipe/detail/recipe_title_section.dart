/// ============================================
/// RECIPE TITLE SECTION WIDGET
/// ============================================
/// 
/// Displays the recipe title and author information:
/// - Drag handle indicator for bottom sheet style
/// - Recipe title with custom typography
/// - Author/source attribution
/// 
/// UI Components:
/// - Centered drag handle bar
/// - Recipe title in Merriweather bold font
/// - Author name in subtle gray text
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget displaying recipe title and author
class RecipeTitleSection extends StatelessWidget {
  /// Recipe title text
  final String title;
  
  /// Recipe author or source
  final String author;
  
  /// Primary theme color for title
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
        // Drag handle indicator
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
        // Recipe title
        Text(
          title,
          style: GoogleFonts.merriweather(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: mainColor,
          ),
        ),
        const SizedBox(height: 8),
        // Author attribution
        Text(
          author,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
