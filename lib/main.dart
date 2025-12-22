import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. IMPORT QUAN TRỌNG ĐỂ CÓ MULTIPROVIDER ---
import 'package:provider/provider.dart'; 

// 2. Import file cấu hình Firebase
import 'firebase_options.dart';

// 3. Import Router
import 'router/app_router.dart';

// 4. Import các Provider (Bạn đã tạo ở bước trước)
import 'providers/inventory_provider.dart';
import 'providers/recipe_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // --- KHỐI MULTIPROVIDER Ở ĐÂY ---
    // Nó bọc lấy MyApp để cung cấp dữ liệu cho toàn bộ ứng dụng
    MultiProvider(
      providers: [
        // 1. Provider quản lý Kho (Tủ lạnh)
        // Dùng cascade (..) để gọi hàm lắng nghe ngay khi khởi tạo
        ChangeNotifierProvider(
          create: (_) => InventoryProvider()..listenToInventory(),
        ),

        // 2. Provider quản lý Công thức & API
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(),
        ),
      ],
      // App chính nằm bên trong MultiProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bếp Trợ Lý',
      
      // Cấu hình Theme
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0FBD3B), // Màu xanh lá chủ đạo
          primary: const Color(0xFF0FBD3B),
        ),
      ),

      // Kết nối GoRouter
      routerConfig: appRouter, 
    );
  }
}