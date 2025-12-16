import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/meal&plan/planner/planner_screen.dart';
import 'package:fridge_to_fork_assistant/screens/meal&plan/planner/planner_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.merriweather().fontFamily,
      ),
      home: const PlannerScreen(),
    );
  }
}
