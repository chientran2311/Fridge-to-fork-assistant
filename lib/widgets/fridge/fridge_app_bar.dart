import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/settings/settings.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_notifications.dart';

class FridgeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color mainColor;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onCancelSelection;
  final VoidCallback onDeletePressed;

  const FridgeAppBar({
    super.key,
    required this.mainColor,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onCancelSelection,
    required this.onDeletePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      toolbarHeight: 100,
      backgroundColor: const Color(0xFFF0F1F1),
      elevation: 0,
      title: isSelectionMode
          ? Row(
              children: [
                TextButton(
                  onPressed: onCancelSelection,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "My Fridge",
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: selectedCount == 0 ? null : onDeletePressed,
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: selectedCount == 0 ? Colors.grey : mainColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.asset(
                    'assets/images/pork.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello",
                        style: TextStyle(color: mainColor, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "dreammy",
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Icon(Icons.notifications_outlined, color: mainColor),
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: mainColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FridgeNotificationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.settings, color: mainColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                )
              ],
            ),
    );
  }
}
