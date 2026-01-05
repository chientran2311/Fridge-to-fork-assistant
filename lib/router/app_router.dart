import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import màn hình
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/meal&plan/planner/planner_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/planner',
  
  // ✅ Refresh router khi auth state thay đổi
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  
  // ✅ Redirect logic: chưa login -> login, đã login -> planner
  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isLoggingIn = state.matchedLocation == '/login' || 
                              state.matchedLocation == '/register';
    
    // Nếu chưa login và không phải đang ở trang login -> redirect về login
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    
    // Nếu đã login mà đang ở trang login -> redirect về planner
    if (isLoggedIn && isLoggingIn) {
      return '/planner';
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
      path: '/planner',
      builder: (context, state) => const PlannerScreen(),
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