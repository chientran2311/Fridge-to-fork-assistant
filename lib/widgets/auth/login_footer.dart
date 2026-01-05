import 'package:flutter/material.dart';
// import '../../screens/auth/register.dart';

class SignupFooter extends StatelessWidget {
  const SignupFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "New here? ",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            // Điều hướng sang trang đăng ký
            // Navigator.push(
            //   context,
            //   // MaterialPageRoute(builder: (context) => const RegisterScreen()),
            // );
          },
          child: const Text(
            "Create an account",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
