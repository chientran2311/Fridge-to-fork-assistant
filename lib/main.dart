/// ============================================
/// MAIN ENTRY POINT - SETTINGS FEATURE FOCUS
/// ============================================
/// 
/// Application entry point configured for Settings feature:
/// - Firebase initialization
/// - Provider setup (Auth, Household, Locale)
/// - Localization support (Vietnamese/English)
/// - Theme configuration
/// 
/// Providers for Settings:
/// - LocaleProvider: Language switching
/// - AuthProvider: User authentication state
/// - HouseholdProvider: Multi-household management
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Localization imports
import 'l10n/app_localizations.dart';

// Provider imports for Settings feature
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/household_provider.dart';

// Router configuration
import 'package:fridge_to_fork_assistant/router/app_router.dart';

/// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for authentication and Firestore
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize router before app starts
  await initializeRouter();

  runApp(const MyApp());
}

/// Root application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Language/locale provider
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // User authentication provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Household management provider
        ChangeNotifierProvider(create: (_) => HouseholdProvider()),
      ],
      child: const _AppWithLocale(),
    );
  }
}

/// Widget with locale support
class _AppWithLocale extends StatelessWidget {
  const _AppWithLocale();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Fridge to Fork - Settings',

          // Localization configuration
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,

          // Theme configuration
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0FBD3B),
              primary: const Color(0xFF0FBD3B),
              secondary: const Color(0xFFFF9F1C),
              surface: Colors.white,
            ),
            fontFamily: 'Merriweather',
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0FBD3B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // GoRouter configuration
          routerConfig: appRouter,
        );
      },
    );
  }
}
