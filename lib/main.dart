import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Import Localization
import 'l10n/app_localizations.dart';

// Import Providers
import 'providers/locale_provider.dart';
import 'package:fridge_to_fork_assistant/providers/inventory_provider.dart';
import 'package:fridge_to_fork_assistant/providers/recipe_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/household_provider.dart';
import 'providers/profile_image_provider.dart';

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

  // [QUAN TRỌNG] Load trạng thái onboarding TRƯỚC khi khởi tạo router
  await initializeRouter();

  // [QUAN TRỌNG] Truyền key (lấy từ app_router.dart) vào Service
  await NotificationService().init(rootNavigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => InventoryProvider()..listenToInventory(),
            lazy: false),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HouseholdProvider()),
        ChangeNotifierProvider(create: (_) => ProfileImageProvider()),
      ],
      child: const _AuthProfileImageSync(
        child: _AppWithLocale(),
      ),
    );
  }
}

/// Widget lắng nghe thay đổi auth state và sync với ProfileImageProvider
/// Khi user đăng nhập: load ảnh của user đó
/// Khi user đăng xuất: reset về mặc định
class _AuthProfileImageSync extends StatefulWidget {
  final Widget child;
  
  const _AuthProfileImageSync({required this.child});
  
  @override
  State<_AuthProfileImageSync> createState() => _AuthProfileImageSyncState();
}

class _AuthProfileImageSyncState extends State<_AuthProfileImageSync> {
  String? _lastUserId;
  
  @override
  Widget build(BuildContext context) {
    // ✅ Lắng nghe AuthProvider trong build
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.uid;
    
    // ✅ Sử dụng addPostFrameCallback để tránh gọi notifyListeners() trong build
    if (currentUserId != _lastUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        _lastUserId = currentUserId;
        final profileProvider = context.read<ProfileImageProvider>();
        
        if (currentUserId != null) {
          // User đăng nhập -> load ảnh của user đó
          profileProvider.loadProfileImageForUser(currentUserId);
        } else {
          // User đăng xuất -> reset về mặc định
          profileProvider.resetToDefault();
        }
      });
    }
    
    return widget.child;
  }
}

/// Widget con có locale
class _AppWithLocale extends StatelessWidget {
  const _AppWithLocale();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Bếp Trợ Lý',

          // Localization
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,

          // Theme
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

          // [QUAN TRỌNG] Gắn router đã cấu hình key
          routerConfig: appRouter,
        );
      },
    );
  }
}
