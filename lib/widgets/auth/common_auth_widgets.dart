import 'package:flutter/material.dart';

// 1. Widget TextField kèm Label (Dùng chung cho cả form)
class CustomAuthField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final bool isObscure;
  final VoidCallback? onIconTap;
  final Color mainColor;
  final TextEditingController? controller; // Biến controller để lấy dữ liệu

  const CustomAuthField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.isObscure = false,
    this.onIconTap,
    this.mainColor = const Color(0xFF1B3B36),
    this.controller, // Nhận controller từ bên ngoài (Login/Register Screen)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        // TextField
        TextField(
          controller: controller, // QUAN TRỌNG: Gắn controller vào đây
          obscureText: isPassword ? isObscure : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[500],
                    ),
                    onPressed: onIconTap,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: mainColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// 2. Widget Button Chính (Sign Up / Login)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed; // Hàm xử lý khi bấm nút
  final Color color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF1B3B36),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed, // QUAN TRỌNG: Gắn hàm xử lý vào đây
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// 3. Widget Avatar Tròn
class AvatarDisplay extends StatelessWidget {
  final String imageUrl;
  final double size;

  const AvatarDisplay({
    super.key,
    required this.imageUrl,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}