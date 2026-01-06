import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AddRecipeScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> recipes;
  final Function(DateTime date, String recipeId, String mealType, int servings)
      onAddMealPlan;

  const AddRecipeScreen({
    super.key,
    required this.selectedDate,
    required this.recipes,
    required this.onAddMealPlan,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  late DateTime pickedDate;
  String selectedMealType = 'breakfast';
  int servings = 1;
  String recipeFilter = 'all';

  @override
  void initState() {
    super.initState();
    pickedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRecipes = widget.recipes;
    if (recipeFilter == 'favorite') {
      filteredRecipes =
          widget.recipes.where((r) => r['isFavorite'] == true).toList();
    } else if (recipeFilter == 'api') {
      filteredRecipes = widget.recipes
          .where((r) => r['isFromApi'] == true && r['isFavorite'] != true)
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm công thức vào kế hoạch',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DragTarget<Map<String, dynamic>>(
                    onWillAccept: (data) => true,
                    onAccept: (dragData) async {
                      final recipe = dragData['recipe'] as Map<String, dynamic>;
                      await widget.onAddMealPlan(
                        pickedDate,
                        recipe['id'],
                        selectedMealType,
                        servings,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          border: isHovering
                              ? Border.all(
                                  color: const Color(0xFF214130), width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: isHovering
                              ? const Color(0xFF214130).withOpacity(0.05)
                              : null,
                        ),
                        child: TableCalendar(
                          focusedDay: pickedDate,
                          firstDay: DateTime(2025, 1, 1),
                          lastDay: DateTime(2027, 12, 31),
                          selectedDayPredicate: (day) => isSameDay(pickedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              pickedDate = selectedDay;
                            });
                          },
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: const Color(0xFF214130),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: const Color(0xFF214130).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(color: Colors.white),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _mealTypeButton('Bữa sáng', 'breakfast'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _mealTypeButton('Bữa trưa', 'lunch'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _mealTypeButton('Bữa tối', 'dinner'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Khẩu phần:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (servings > 1) setState(() => servings--);
                        },
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text('$servings',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => servings++),
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const Divider(height: 1),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _recipeFilterButton('Tất cả', 'all'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _recipeFilterButton('Yêu thích', 'favorite'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _recipeFilterButton('Từ API', 'api'),
            ),
          ],
        ),
      ),
      const Divider(height: 1),
      Expanded(
        child: filteredRecipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      recipeFilter == 'favorite'
                          ? 'Không có công thức yêu thích'
                          : recipeFilter == 'api'
                              ? 'Không có công thức từ API'
                              : 'Không có công thức nào',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = filteredRecipes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildRecipeCard(recipe),
                  );
                },
              ),
      ),
    ],
      ),
    );
  }

  Widget _mealTypeButton(String label, String type) {
    final isSelected = type == selectedMealType;
    return GestureDetector(
      onTap: () => setState(() => selectedMealType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF214130) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _recipeFilterButton(String label, String type) {
    final isSelected = type == recipeFilter;
    return GestureDetector(
      onTap: () => setState(() => recipeFilter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF214130) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF214130), width: 2)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: {
        'recipe': recipe,
        'date': pickedDate,
        'mealType': selectedMealType,
      },
      delay: const Duration(milliseconds: 500),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: (recipe['image'] as String).isNotEmpty
                      ? Image.network(
                          recipe['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.restaurant,
                              color: Colors.grey[400],
                              size: 28),
                        )
                      : Icon(Icons.restaurant,
                          color: Colors.grey[400], size: 28),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 12, color: Colors.orange[700]),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe['calories']} kcal',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[100],
                    child: (recipe['image'] as String).isNotEmpty
                        ? Image.network(
                            recipe['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(Icons.restaurant,
                                  color: Colors.grey[300], size: 28),
                            ),
                          )
                        : Center(
                            child: Icon(Icons.restaurant,
                                color: Colors.grey[300], size: 28),
                          ),
                  ),
                ),
                if (recipe['isFavorite'] == true)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 12, color: Colors.orange[700]),
                    const SizedBox(width: 3),
                    Text(
                      '${recipe['calories']} kcal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (recipe['isFavorite'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF214130).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Yêu thích',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF214130),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.drag_indicator, color: Colors.grey[350], size: 18),
        ],
      ),      ),    );
  }
}
      body: const Center(
        child: Text('Add Recipe to Calendar'),
      ),
    );
  }
}
