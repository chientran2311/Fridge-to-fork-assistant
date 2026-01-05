/// ============================================
/// APP ROUTER - NAVIGATION CONFIGURATION
/// ============================================
/// 
/// GoRouter configuration for Favorite Screen feature.
/// 
/// Routes:
/// - /favorites: Main favorite recipes screen
/// 
/// Features:
/// - Firebase Auth state listening
/// - Stream-based route refresh
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import screens
import '../screens/recipe/favorite_screen.dart';

// Global navigator key for external navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main router configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/favorites',

  // Listen to auth state changes
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  routes: [
    // Favorite recipes route
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoriteScreen(),
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
