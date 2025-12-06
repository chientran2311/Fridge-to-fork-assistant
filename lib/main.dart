import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ShoppingPlanScreen(),
    );
  }
}

class ShoppingPlanScreen extends StatefulWidget {
  const ShoppingPlanScreen({super.key});

  @override
  State<ShoppingPlanScreen> createState() => _ShoppingPlanScreenState();
}

class _ShoppingPlanScreenState extends State<ShoppingPlanScreen> {
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EAE9),

      // ----------------- APP BAR ------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7EAE9),
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
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ------------------ CALENDAR ---------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xfff4f5f2),
              ),
              child: TableCalendar(
                focusedDay: today,
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 9, 30),
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

      // ------------------ BOTTOM NAV ---------------------
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xfff4f5f2),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.kitchen, size: 28, color: Color(0xff214d34)),
            Icon(Icons.menu_book, size: 28, color: Colors.black45),
            Icon(Icons.shopping_bag, size: 28, color: Colors.black45),
          ],
        ),
      ),
    );
  }

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
}
