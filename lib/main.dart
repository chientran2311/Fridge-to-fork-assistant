import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// 1. Import Localizations (Quan trọng: Trỏ đúng vào file bạn đang lưu)
import 'l10n/app_localizations.dart'; 

// Import Providers
import 'providers/locale_provider.dart';
import 'package:fridge_to_fork_assistant/providers/inventory_provider.dart';
import 'package:fridge_to_fork_assistant/providers/recipe_provider.dart';

// Import Router
import 'package:fridge_to_fork_assistant/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ Lưu ý: Không tìm thấy file .env hoặc lỗi config: $e");
  }

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
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      // Dùng Consumer để lắng nghe thay đổi ngôn ngữ từ LocaleProvider
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Bếp Trợ Lý',
            
            // --- CẤU HÌNH ĐA NGÔN NGỮ ---
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            
            // Thay vì cố định 'vi', ta lấy từ Provider để đổi được ngôn ngữ
            // Nếu LocaleProvider chưa hoàn thiện, bạn có thể đổi lại thành: const Locale('vi')
            locale: localeProvider.locale, 

            // --- CẤU HÌNH THEME ---
            theme: ThemeData(
              useMaterial3: true,
              
              // 1. Màu sắc
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0FBD3B),
                primary: const Color(0xFF0FBD3B),
                secondary: const Color(0xFFFF9F1C),
                surface: Colors.white,
                background: const Color(0xFFF8F9FA),
              ),
              
              // 2. Font chữ
              fontFamily: 'Roboto', 
              
              // 3. AppBar
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                titleTextStyle: TextStyle(
                  color: Color(0xFF1B3B36),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: Color(0xFF1B3B36)),
              ),

              // 4. Input (Ô nhập liệu)
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF0FBD3B), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),

              // 5. Button
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0FBD3B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              // 6. Floating Action Button
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF0FBD3B),
                foregroundColor: Colors.white,
                shape: CircleBorder(),
              ),
              
              // dialogTheme đã được comment theo yêu cầu cũ
              // dialogTheme: DialogTheme(...)
            ),
            
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}