import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'shopping_list_screen.dart';

class ShoppingPlanScreen extends StatefulWidget {
  const ShoppingPlanScreen({super.key});

  @override
  State<ShoppingPlanScreen> createState() => _ShoppingPlanScreenState();
}

class _ShoppingPlanScreenState extends State<ShoppingPlanScreen> {
  late DateTime today;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F1),

      // ----------------- APP BAR ------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F1),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: const Text(
          "Shopping plan",
          style: TextStyle(
            color: Color(0xff214130),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Merriweather'
          ),
        ),
      ),

      // ------------------ BODY ---------------------
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ------------------ CALENDAR ---------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F1),
              ),
              child: TableCalendar(
                focusedDay: today,
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2050, 12, 31),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color(0xff214d34),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xff214d34),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  defaultTextStyle: const TextStyle(
                    color: Colors.black87,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
                selectedDayPredicate: (day) => isSameDay(day, today),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    today = selectedDay;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShoppingListScreen(),
                    ),
                  );
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------------
            // TODAY LIST + UPCOMING LIST
            // ----------------------------------------------------------
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EAE9),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODAY LIST
                  const Text(
                    "Today list",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff214d34),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Merriweather'
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildBullet("Braised pork"),
                  buildBullet("Banh mi"),
                  buildBullet("Chicken soup"),

                  const SizedBox(height: 20),

                  // UPCOMING LIST
                  const Text(
                    "Upcoming list",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff214d34),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Merriweather'
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    "19, September 2025",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Merriweather'
                    ),
                  ),
                  const SizedBox(height: 8),

                  buildBullet("Chicken jockey"),
                  buildBullet("Hamburger"),
                  buildBullet("Bun Cha"),

                  const SizedBox(height: 14),
                  const Text(
                    "--More--",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Merriweather'
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      // ----------------------------------------------------------
      // NEW FLOATING CARD NAVIGATION BAR (UPDATED PART)
      // ----------------------------------------------------------
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.kitchen, "Pantry", false),
            _navItem(Icons.menu_book, "Recipes", false),
            _navItem(Icons.shopping_bag, "Shopping", true),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Widget FOR BULLET POINTS
  // ----------------------------------------------------------
  Widget buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        children: [
          const Text("• ",
              style: TextStyle(fontSize: 18, color: Colors.black87)),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // Floating NAVIGATION BAR ICON BUILDER
  // ----------------------------------------------------------
  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: active ? const Color(0xff214d34) : Colors.black45,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? const Color(0xff214d34) : Colors.black45,
          ),
        )
      ],
    );
  }
}
