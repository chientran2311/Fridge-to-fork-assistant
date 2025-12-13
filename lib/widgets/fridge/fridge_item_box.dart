import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/marquee_text.dart';

class FridgeItemBox extends StatelessWidget {
  final Color mainColor;
  final bool isExpire;
  final String itemName;
  final String? quantity;
  final int? daysLeft;
  final String? expireDate;
  final bool isSelected;
  final bool isSelectionMode;

  const FridgeItemBox({
    super.key,
    required this.mainColor,
    required this.isExpire,
    required this.itemName,
    this.quantity,
    this.daysLeft,
    this.expireDate,
    required this.isSelected,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpire ? 180 : null,
      margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? mainColor : const Color(0xFFE7EAE9),
        borderRadius: BorderRadius.circular(16),
        border: isSelectionMode && !isSelected
            ? Border.all(color: Colors.grey.withOpacity(0.5), width: 2)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/pork.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                MarqueeText(
                  text: itemName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : mainColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                if (!isExpire && quantity != null) ...[
                  Text(
                    "Quantity: $quantity",
                    style: TextStyle(
                      fontSize: 7,
                      color: isSelected ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ],
                if (isExpire) ...[
                  if (daysLeft != null)
                    Text(
                      "$daysLeft days left",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  if (expireDate != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      "EXP: $expireDate",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
