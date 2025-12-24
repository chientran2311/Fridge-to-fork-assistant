import 'package:flutter/material.dart';
// import 'package:fridge_to_fork_assistant/widgets/plans/modals/planner_confirm_delete_modal.dart';
// import '../../../../widgets/plans/tabs/shopping_list_tab/circle_button.dart';
import '../../../../widgets/plans/tabs/shopping_list_tab/section_header.dart';
import '../../../../widgets/plans/tabs/shopping_list_tab/shopping_filter.dart';
import '../../../../widgets/plans/tabs/shopping_list_tab/shopping_item.dart';


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
          CategoryFilters(),
          
          const SizedBox(height: 24),

          // 2. Produce Section
          SectionHeader(
            title: "PRODUCE (3)",
            children: const [
              EditableShoppingItem(
                title: "Almond Milk",
                subtitle: "1L • Unsweetened",
              ),
              EditableShoppingItem(
                title: "Avocados",
                subtitle: "4 ripe ones",
              ),
              EditableShoppingItem(
                title: "Cherry Tomatoes",
                subtitle: "1 pack",
              ),
              EditableShoppingItem(
                title: "Spinach Bunches",
                subtitle: "2 bunches • Organic",
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // 3. Pantry Section
          SectionHeader(
            title: "PANTRY (2)",
            children: const [
              EditableShoppingItem(
                title: "Quinoa",
                subtitle: "500g pack",
              ),
              EditableShoppingItem(
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

