import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login.dart';

import 'package:firebase_core/firebase_core.dart'; // 1. Import này
import 'firebase_options.dart'; // 2. Import file vừa được sinh ra ở bước trên
void main() async { // 3. Thêm từ khóa async
  // 4. Đảm bảo binding được khởi tạo trước
  WidgetsFlutterBinding.ensureInitialized();
  
  // 5. Khởi tạo Firebase với cấu hình từ file options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // fontFamily: GoogleFonts.merriweather().fontFamily,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      home: const LoginScreen(),
    );
  }
}
