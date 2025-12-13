import 'package:flutter/material.dart';
import 'plan_recipe_detail.dart';
import 'package:google_fonts/google_fonts.dart';


class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<_ShoppingListItem> _items = [
    _ShoppingListItem(
      title: "Braised pork",
      subtitle: "3 ingredients left",
    ),
    _ShoppingListItem(
      title: "Banh mi",
      subtitle: "5 ingredients left",
    ),
    _ShoppingListItem(
      title: "Chicken soup",
      subtitle: "3 ingredients left",
    ),
    _ShoppingListItem(
      title: "Extra",
      subtitle: "2 ingredients left",
    ),
  ];

  bool _selectionMode = false;

  int get _selectedCount => _items.where((item) => item.isSelected).length;

  void _startSelection(int index) {
    setState(() {
      _selectionMode = true;
      _items[index].isSelected = true;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      final item = _items[index];
      item.isSelected = !item.isSelected;
      if (_items.every((innerItem) => !innerItem.isSelected)) {
        _selectionMode = false;
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _items.removeWhere((item) => item.isSelected);
      _selectionMode = false;
    });
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int count) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF3F2EF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Delete these $count list${count == 1 ? '' : 's'} ?",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff214d34),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "These lists will be permanently deleted from this planner.",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 15,
                  color: const Color(0xff214d34),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.merriweather(
                          color: const Color(0xffd69314),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    color: const Color(0xffbdbdbd),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.merriweather(
                          color: const Color(0xffdc3a34),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm ?? false) {
      _deleteSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool selectionMode = _selectionMode;
    final int selectedCount = _selectedCount;
    final double listBottomPadding = selectionMode ? 120 : 16;

    return Scaffold(
      backgroundColor: const Color(0xfff4f5f2),
      body: Stack(
        children: [
          // ---------- MAIN CONTENT ----------
          Padding(
            // leave space for status bar + back button + a bit before title
            padding: EdgeInsets.only(
              top: topPadding + 12,
            ),
            child: Column(
              children: [
                Text(
                  "Shopping list",
                  style: GoogleFonts.merriweather(
                    color: const Color(0xff214d34),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "9, September 2025",
                  style: GoogleFonts.merriweather(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                if (selectionMode) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "$selectedCount list${selectedCount == 1 ? '' : 's'} selected",
                        style: GoogleFonts.merriweather(
                          fontSize: 15,
                          color: const Color(0xff214d34),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, listBottomPadding),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return buildCard(
                        context,
                        _items[index],
                        index: index,
                        selectionMode: selectionMode,
                        navigateToDetail: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ---------- FIGMA-STYLE BACK BUTTON ----------
          Positioned(
            top: topPadding + 16, // just under the status bar, like screenshot
            left: 16,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EAE9),
                borderRadius: BorderRadius.circular(9),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.15),
                //     blurRadius: 6,
                //     offset: const Offset(0, 3),
                //   ),
                // ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff214d34)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          if (selectionMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: const Color(0xffb71c1c),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                  child: TextButton(
                    onPressed: selectedCount > 0
                        ? () => _showDeleteConfirmation(context, selectedCount)
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Delete",
                          style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCard(
    BuildContext context,
    _ShoppingListItem item, {
    required int index,
    required bool selectionMode,
    bool navigateToDetail = false,
  }) {
    final bool isSelected = item.isSelected;
    final titleStyle = GoogleFonts.merriweather(
      fontSize: 20,
      color: const Color(0xff214d34),
      fontWeight: FontWeight.bold,
      decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
    );
    final subtitleStyle = GoogleFonts.merriweather(
      color: Colors.black54,
      fontSize: 14,
      decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
    );
    const selectionColor = Color(0xff214d34);

    return GestureDetector(
      onLongPress: () {
        if (_selectionMode) {
          _toggleSelection(index);
          return;
        }
        _startSelection(index);
      },
      onTap: () {
        if (_selectionMode) {
          _toggleSelection(index);
          return;
        }
        if (navigateToDetail) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecipeDetailScreen(),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          // color: isSelected ? const Color(0xFFDCE7DC) : const Color(0xFFE7EAE9),
          color: const Color(0xFFE7EAE9),
          borderRadius: BorderRadius.circular(15),
          // border: isSelected ? Border.all(color: selectionColor, width: 1.5) : null,
        ),
        child: Row(
          children: [
            selectionMode
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? selectionColor : Colors.transparent,
                      border: Border.all(
                        color: selectionColor,
                        width: 2,
                      ),
                    ),
                  )
                : Checkbox(
                    value: item.isChecked,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: selectionColor,
                    side: const BorderSide(color: selectionColor),
                    onChanged: (checked) {
                      setState(() {
                        _items[index].isChecked = checked ?? false;
                      });
                    },
                  ),
            SizedBox(width: selectionMode ? 16 : 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: titleStyle,
                  ),
                  Text(
                    item.subtitle,
                    style: subtitleStyle,
                  ),
                ],
              ),
            ),

            
          ],
        ),
      ),
    );
  }
}

class _ShoppingListItem {
  final String title;
  final String subtitle;
  bool isChecked;
  bool isSelected;

  _ShoppingListItem({
    required this.title,
    required this.subtitle,
    this.isChecked = false,
    this.isSelected = false,
  });
}
