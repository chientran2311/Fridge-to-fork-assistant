import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_image_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

/// Widget Avatar Profile có thể tap để đổi ảnh (View trong MVVM)
/// Sử dụng Consumer Pattern để listen state từ Provider
/// 
/// [isRegisterMode]: Nếu true, sẽ reset về mặc định (không load ảnh cũ)
class ProfileAvatar extends StatefulWidget {
  final double size;
  final bool showEditIcon;
  final VoidCallback? onTap;
  final bool isRegisterMode;

  const ProfileAvatar({
    super.key,
    this.size = 48,
    this.showEditIcon = true,
    this.onTap,
    this.isRegisterMode = false,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  void initState() {
    super.initState();
    // Nếu là register mode, reset về mặc định
    if (widget.isRegisterMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileImageProvider>().resetToDefault();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileImageProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: widget.onTap ?? () => _showImagePickerSheet(context),
          child: Stack(
            children: [
              // Avatar container
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F5E9),
                  border: Border.all(
                    color: const Color(0xFF1B3B36),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: provider.isLoading
                      ? _buildLoadingIndicator()
                      : provider.hasImage
                          ? _buildImage(provider.imagePath!)
                          : _buildPlaceholder(),
                ),
              ),

              // Edit icon badge
              if (widget.showEditIcon)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: widget.size * 0.32,
                    height: widget.size * 0.32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3B36),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: widget.size * 0.16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: widget.size * 0.4,
        height: widget.size * 0.4,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF1B3B36),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: widget.size,
      height: widget.size,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      size: widget.size * 0.5,
      color: const Color(0xFF1B3B36),
    );
  }

  /// Hiện Bottom Sheet chọn nguồn ảnh
  void _showImagePickerSheet(BuildContext context) {
    final s = AppLocalizations.of(context);
    final provider = context.read<ProfileImageProvider>();
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.6,
          ),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                s?.changeProfilePhoto ?? 'Đổi ảnh đại diện',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable options
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Option: Edit Display Name (chỉ hiện khi đã đăng nhập)
                      if (authProvider.isAuthenticated) ...[
                        _buildOptionTile(
                          icon: Icons.edit_outlined,
                          title: s?.editDisplayName ?? 'Chỉnh sửa tên',
                          onTap: () {
                            Navigator.pop(ctx);
                            _showEditNameDialog(context, authProvider, s);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Option: Gallery
                      _buildOptionTile(
                        icon: Icons.photo_library_outlined,
                        title: s?.chooseFromGallery ?? 'Chọn từ thư viện',
                        onTap: () async {
                          Navigator.pop(ctx);
                          // TODO: Implement pick from gallery
                        },
                      ),

                      const SizedBox(height: 12),

                      // Option: Camera
                      _buildOptionTile(
                        icon: Icons.camera_alt_outlined,
                        title: s?.takePhoto ?? 'Chụp ảnh mới',
                        onTap: () async {
                          Navigator.pop(ctx);
                          // TODO: Implement take photo
                        },
                      ),

                      // Option: Remove (chỉ hiện khi đã có ảnh)
                      if (provider.hasImage) ...[
                        const SizedBox(height: 12),
                        _buildOptionTile(
                          icon: Icons.delete_outline,
                          title: s?.removePhoto ?? 'Xóa ảnh',
                          color: Colors.red,
                          onTap: () async {
                            Navigator.pop(ctx);
                            // TODO: Implement remove image
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    s?.cancel ?? 'Hủy',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiện Dialog chỉnh sửa tên
  void _showEditNameDialog(
      BuildContext context, AuthProvider authProvider, AppLocalizations? s) {
    final TextEditingController nameController = TextEditingController(
      text: authProvider.displayName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s?.editDisplayName ?? 'Chỉnh sửa tên'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: s?.enterNewName ?? 'Nhập tên mới',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1B3B36), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s?.cancel ?? 'Hủy',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s?.nameEmpty ?? 'Tên không được để trống'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);

              final error = await authProvider.updateDisplayName(newName);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error ?? (s?.nameUpdated ?? 'Cập nhật tên thành công!'),
                    ),
                    backgroundColor: error == null ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3B36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              s?.confirm ?? 'Xác nhận',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color(0xFF1B3B36)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
