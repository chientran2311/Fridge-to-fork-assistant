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

  @override
  void initState() {
    super.initState();
    pickedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
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
}
      body: const Center(
        child: Text('Add Recipe to Calendar'),
      ),
    );
  }
}
