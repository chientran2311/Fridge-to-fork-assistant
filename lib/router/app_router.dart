/// ============================================
/// APP ROUTER - Cấu hình điều hướng ứng dụng
/// Sử dụng GoRouter với Firebase Auth
/// ============================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Import màn hình chính
import '../screens/auth/register.dart';

/// Key global cho Navigator - dùng cho NotificationService
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router chính của ứng dụng
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/register',
  
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

  redirect: (context, state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isOnRegister = state.matchedLocation == '/register';

    if (!isLoggedIn && !isOnRegister) return '/register';
    if (isLoggedIn && isOnRegister) return '/home';
    
    return null;
  },

  routes: [
    GoRoute(
      path: '/register', 
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dang ky thanh cong!'),
        backgroundColor: const Color(0xFF1B3B36),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Color(0xFF1B3B36)),
            const SizedBox(height: 24),
            const Text(
              'Chao mung ban!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Email: ${FirebaseAuth.instance.currentUser?.email ?? "N/A"}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3B36),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Dang xuat', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
