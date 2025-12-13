import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_add_ingredients.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/bottom_nav.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/fridge_app_bar.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/fridge_item_box.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/delete_confirm_dialog.dart';

class FridgeHomeScreen extends StatefulWidget {
  const FridgeHomeScreen({super.key});

  @override
  State<FridgeHomeScreen> createState() => _FridgeHomeScreenState();
}

class _FridgeHomeScreenState extends State<FridgeHomeScreen> {
  final Color mainColor = const Color(0xFF214130);
  List items = List.generate(11, (_) => "Raw pork");
  List nearlyExpireItems = List.generate(2, (_) => "Raw pork");

  bool isSelectionMode = false;
  Set<int> selectedIndices = {};

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedIndices.clear();
      }
    });
  }

  void toggleItemSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

  void showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmDialog(
          mainColor: mainColor,
          itemCount: selectedIndices.length,
          onConfirm: deleteSelectedItems,
        );
      },
    );
  }

  void deleteSelectedItems() {
    setState(() {
      var sortedIndices = selectedIndices.toList()
        ..sort((a, b) => b.compareTo(a));
      for (var index in sortedIndices) {
        items.removeAt(index);
      }
      selectedIndices.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F1),
      appBar: FridgeAppBar(
        mainColor: mainColor,
        isSelectionMode: isSelectionMode,
        selectedCount: selectedIndices.length,
        onCancelSelection: toggleSelectionMode,
        onDeletePressed: showDeleteConfirmDialog,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSelectionMode)
              Text(
                "My Fridge(${items.length})",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () {
                      if (!isSelectionMode) {
                        toggleSelectionMode();
                        toggleItemSelection(index);
                      }
                    },
                    onTap: () {
                      if (isSelectionMode) {
                        toggleItemSelection(index);
                      }
                    },
                    child: FridgeItemBox(
                      mainColor: mainColor,
                      isExpire: false,
                      itemName: "Raw pork",
                      quantity: "200g",
                      isSelected: selectedIndices.contains(index),
                      isSelectionMode: isSelectionMode,
                    ),
                  );
                },
              ),
            ),
            if (!isSelectionMode) ...[
              const SizedBox(height: 10),
              Text(
                "Nearly run out or expire(${nearlyExpireItems.length})",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: nearlyExpireItems.length,
                  itemBuilder: (context, index) {
                    return FridgeItemBox(
                      mainColor: mainColor,
                      isExpire: true,
                      itemName: "Raw pork",
                      daysLeft: 9,
                      expireDate: "9/11/2001",
                      isSelected: false,
                      isSelectionMode: false,
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: isSelectionMode
          ? null
          : GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FridgeAddIngredients(),
                  ),
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE7EAE9),
                ),
                child: Icon(Icons.add, size: 35, color: mainColor),
              ),
            ),
      //toggle delete
      bottomNavigationBar: isSelectionMode
          ? Container(
              height: 75,
              color: const Color(0xFFB72323),
              child: Center(
                child: InkWell(
                  onTap:
                      selectedIndices.isEmpty ? null : showDeleteConfirmDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Delete(${selectedIndices.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : BottomNav(
              textColor: mainColor,
            ),
    );
  }
}
