/// ============================================
/// JOIN HOUSEHOLD DIALOG WIDGET
/// ============================================
/// 
/// Dialog for joining an existing household:
/// - Text input for invite code
/// - Code validation
/// - Loading state during join process
/// - Styled with app theme colors
/// 
/// Features:
/// - Invite code validation (required, format check)
/// - Async join callback
/// - Auto-dismiss on success
/// - Custom styled AlertDialog
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog widget for joining households via invite code
class JoinHouseholdDialog extends StatefulWidget {
  /// Callback function when user submits invite code
  final Function(String code) onJoinHousehold;

  const JoinHouseholdDialog({
    super.key,
    required this.onJoinHousehold,
  });

  @override
  State<JoinHouseholdDialog> createState() => _JoinHouseholdDialogState();
}

/// State for JoinHouseholdDialog with form management
class _JoinHouseholdDialogState extends State<JoinHouseholdDialog> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Handle join request with validation
  void _handleJoin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await widget.onJoinHousehold(_codeController.text.trim());
      setState(() => _isLoading = false);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF1B3B36);

    return AlertDialog(
      backgroundColor: const Color(0xFFF9F9F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      // Dialog title with icon
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, mainColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.login,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tham gia tủ lạnh',
                  style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Text(
                  'Nhập mã mời để tham gia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _codeController,
              autofocus: true,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Mã mời',
                hintText: 'Nhập mã 6 ký tự',
                hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 1),
                prefixIcon: Icon(Icons.vpn_key, color: mainColor),
                suffixIcon: Icon(Icons.qr_code_scanner, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: mainColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã mời';
                }
                // Remove dashes and spaces for validation
                final cleanCode = value.replaceAll(RegExp(r'[-\s]'), '');
                if (cleanCode.length < 6) {
                  return 'Mã mời không hợp lệ (tối thiểu 6 ký tự)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hỏi chủ tủ lạnh để lấy mã mời',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Hủy',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: mainColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Tham gia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
