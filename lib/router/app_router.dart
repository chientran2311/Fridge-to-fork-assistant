import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import các màn hình
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/fridge/fridge_home.dart';
import '../screens/fridge/fridge_barcode_scan.dart';


// [QUAN TRỌNG] Khai báo biến global public để Main dùng chung
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Khởi tạo router (giữ lại hàm này để không phá vỡ code gọi từ main.dart)
Future<void> initializeRouter() async {
  // Không còn logic onboarding nữa
}

/// Deprecated - không còn dùng onboarding
void markOnboardingCompleted() {
  // Không còn logic onboarding nữa
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey, // Gắn chìa khóa vào đây
  initialLocation: '/fridge',

  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isLoggingIn = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // Nếu chưa login và không đang ở trang login/register -> redirect về login
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    // Nếu đã login mà đang ở login/register -> redirect về fridge
    if (isLoggedIn && isLoggingIn) {
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
      routes: [
        GoRoute(
            path: 'barcode-scan',
            builder: (context, state) => const FridgeBarcodeScanScreen()),
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
