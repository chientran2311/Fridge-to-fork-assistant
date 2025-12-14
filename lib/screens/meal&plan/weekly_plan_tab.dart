import 'package:flutter/material.dart';
import 'planner_detail_screen.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class WeeklyPlanContent extends StatefulWidget {
  const WeeklyPlanContent({super.key});

  @override
  State<WeeklyPlanContent> createState() => _WeeklyPlanContentState();
}

class _WeeklyPlanContentState extends State<WeeklyPlanContent> {
  int selectedDayIndex = 1; // default = Tue

  final List<Map<String, String>> days = [
    {"day": "Mon", "date": "23"},
    {"day": "Tue", "date": "24"},
    {"day": "Wed", "date": "25"},
    {"day": "Thu", "date": "26"},
    {"day": "Fri", "date": "27"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('weekly'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- DAY SELECTOR ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() => selectedDayIndex = index);
              },
              child: _DayItem(
                day: days[index]["day"]!,
                date: days[index]["date"]!,
                active: selectedDayIndex == index,
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

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
        const _MealCard(
          label: "BREAKFAST",
          title: "Creamy Avocado & Spinach",
          kcal: 320,
        ),
        const SizedBox(height: 16),
        const _MealCard(
          label: "LUNCH",
          title: "Superfood Quinoa Salad",
          kcal: 420,
        ),

        const SizedBox(height: 16),
        const _PlanDinnerCard(),

        const SizedBox(height: 24),
        const _ShoppingList(),
      ],
    );
  }
}

//
// ---------------- DAY ITEM ----------------
//

class _DayItem extends StatelessWidget {
  final String day;
  final String date;
  final bool active;

  const _DayItem({
    required this.day,
    required this.date,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF214130) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

//
// ---------------- PLAN DINNER CARD ----------------
//

class _PlanDinnerCard extends StatelessWidget {
  const _PlanDinnerCard();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return AspectRatio(
      aspectRatio: isDesktop ? 2.6 : 1.8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(height: 8),
            Text(
              "Plan Dinner",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Use ingredients expiring soon\nor get AI suggestions.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: null,
              child: Text("+ Add Meal"),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------------- SHOPPING LIST ----------------
//

class _ShoppingList extends StatelessWidget {
  const _ShoppingList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quick Shopping List",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("View All", style: TextStyle(color: Colors.grey)),
          ],
        ),
        SizedBox(height: 12),
        ListTile(
          leading: Checkbox(value: true, onChanged: null),
          title: Text("Spinach"),
          subtitle: Text("Produce • 2x"),
        ),
        ListTile(
          leading: Checkbox(value: false, onChanged: null),
          title: Text("Pasta"),
          subtitle: Text("Dairy • 1x"),
        ),
      ],
    );
  }
}

//
// ---------------- MEAL CARD ----------------
//

class _MealCard extends StatelessWidget {
  final String label;
  final String title;
  final int kcal;

  const _MealCard({
    required this.label,
    required this.title,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PlannerDetailScreen(),
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _Tag(text: label),
                ),
                const Positioned(
                  bottom: 12,
                  right: 12,
                  child: _Tag(text: "Low Waste", filled: true),
                ),
              ],
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$kcal kcal",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------------- TAG ----------------
//

class _Tag extends StatelessWidget {
  final String text;
  final bool filled;

  const _Tag({
    required this.text,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF214130) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: filled ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
