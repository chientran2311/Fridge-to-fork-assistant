import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import màn hình
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/meal&plan/planner/planner_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  
  // ✅ Refresh router khi auth state thay đổi
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  
  // ✅ Redirect logic
  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isLoggingIn = state.matchedLocation == '/login' || 
                              state.matchedLocation == '/register';
    
    // Nếu chưa login và không phải đang ở trang login -> redirect về login
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    
    // Nếu đã login mà đang ở trang login -> redirect về planner detail
    if (isLoggedIn && isLoggingIn) {
      return '/planner-detail';
    }
    
    return null;
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
    GoRoute(
      path: '/planner-detail',
      builder: (context, state) {
        // Demo data - trong thực tế sẽ nhận từ navigation
        return const PlannerDetailScreen(
          recipeId: 'demo_recipe',
          householdId: 'demo_household',
          mealPlanDate: '2026-01-05',
          mealType: 'lunch',
          mealPlanServings: 2,
        );
      },
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