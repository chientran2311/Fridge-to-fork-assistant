import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/auth/login.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/rotate_logo.dart';
import '../../widgets/auth/big_title.dart';
import '../../widgets/auth/custom_input.dart';
import '../../widgets/auth/primary_button.dart';
import '../../utils/responsive_layout.dart'; // Đừng quên import file này

class Registerscreen extends StatelessWidget {
  const Registerscreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // BẮT ĐẦU CẤU TRÚC RESPONSIVE
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 450), // Giới hạn chiều rộng
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40), // Giảm xuống 40 cho thoáng
                          const RotatedLogo(),
                          
                          // Khoảng cách linh hoạt
                          SizedBox(height: ResponsiveLayout.isMobile(context) ? 60 : 100),
                          
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
                          const SizedBox(height: 16),
                          const CustomInput(
                            hint: "Rewrite Password",
                            obscure: true,
                          ),
                          const SizedBox(height: 30),
                          
                          PrimaryButton(
                            text: "Register now",
                            onPressed: () {
                              // Khi đăng ký xong thường sẽ vào thẳng Home hoặc Login
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                          
                          const Spacer(),
                          
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              // Dùng pop để quay lại màn hình Login trước đó (tránh tạo chồng screen vô hạn)
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Already have account? Login",
                              style: GoogleFonts.merriweather(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // KẾT THÚC CẤU TRÚC RESPONSIVE
      ),
    );
  }
}