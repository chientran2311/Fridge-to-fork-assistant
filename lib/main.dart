import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/main_screen.dart';
import 'package:fridge_to_fork_assistant/screens/meal&plan/planner/planner_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import này
import 'firebase_options.dart';
void main() async {
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
      home: const MainScreen(),
    );
  }
}
