import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Cần import thư viện này cho Stream

// Import các màn hình
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/main_screen.dart';
import '../screens/fridge/fridge_home.dart';
import '../screens/recipe/ai_recipe.dart';
import '../screens/meal&plan/planner_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/fridge',
  
  // --- [QUAN TRỌNG 1] Lắng nghe thay đổi Auth ---
  // Nếu thiếu dòng này, Router sẽ bị "điếc", không biết bạn đã login xong
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  // --- [QUAN TRỌNG 2] Logic chuyển hướng (Guard) ---
  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    
    // Kiểm tra xem user có đang ở trang Login hoặc Register không
    final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    // 1. Nếu chưa đăng nhập mà không phải đang ở trang login/register -> Đá về Login
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    // 2. Nếu ĐÃ đăng nhập mà vẫn đang ở trang Login/Register -> Đá vào trong (Fridge)
    // Đây là lý do tại sao màn hình tự chuyển mà không cần context.go (nhưng giữ context.go cũng không sao)
    if (isLoggedIn && isLoggingIn) {
      return '/fridge';
    }

    return null; // Không làm gì cả, cho phép đi tiếp
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Shell Route cho MainScreen
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Fridge
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fridge',
              builder: (context, state) => const FridgeHomeScreen(),
            ),
          ],
        ),
        // Branch 1: Recipes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (context, state) => const AIRecipeScreen(),
            ),
          ],
        ),
        // Branch 2: Planner
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

// --- [QUAN TRỌNG 3] Class tiện ích để biến Stream thành Listenable ---
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