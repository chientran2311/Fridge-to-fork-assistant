/// ============================================
/// APP ROUTER - SETTINGS FEATURE NAVIGATION
/// ============================================
/// 
/// GoRouter configuration for Settings feature:
/// - Authentication redirect logic
/// - Settings screen routing
/// - Firebase auth state refresh
/// 
/// Routes:
/// - /settings: Main settings screen
/// - /login: Authentication screen
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Screen imports
import '../screens/settings/settings.dart';

// Global navigator key for Settings feature
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Onboarding completion status
bool _hasCompletedOnboarding = false;

/// Key for SharedPreferences
const String kOnboardingCompletedKey = 'onboarding_completed';

/// Initialize router after checking onboarding status
Future<void> initializeRouter() async {
  final prefs = await SharedPreferences.getInstance();
  _hasCompletedOnboarding = prefs.getBool(kOnboardingCompletedKey) ?? false;
}

/// Mark onboarding as completed
void markOnboardingCompleted() {
  _hasCompletedOnboarding = true;
}

/// Main router configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/settings',

  // Listen to Firebase auth state changes
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  // Route definitions
  routes: [
    // Settings route - main screen for this feature
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
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
