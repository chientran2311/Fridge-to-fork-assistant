// =============================================================================
// APP ROUTER - NAVIGATION FOR EXPIRY ALERT FEATURE
// =============================================================================
// File: lib/router/app_router.dart
// Feature: Deep Link Navigation for Expiry Alert Notifications
// Description: GoRouter configuration cho Recipe screens với deep link
//              support từ push notifications.
//
// Routes:
//   - /recipes: AIRecipeScreen (với search query từ notification)
//   - /recipes/detail: RecipeDetailScreen
//   - /recipes/favorites: FavoriteRecipesScreen
//
// Deep Link Flow:
//   Notification tap -> NotificationService._handleNavigate()
//   -> appRouter.go('/recipes?search=ingredients') -> AIRecipeScreen
//
// Author: Fridge to Fork Team
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// Screen imports
import '../screens/recipe/ai_recipe.dart';
import '../screens/recipe/detail_recipe.dart';
import '../screens/recipe/favorite_recipes.dart';

// Model imports
import '../models/household_recipe.dart';

// =============================================================================
// GLOBAL NAVIGATOR KEY - Used by NotificationService for navigation
// =============================================================================
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// =============================================================================
// APP ROUTER CONFIGURATION
// =============================================================================
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/recipes',

  // ===========================================================================
  // RECIPE ROUTES
  // ===========================================================================
  routes: [
    // -------------------------------------------------------------------------
    // MAIN RECIPE ROUTE - /recipes
    // Supports deep link: /recipes?search=ingredient1,ingredient2
    // -------------------------------------------------------------------------
    GoRoute(
      path: '/recipes',
      builder: (context, state) {
        // Parse search query from notification deep link
        final searchQuery = state.uri.queryParameters['search'];
        return AIRecipeScreen(initialQuery: searchQuery);
      },
      routes: [
        // ---------------------------------------------------------------------
        // RECIPE DETAIL - /recipes/detail
        // Receives HouseholdRecipe via state.extra
        // ---------------------------------------------------------------------
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final recipe = state.extra as HouseholdRecipe;
            return RecipeDetailScreen(recipe: recipe);
          },
        ),
        
        // ---------------------------------------------------------------------
        // FAVORITES - /recipes/favorites
        // ---------------------------------------------------------------------
        GoRoute(
          path: 'favorites',
          builder: (context, state) => const FavoriteRecipesScreen(),
        ),
      ],
    ),
  ],
);

// =============================================================================
// GO ROUTER REFRESH STREAM UTILITY
// =============================================================================
/// Utility class to convert Stream to Listenable for router refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  
  late final StreamSubscription<dynamic> _subscription;
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
