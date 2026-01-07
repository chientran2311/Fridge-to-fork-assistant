import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Import các màn hình
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/main_screen.dart';
import '../screens/fridge/fridge_home.dart';
import '../screens/recipe/ai_recipe.dart';
import '../screens/meal&plan/planner/planner_screen.dart';
import '../../screens/recipe/detail_recipe.dart';
import '../models/household_recipe.dart';
import '../screens/settings/settings.dart';
import '../screens/recipe/favorite_recipes.dart';
import '../screens/intro/onboarding_screen.dart';

// [QUAN TRỌNG] Khai báo biến global public để Main dùng chung
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Biến lưu trạng thái onboarding (được load từ SharedPreferences khi app khởi động)
bool _hasCompletedOnboarding = false;

/// Khởi tạo router sau khi đã kiểm tra onboarding status
Future<void> initializeRouter() async {
  final prefs = await SharedPreferences.getInstance();
  _hasCompletedOnboarding = prefs.getBool(kOnboardingCompletedKey) ?? false;
}

/// Cập nhật trạng thái onboarding đã hoàn thành (gọi từ OnboardingScreen)
void markOnboardingCompleted() {
  _hasCompletedOnboarding = true;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey, // Gắn chìa khóa vào đây
  initialLocation: '/fridge',

  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isOnboarding = state.matchedLocation == '/onboarding';
    final bool isLoggingIn = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // 1. Nếu chưa hoàn thành onboarding VÀ chưa login -> redirect về onboarding
    if (!_hasCompletedOnboarding && !isLoggedIn && !isOnboarding) {
      return '/onboarding';
    }

    // 2. Nếu đã hoàn thành onboarding (hoặc đã login) nhưng chưa login -> redirect về login
    if (!isLoggedIn && !isLoggingIn && !isOnboarding) {
      return '/login';
    }

    // 3. Nếu đã login mà đang ở login/register/onboarding -> redirect về fridge
    if (isLoggedIn && (isLoggingIn || isOnboarding)) {
      return '/fridge';
    }

    return null;
  },

  routes: [
    // Route Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
        path: '/register', builder: (context, state) => const RegisterScreen()),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Fridge
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fridge',
              builder: (context, state) => const FridgeHomeScreen(),
              routes: [
                GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen()),
              ],
            ),
          ],
        ),

        // Branch 2: Recipes (Có logic Deep Link)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (context, state) {
                // Hứng tham số search từ URL (do Notification Service gọi)
                final searchQuery = state.uri.queryParameters['search'];
                return AIRecipeScreen(initialQuery: searchQuery);
              },
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final recipe = state.extra as HouseholdRecipe;
                    return RecipeDetailScreen(recipe: recipe);
                  },
                ),
                GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoriteRecipesScreen()),
              ],
            ),
          ],
        ),

        // Branch 3: Planner
        StatefulShellBranch(
          routes: [
            GoRoute(
                path: '/planner',
                builder: (context, state) => const PlannerScreen()),
          ],
        ),
      ],
    ),
  ],
);

// Class tiện ích Stream -> Listenable
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
