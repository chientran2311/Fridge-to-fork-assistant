/// ============================================
/// CREATE HOUSEHOLD DIALOG WIDGET
/// ============================================
/// 
/// Dialog for creating a new household:
/// - Text input for household name
/// - Form validation
/// - Loading state during creation
/// - Styled with app theme colors
/// 
/// Features:
/// - Name validation (required field)
/// - Async creation callback
/// - Auto-dismiss on success
/// - Custom styled AlertDialog
/// 
/// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog widget for creating new households
class CreateHouseholdDialog extends StatefulWidget {
  /// Callback function when household is created
  final Function(String name) onCreateHousehold;

  const CreateHouseholdDialog({
    super.key,
    required this.onCreateHousehold,
  });

  @override
  State<CreateHouseholdDialog> createState() => _CreateHouseholdDialogState();
}

/// State for CreateHouseholdDialog with form management
class _CreateHouseholdDialogState extends State<CreateHouseholdDialog> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Handle household creation with validation
  void _handleCreate() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await widget.onCreateHousehold(_nameController.text.trim());
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
              Icons.kitchen,
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
                  'Tạo tủ lạnh mới',
                  style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Text(
                  'Tạo một không gian mới',
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
              controller: _nameController,
              autofocus: true,
              enabled: !_isLoading,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Tên tủ lạnh',
                hintText: 'VD: Bếp gia đình',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.label_outline, color: mainColor),
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
                  return 'Vui lòng nhập tên tủ lạnh';
                }
                if (value.trim().length < 3) {
                  return 'Tên phải có ít nhất 3 ký tự';
                }
                return null;
              },
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
          onPressed: _isLoading ? null : _handleCreate,
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
                  'Tạo',
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
