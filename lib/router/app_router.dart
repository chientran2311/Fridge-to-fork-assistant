/// ============================================
/// APP ROUTER - NAVIGATION CONFIGURATION
/// ============================================
/// 
/// GoRouter configuration for AI Recipe Screen feature.
/// 
/// Routes:
/// - /recipes: Main AI recipe search screen
/// 
/// Features:
/// - Firebase Auth state listening
/// - Deep link support for recipe search
/// - Stream-based route refresh
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import screens
import '../screens/recipe/ai_recipe.dart';

// Global navigator key for external navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main router configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/recipes',

  // Listen to auth state changes
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  routes: [
    // AI Recipe search route with deep link support
    GoRoute(
      path: '/recipes',
      builder: (context, state) {
        // Support search query from deep link or notification
        final searchQuery = state.uri.queryParameters['search'];
        return AIRecipeScreen(initialQuery: searchQuery);
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
