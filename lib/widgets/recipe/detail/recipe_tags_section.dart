/// ============================================
/// RECIPE TAGS SECTION WIDGET
/// ============================================
/// 
/// Displays recipe metadata tags including:
/// - Cooking time in minutes
/// - Number of servings
/// - Pill-shaped tag containers
/// 
/// UI Components:
/// - Timer icon with duration text
/// - People icon with servings count
/// - Rounded pill-style containers
/// - Consistent spacing and styling
/// 
/// ============================================

import 'package:flutter/material.dart';

/// Widget displaying recipe metadata as tag pills
class RecipeTagsSection extends StatelessWidget {
  /// Total cooking time in minutes
  final int readyInMinutes;
  
  /// Number of servings the recipe yields
  final int servings;

  const RecipeTagsSection({
    super.key,
    this.readyInMinutes = 0,
    this.servings = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Time tag
        _buildTag(Icons.timer_outlined, "$readyInMinutes mins"),
        const SizedBox(width: 16),
        // Servings tag
        _buildTag(Icons.people_outline, "$servings servings"),
        // Can add HealthScore or Price tags if needed
      ],
    );
  }

  /// Builds a pill-shaped tag with icon and text
  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}