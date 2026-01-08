import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/notification_provider.dart';
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

// Import Native Splash
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // Giữ splash screen cho đến khi khởi tạo xong
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // Load từ assets/.env (Flutter Web và Mobile đều hoạt động)
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint("⚠️ Dotenv config: $e");
  }

  // [QUAN TRỌNG] Load trạng thái onboarding TRƯỚC khi khởi tạo router
  await initializeRouter();

  // [QUAN TRỌNG] Truyền key (lấy từ app_router.dart) vào Service
  await NotificationService().init(rootNavigatorKey);

  // Xóa splash screen sau khi khởi tạo xong
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        ChangeNotifierProvider(create: (_) => NotificationProvider(), lazy: false),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProfileImage();
  }
  
  void _syncProfileImage() {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.read<ProfileImageProvider>();
    
    final currentUserId = authProvider.user?.uid;
    
    // Chỉ load khi userId thay đổi (đăng nhập user khác hoặc đăng xuất)
    if (currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      
      // Delay để tránh gọi notifyListeners trong build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        if (currentUserId != null) {
          // User đăng nhập -> load ảnh của user đó
          profileProvider.loadProfileImageForUser(currentUserId);
        } else {
          // User đăng xuất -> reset về mặc định
          profileProvider.resetToDefault();
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
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
