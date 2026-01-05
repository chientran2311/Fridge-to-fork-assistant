/// ============================================
/// MAIN.DART - APPLICATION ENTRY POINT
/// ============================================
/// 
/// Entry point for Fridge to Fork Assistant app.
/// Focused on AI Recipe Search feature.
/// 
/// Initialization:
/// - Firebase Core setup
/// - Environment variables (.env) for API keys
/// - Provider setup (RecipeProvider, InventoryProvider)
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Import Localization
import 'l10n/app_localizations.dart';

// Import Providers
import 'package:fridge_to_fork_assistant/providers/inventory_provider.dart';
import 'package:fridge_to_fork_assistant/providers/recipe_provider.dart';

// Import Router
import 'package:fridge_to_fork_assistant/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables (API keys)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ config: $e");
  }

  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inventory provider for ingredient data
        ChangeNotifierProvider(
          create: (_) => InventoryProvider()..listenToInventory(),
          lazy: false,
        ),
        // Recipe provider for AI recipe search
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Fridge to Fork - AI Recipe',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B3B36),
          ),
          useMaterial3: true,
          fontFamily: 'Merriweather',
        ),

        // Localization support
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),

        // Router configuration
        routerConfig: appRouter,
      ),
    );
  }
}
