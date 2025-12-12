import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_add_ingredients.dart';
import '../settings/settings.dart';
import '../../widgets/recipe/bottom_nav.dart';
class FridgeHomeScreen extends StatefulWidget {
  const FridgeHomeScreen({super.key});

  @override
  State<FridgeHomeScreen> createState() => _FridgeHomeScreenState();
}

class _FridgeHomeScreenState extends State<FridgeHomeScreen> {
  Color mainColor = const Color(0xFF214130);
  List items = List.generate(11, (_) => "Raw pork");
  List nearlyExpireItems = List.generate(2, (_) => "Raw pork");

  // Biến để theo dõi chế độ multi-select
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete these ${selectedIndices.length} ingredients?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "These ingredients will be permanently deleted from this fridge.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            color: mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteSelectedItems();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteSelectedItems() {
    setState(() {
      // Xóa items theo index từ lớn đến nhỏ để tránh lỗi index
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
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFFF0F1F1),
        elevation: 0,
        title: isSelectionMode
            ? Row(
                children: [
                  TextButton(
                    onPressed: toggleSelectionMode,
                    child: Text(
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
                    onPressed: selectedIndices.isEmpty
                        ? null
                        : showDeleteConfirmDialog,
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color:
                            selectedIndices.isEmpty ? Colors.grey : mainColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
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
                  Icon(Icons.notifications_outlined, color: mainColor),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.settings,
                        color: mainColor), // Icon cũ của bạn
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SettingsScreen(), // Thay SettingsScreen bằng tên class màn hình cài đặt của bạn
                        ),
                      );
                    },
                  )
                ],
              ),
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
                    child: _buildItemBox(
                      mainColor,
                      false,
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
                    return _buildItemBox(
                      mainColor,
                      true,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE7EAE9),
                ),
                child: Icon(Icons.add, size: 35, color: mainColor),
              ),
            ),
      bottomNavigationBar: isSelectionMode
    ? Container(
        height: 75,
        color: const Color(0xFF8B4513),
        child: Center(
          child: InkWell(
            onTap: selectedIndices.isEmpty ? null : showDeleteConfirmDialog,
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
        // Truyền màu chủ đạo của bạn vào đây (mainColor lấy từ biến trong file của bạn)
        textColor: mainColor, 
      ),
    );
  }

  Widget _buildItemBox(
    Color mainColor,
    bool isExpire, {
    required String itemName,
    String? quantity,
    int? daysLeft,
    String? expireDate,
    required bool isSelected,
    required bool isSelectionMode,
  }) {
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

// Widget Marquee Text tự động chạy chữ khi text quá dài
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pauseDuration;
  final Duration scrollDuration;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.pauseDuration = const Duration(seconds: 1),
    this.scrollDuration = const Duration(seconds: 3),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    if (!mounted) return;

    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      _isScrolling = true;

      while (_isScrolling && mounted) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) break;

        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.scrollDuration,
          curve: Curves.linear,
        );
        if (!mounted) break;

        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) break;

        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.style.fontSize! * 1.5,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Text(widget.text, style: widget.style, maxLines: 1),
      ),
    );
  }
}
