import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Import Localization
// import 'l10n/app_localizations.dart';

// Import Providers
// import 'providers/locale_provider.dart';
// import 'package:fridge_to_fork_assistant/providers/inventory_provider.dart';
// import 'package:fridge_to_fork_assistant/providers/recipe_provider.dart';
import 'providers/auth_provider.dart';
// import 'providers/household_provider.dart';

// Import Router (Để lấy biến rootNavigatorKey và appRouter)
import 'package:fridge_to_fork_assistant/router/app_router.dart';

// Import Notification Service
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ config: $e");
  }

  // [QUAN TRỌNG] Truyền key (lấy từ app_router.dart) vào Service
  await NotificationService().init(rootNavigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => InventoryProvider()..listenToInventory(), lazy: false),
        // ChangeNotifierProvider(create: (_) => RecipeProvider()),
        // ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(create: (_) => HouseholdProvider()), // [MỚI] Thêm HouseholdProvider
      ],
      // child: Consumer<LocaleProvider>(
      //   builder: (context, localeProvider, child) {
      //     return MaterialApp.router(
      //       debugShowCheckedModeBanner: false,
      //       title: 'Bếp Trợ Lý',
            
      //       // Localization
      //       localizationsDelegates: AppLocalizations.localizationsDelegates,
      //       supportedLocales: AppLocalizations.supportedLocales,
      //       locale: localeProvider.locale, 

      //       // Theme
      //       theme: ThemeData(
      //         useMaterial3: true,
      //         colorScheme: ColorScheme.fromSeed(
      //           seedColor: const Color(0xFF0FBD3B),
      //           primary: const Color(0xFF0FBD3B),
      //           secondary: const Color(0xFFFF9F1C),
      //           surface: Colors.white,
      //         ),
      //         fontFamily: 'Merriweather', 
      //         elevatedButtonTheme: ElevatedButtonThemeData(
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: const Color(0xFF0FBD3B),
      //             foregroundColor: Colors.white,
      //             elevation: 0,
      //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //           ),
      //         ),
      //       ),
            
      //       // [QUAN TRỌNG] Gắn router đã cấu hình key
      //       routerConfig: appRouter,
      //     );
      //   },
      // ),
    );
  }
}
