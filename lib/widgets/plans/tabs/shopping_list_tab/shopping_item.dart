import 'package:flutter/material.dart';
import 'circle_button.dart';
import '../../modals/planner_confirm_delete_modal.dart';

class EditableShoppingItem extends StatefulWidget {
  final String title;
  final String subtitle;

  const EditableShoppingItem({
    required this.title,
    required this.subtitle,
  });

  @override
  State<EditableShoppingItem> createState() => EditableShoppingItemState();
}

class EditableShoppingItemState extends State<EditableShoppingItem> {
  bool isEditing = false;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() => isEditing = true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isEditing
              ? Border.all(
                  color: const Color(0xFF214130),
                  width: 2.5,
                )
              : null,
        ),
        child: isEditing ? _editMode() : _viewMode(),
      ),
    );
  }

  Widget _viewMode() {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(widget.subtitle,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit,
                size: 18, color: Color(0xFF214130)),
            const SizedBox(width: 6),
            const Text("Item Name",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DeleteItemModal(
                    
                  ),
                );
              },
            ),
          ],
        ),
        Text(widget.title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quantity",
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("$quantity L",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ),
                    CircleButton(
                      icon: Icons.add,
                      onTap: () => setState(() => quantity++),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Note",
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 6),
                Chip(label: Text("Unsweetened")),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => isEditing = false),
            child: const Text("Done"),
          ),
        ),
      ],
    );
  }
}