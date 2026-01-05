/// ============================================
/// MAIN.DART - Entry point của ứng dụng
/// Fridge to Fork Assistant - Register Module
/// ============================================
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Import Localization để hỗ trợ đa ngôn ngữ
import 'l10n/app_localizations.dart';

/// Import Router - GoRouter configuration
import 'package:fridge_to_fork_assistant/router/app_router.dart';

/// Import Notification Service - FCM handling
import 'data/services/notification_service.dart';

/// Hàm main - khởi tạo app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khoi tao Notification Service
  await NotificationService().init(rootNavigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Register App',
      
      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),

      // Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3B36),
          primary: const Color(0xFF1B3B36),
          surface: Colors.white,
        ),
        fontFamily: 'Merriweather',
      ),
      
      routerConfig: appRouter,
    );
  }
}
