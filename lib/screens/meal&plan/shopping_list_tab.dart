import 'package:flutter/material.dart';

class ShoppingListTab extends StatefulWidget {
  const ShoppingListTab({super.key});

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  @override
  Widget build(BuildContext context) {
    // Check for desktop width to adjust padding dynamically
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. The Filter Chips (All Items, Produce, etc.)
          _CategoryFilters(),
          
          const SizedBox(height: 24),

          // 2. Produce Section
          _SectionHeader(
            title: "PRODUCE (3)",
            children: const [
              _EditableShoppingItem(
                title: "Almond Milk",
                subtitle: "1L • Unsweetened",
              ),
              _EditableShoppingItem(
                title: "Avocados",
                subtitle: "4 ripe ones",
              ),
              _EditableShoppingItem(
                title: "Cherry Tomatoes",
                subtitle: "1 pack",
              ),
              _EditableShoppingItem(
                title: "Spinach Bunches",
                subtitle: "2 bunches • Organic",
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // 3. Pantry Section
          _SectionHeader(
            title: "PANTRY (2)",
            children: const [
              _EditableShoppingItem(
                title: "Quinoa",
                subtitle: "500g pack",
              ),
              _EditableShoppingItem(
                title: "Olive Oil",
                subtitle: "Extra Virgin",
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // 4. Checked / Completed Items
          _CheckedSection(),

          // Extra space at bottom so FAB doesn't cover content
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Helper Widget: Section Header
// (You can keep this here since it's only used in this tab, 
// or move it to your 'widgets' folder if you plan to reuse it)
// --------------------------------------------------------------------------


class _CategoryFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: const [
        _FilterChip(text: "All Items", active: true),
        _FilterChip(text: "Produce"),
        _FilterChip(text: "Dairy"),
        _FilterChip(text: "Pantry"),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool active;

  const _FilterChip({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF214130) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}



class _CheckedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("CHECKED (2)",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            Text("Clear", style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Checkbox(value: true, onChanged: null),
            title: const Text("Greek Yogurt",
                style:
                    TextStyle(decoration: TextDecoration.lineThrough)),
            subtitle: const Text("2 tubs"),
            trailing: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _EditableShoppingItem extends StatefulWidget {
  final String title;
  final String subtitle;

  const _EditableShoppingItem({
    required this.title,
    required this.subtitle,
  });

  @override
  State<_EditableShoppingItem> createState() => _EditableShoppingItemState();
}

class _EditableShoppingItemState extends State<_EditableShoppingItem> {
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
              onPressed: () {},
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
                    _CircleButton(
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
                    _CircleButton(
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}



class _SectionHeader extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionHeader({
    required this.title, 
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The grey section title
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        // The list of shopping items
        ...children,
      ],
    );
  }
}