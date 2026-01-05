/// ============================================
/// FAVORITE SCREEN - SAVED RECIPES DISPLAY
/// ============================================
/// 
/// This screen displays user's favorite/saved recipes.
/// 
/// Features:
/// - List all favorited recipes from Firestore
/// - Pull-to-refresh functionality
/// - Remove from favorites with swipe
/// - Navigate to recipe details
/// 
/// Dependencies:
/// - RecipeProvider for favorite state management
/// - HouseholdRecipe model for recipe data
/// - RecipeCard widget for display
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipe/ai_recipe/recipe_card.dart';
import '../../l10n/app_localizations.dart';

/// Main screen for displaying user's favorite recipes
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to favorites when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().listenToFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(s.favoriteRecipes),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B3B36),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final favorites = recipeProvider.favoriteRecipes;

          // Loading state
          if (recipeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B3B36),
              ),
            );
          }

          // Empty state
          if (favorites.isEmpty) {
            return _buildEmptyState(s);
          }

          // Favorites list
          return RefreshIndicator(
            onRefresh: () async {
              recipeProvider.listenToFavorites();
            },
            color: const Color(0xFF1B3B36),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecipeCard(recipe: recipe),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Build empty state when no favorites exist
  Widget _buildEmptyState(AppLocalizations s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            s.noFavoriteRecipes,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.addFavoriteHint,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
