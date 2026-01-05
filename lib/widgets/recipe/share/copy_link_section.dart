import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyLinkSection extends StatefulWidget {
  final String url;
  const CopyLinkSection({super.key, required this.url});

  @override
  State<CopyLinkSection> createState() => _CopyLinkSectionState();
}

class _CopyLinkSectionState extends State<CopyLinkSection> {
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.url));
    setState(() => _isCopied = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
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
                side: BorderSide(
                    color: _isCopied ? Colors.transparent : Colors.grey.shade300),
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
    );
  }
}
