import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'plan_shopping_list.dart';
import 'package:google_fonts/google_fonts.dart';


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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF0F1F1),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          "Shopping plan",
          style: GoogleFonts.merriweather(
              color: const Color(0xff214130),
              fontSize: 24,
              fontWeight: FontWeight.bold),
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
                  defaultTextStyle: GoogleFonts.merriweather(
                    color: Colors.black87,
                  ),
                  weekendTextStyle: GoogleFonts.merriweather(
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.merriweather(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
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
                  Text(
                    "Today list",
                    style: GoogleFonts.merriweather(
                      fontSize: 20,
                      color: const Color(0xff214d34),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildBullet("Braised pork"),
                  buildBullet("Banh mi"),
                  buildBullet("Chicken soup"),

                  const SizedBox(height: 20),

                  // UPCOMING LIST
                  Text(
                    "Upcoming list",
                    style: GoogleFonts.merriweather(
                      fontSize: 20,
                      color: const Color(0xff214d34),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "19, September 2025",
                    style: GoogleFonts.merriweather(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),

                  buildBullet("Chicken jockey"),
                  buildBullet("Hamburger"),
                  buildBullet("Bun Cha"),

                  const SizedBox(height: 14),
                  Text(
                    "--More--",
                    style: GoogleFonts.merriweather(
                      fontSize: 14,
                      color: Colors.black54,
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
          Text(
            "- ",
            style: GoogleFonts.merriweather(fontSize: 18, color: Colors.black87),
          ),
          Text(
            text,
            style: GoogleFonts.merriweather(fontSize: 16),
          )
        ],
      ),
    );
  }
}
