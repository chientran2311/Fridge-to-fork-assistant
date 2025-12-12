import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/rotate_logo.dart';
import '../../widgets/auth/big_title.dart';
import '../../widgets/auth/custom_input.dart';
import '../../widgets/auth/primary_button.dart';
import 'register.dart';
import '../fridge/fridge_home.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const RotatedLogo(),
              const SizedBox(height: 120),
              const BigTitle(),
              const SizedBox(height: 30),
              const CustomInput(
                hint: "Email",
                obscure: false,
              ),
              const SizedBox(height: 16),
              const CustomInput(
                hint: "Password",
                obscure: true,
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: "Explore the app",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FridgeHomeScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Registerscreen(),
                    ),
                  );
                },
                child: Text(
                  "Don’t have account? Register",
                  style: GoogleFonts.merriweather(
                      color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
