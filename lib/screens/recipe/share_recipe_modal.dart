import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class ShareModal extends StatefulWidget {
  final String url; // Link cần share

  const ShareModal({super.key, required this.url});

  // --- HÀM STATIC GỌI MODAL ---
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
  State<ShareModal> createState() => _ShareModalState();
}

class _ShareModalState extends State<ShareModal> {
  final Color mainColor = const Color(0xFF1B3B36);
  bool _isCopied = false; // Trạng thái để đổi icon khi copy xong

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final BorderRadius borderRadius = isDesktop
        ? BorderRadius.circular(24)
        : const BorderRadius.vertical(top: Radius.circular(24));

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
          // 1. Handle Bar (Mobile)
          if (!isDesktop)
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),

          // 2. Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Share Recipe",
                    style: GoogleFonts.merriweather(
                      fontSize: 20, fontWeight: FontWeight.bold, color: mainColor
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Share this meal with friends",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.grey,
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 24),

          // 3. Link Copy Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F6), // Xám xanh rất nhạt
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _copyToClipboard,
                  style: TextButton.styleFrom(
                    backgroundColor: _isCopied ? Colors.green.shade100 : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: _isCopied ? Colors.transparent : Colors.grey.shade300)
                    ),
                  ),
                  child: Text(
                    _isCopied ? "Copied!" : "Copy",
                    style: TextStyle(
                      color: _isCopied ? Colors.green[800] : mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // 4. Social Icons Grid
          Text(
            "Share via",
            style: GoogleFonts.merriweather(
              fontSize: 16, fontWeight: FontWeight.bold, color: mainColor
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialIcon("Messenger", Icons.chat_bubble, const Color(0xFF0084FF)),
              _buildSocialIcon("Facebook", Icons.facebook, const Color(0xFF1877F2)),
              _buildSocialIcon("Instagram", Icons.camera_alt, const Color(0xFFE4405F)),
              _buildSocialIcon("More", Icons.more_horiz, Colors.grey.shade200, iconColor: Colors.black54),
            ],
          ),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // --- Logic Copy ---
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.url));
    setState(() => _isCopied = true);
    
    // Reset lại trạng thái sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  // --- Helper Widget: Social Icon ---
  Widget _buildSocialIcon(String label, IconData icon, Color bgColor, {Color iconColor = Colors.white}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Xử lý share logic ở đây
            print("Shared via $label");
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            color: Colors.grey[600],
            fontWeight: FontWeight.w500
          ),
        )
      ],
    );
  }
}