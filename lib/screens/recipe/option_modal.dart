import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/widgets/common/primary_button.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/option/option_header.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/option/option_button.dart';
import 'package:fridge_to_fork_assistant/widgets/notification.dart';
import 'share_recipe_modal.dart'; 

class OptionModal extends StatelessWidget {
  const OptionModal({super.key});

  static void show(BuildContext context) {
    if (context.isDesktop || context.isTablet) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => const Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 400, 
            child: OptionModal(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const OptionModal(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDialogMode = !context.isMobile;
    final BorderRadius borderRadius = isDialogMode
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
        children: [
          if (!isDialogMode)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const OptionHeader(),
          OptionButton(
            icon: Icons.ios_share,
            title: "Share Recipe",
            subtitle: "Send to friends or family",
            onTap: () {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 150), () {
                if (context.mounted) {
                   ShareModal.show(context, url: "https://fridge2fork.app/recipe/creamy-pesto");
                }
              });
            },
          ),
          const SizedBox(height: 16),
          OptionButton(
            icon: Icons.favorite_border,
            title: "Save to favorite recipe",
            subtitle: "Access quickly from plan",
            onTap: () {
              Navigator.pop(context);
              CustomToast.show(context, "Recipe saved to favorites!");
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: PrimaryButton(
              text: "Cancel",
              onPressed: () => Navigator.pop(context),
              backgroundColor: const Color(0xFFF8F9FA),
              textColor: const Color(0xFF1B3B36),
            ),
          ),
          SizedBox(height: context.isMobile ? 20 : 10),
        ],
      ),
    );
  }
}