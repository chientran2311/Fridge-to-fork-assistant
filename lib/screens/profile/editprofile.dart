import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/primary_button.dart';
import '../../widgets/auth/custom_input.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF214130);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // TITLE
              Text(
                "Edit profile",
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 30),

              // AVATAR UPLOAD
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white70, size: 28),
                ),
              ),

              const SizedBox(height: 40),

              // FORM FIELDS
              _label("Name profile"),
              const CustomInput(hint: "", obscure: false),
              const SizedBox(height: 16),

              _label("Email"),
              const CustomInput(hint: "", obscure: false),
              const SizedBox(height: 16),

              _label("Phone number"),
              const CustomInput(hint: "", obscure: false),
              const SizedBox(height: 16),

              _label("Age"),
              const CustomInput(hint: "", obscure: false),
              const SizedBox(height: 16),

              _label("Link to profile"),
              const CustomInput(hint: "", obscure: false),

              const SizedBox(height: 40),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: "Cancel",
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: PrimaryButton(
                      text: "Save",
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.merriweather(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }
}
