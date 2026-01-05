import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import các màn hình
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/fridge/fridge_home.dart';


// [QUAN TRỌNG] Khai báo biến global public để Main dùng chung
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Biến lưu trạng thái onboarding (được load từ SharedPreferences khi app khởi động)
bool _hasCompletedOnboarding = false;

/// Khởi tạo router sau khi đã kiểm tra onboarding status
Future<void> initializeRouter() async {
  // Onboarding đã bị xóa, luôn return true
  _hasCompletedOnboarding = true;
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
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
        path: '/register', builder: (context, state) => const RegisterScreen()),

    GoRoute(
      path: '/fridge',
      builder: (context, state) => const FridgeHomeScreen(),
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
