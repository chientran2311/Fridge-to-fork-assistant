import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/share/copy_link_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/share/share_header.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/share/social_icon_button.dart';

class ShareModal extends StatelessWidget {
  final String url;

  const ShareModal({super.key, required this.url});

  static void show(BuildContext context, {String url = "https://fridge2fork.app/recipe/123"}) {
    if (ResponsiveLayout.isDesktop(context)) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 420,
            child: ShareModal(url: url),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => ShareModal(url: url),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final BorderRadius borderRadius = isDesktop
        ? BorderRadius.circular(24)
        : const BorderRadius.vertical(top: Radius.circular(24));
    final Color mainColor = const Color(0xFF1B3B36);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          const ShareHeader(),
          const SizedBox(height: 24),
          CopyLinkSection(url: url),
          const SizedBox(height: 32),
          Text(
            "Share via",
            style: GoogleFonts.merriweather(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SocialIconButton(
                label: "Messenger",
                icon: Icons.chat_bubble,
                backgroundColor: Color(0xFF0084FF),
              ),
              SocialIconButton(
                label: "Facebook",
                icon: Icons.facebook,
                backgroundColor: Color(0xFF1877F2),
              ),
              SocialIconButton(
                label: "Instagram",
                icon: Icons.camera_alt,
                backgroundColor: Color(0xFFE4405F),
              ),
              SocialIconButton(
                label: "More",
                icon: Icons.more_horiz,
                backgroundColor: Color(0xFFE0E0E0),
                iconColor: Colors.black54,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}