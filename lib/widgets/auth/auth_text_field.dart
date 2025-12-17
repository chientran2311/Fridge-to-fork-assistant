  import 'package:flutter/material.dart';

  class AuthTextField extends StatelessWidget {
    final String label;
    final String hintText;
    final IconData icon;
    final bool isPassword;
    final bool isObscure;
    final VoidCallback? onIconTap;
    final TextEditingController? controller;

    const AuthTextField({
      super.key,
      required this.label,
      required this.hintText,
      required this.icon,
      this.isPassword = false,
      this.isObscure = false,
      this.onIconTap,
      this.controller,
    });

    @override
    Widget build(BuildContext context) {
      const Color mainColor = Color(0xFF1B3B36);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // TextField
          TextField(
            controller: controller,
            obscureText: isPassword ? isObscure : false,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  isPassword
                      ? (isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined)
                      : icon,
                  color: Colors.grey[600],
                ),
                onPressed: isPassword ? onIconTap : null, // Chỉ cho phép tap nếu là password field
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: mainColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      );
    }
  }