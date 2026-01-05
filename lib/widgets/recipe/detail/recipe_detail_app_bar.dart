/// ============================================
/// RECIPE DETAIL APP BAR WIDGET
/// ============================================
/// 
/// Custom SliverAppBar for recipe detail screen with:
/// - Expandable hero image header
/// - Back navigation button
/// - Options menu button
/// - Collapsing behavior on scroll
/// 
/// Features:
/// - 300px expandable height for recipe image
/// - Pinned app bar on scroll
/// - Circular icon buttons with semi-transparent background
/// - Network image with error fallback
/// - Options modal integration
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/recipe/option_modal.dart';

/// SliverAppBar with hero image for recipe details
class RecipeDetailAppBar extends StatelessWidget {
  /// URL of the recipe hero image
  final String imageUrl;

  const RecipeDetailAppBar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      // Back navigation button
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      // Options menu button
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                OptionModal.show(context);
              },
            ),
          ),
        ),
      ],
      // Hero image area
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}
