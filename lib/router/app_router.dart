import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; 

// Import các màn hình chính
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/main_screen.dart';
import '../screens/fridge/fridge_home.dart';
import '../screens/recipe/ai_recipe.dart';
import '../screens/meal&plan/planner_screen.dart';

// [MỚI] Import màn hình chi tiết, settings, favorite
import '../../screens/recipe/detail_recipe.dart'; // Kiểm tra lại đường dẫn file này
import '../models/household_recipe.dart'; 
import '../screens/settings/settings.dart'; // [Cần tạo file này hoặc import đúng]
import '../screens/recipe/favorite_recipes.dart'; // [Cần tạo file này hoặc import đúng]

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/fridge',
  
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/fridge';
    return null; 
  },

  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),

    // Shell Route (Chứa Bottom Bar)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // --- Branch 0: Fridge & Settings ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fridge',
              builder: (context, state) => const FridgeHomeScreen(),
              routes: [
                // Đường dẫn con: /fridge/settings
                // Vì không nằm trong list MainScreen -> Tự động ẩn BottomBar
                GoRoute(
                  path: 'settings', 
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        
        // --- Branch 1: Recipes, Detail & Favorites ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (context, state) => const AIRecipeScreen(),
              routes: [
                // Đường dẫn con: /recipes/detail
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final recipe = state.extra as HouseholdRecipe;
                    return RecipeDetailScreen(recipe: recipe);
                  },
                ),
                // Đường dẫn con: /recipes/favorites
                GoRoute(
                  path: 'favorites',
                  builder: (context, state) => const FavoriteRecipesScreen(),
                ),
              ],
            ),
          ],
        ),

        // --- Branch 2: Planner ---
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const PlannerScreen(),
            ),
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
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}