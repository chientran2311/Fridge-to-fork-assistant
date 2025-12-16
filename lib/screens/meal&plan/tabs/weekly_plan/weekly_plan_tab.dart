import 'package:flutter/material.dart';

import '../../../../widgets/plans/tabs/weekly_plan_tab/meal_card.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/quick_shopping_list.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/day_item.dart';
import '../../../../widgets/plans/tabs/weekly_plan_tab/plan_dinner_card.dart';

class WeeklyPlanContent extends StatefulWidget {
  const WeeklyPlanContent({super.key});

  @override
  State<WeeklyPlanContent> createState() => _WeeklyPlanContentState();
}

class _WeeklyPlanContentState extends State<WeeklyPlanContent> {
  late List<DateTime> weekDays;
  late int selectedDayIndex;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    // Monday of current week
    final monday =
        today.subtract(Duration(days: today.weekday - DateTime.monday));

    // Generate 7 days (Mon → Sun)
    weekDays = List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );

    // Select today automatically
    selectedDayIndex = weekDays.indexWhere(
      (d) =>
          d.year == today.year &&
          d.month == today.month &&
          d.day == today.day,
    );

    if (selectedDayIndex == -1) {
      selectedDayIndex = 0;
    }
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('weekly'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- DAY SELECTOR ----------
      
SizedBox(
  height: 70,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: weekDays.length,
    itemBuilder: (context, index) {
      final date = weekDays[index];

      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () {
            setState(() => selectedDayIndex = index);
          },
          child: DayItem(
            day: _weekdayLabel(date),
            date: date.day.toString(),
            active: selectedDayIndex == index,
          ),
        ),
      );
    },
  ),
),

const SizedBox(height: 20),

        // ---------- TITLE ----------
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Meals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("1,450 kcal", style: TextStyle(color: Colors.grey)),
          ],
        ),

        const SizedBox(height: 16),

        // ---------- MEAL CARDS ----------
        const MealCard(
          label: "BREAKFAST",
          title: "Creamy Avocado & Spinach",
          kcal: 320,
        ),

        const SizedBox(height: 16),

        const MealCard(
          label: "LUNCH",
          title: "Superfood Quinoa Salad",
          kcal: 420,
        ),

        const SizedBox(height: 16),

        const PlanDinnerCard(),

        const SizedBox(height: 24),

        const ShoppingList(),
      ],
    );
  }
}

