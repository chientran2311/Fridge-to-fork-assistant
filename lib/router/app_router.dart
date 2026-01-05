/// ============================================
/// APP ROUTER - NAVIGATION CONFIGURATION
/// ============================================
/// 
/// GoRouter configuration for Recipe Detail Screen feature.
/// 
/// Routes:
/// - /recipe/detail: Recipe detail screen with full information
/// 
/// Features:
/// - Firebase Auth state listening
/// - Recipe data passed via extra parameter
/// - Stream-based route refresh
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import screens and models
import '../screens/recipe/detail_recipe.dart';
import '../models/household_recipe.dart';

// Global navigator key for external navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main router configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/recipe/detail',

  // Listen to auth state changes
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  routes: [
    // Recipe detail route - displays full recipe information
    GoRoute(
      path: '/recipe/detail',
      builder: (context, state) {
        // Get recipe from extra parameter or create sample
        final recipe = state.extra as HouseholdRecipe? ?? 
          HouseholdRecipe(
            apiRecipeId: 716429,
            title: 'Sample Recipe',
          );
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
  ],
);

/// Utility class to convert Stream to Listenable for GoRouter refresh
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
