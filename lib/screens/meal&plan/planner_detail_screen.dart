import 'package:flutter/material.dart';
import '../../widgets/notification.dart';

class PlannerDetailScreen extends StatefulWidget {
  const PlannerDetailScreen({super.key});

  @override
  State<PlannerDetailScreen> createState() => _PlannerDetailScreenState();
}

class _PlannerDetailScreenState extends State<PlannerDetailScreen> {
  int servings = 2;
  DateTime? selectedDate; // 👈 ngày được chọn

  final List<Map<String, dynamic>> ingredients = [
    {"name": "2 ripe Avocados", "inFridge": true, "checked": true},
    {"name": "200g Spinach", "inFridge": false, "checked": false},
    {"name": "500g Pasta", "inFridge": false, "checked": false},
    {"name": "1 Lemon", "inFridge": true, "checked": true},
    {"name": "3 Garlic Cloves", "inFridge": false, "checked": false},
  ];

  final List<String> instructions = [
    "Boil the pasta in salted water according to the package instructions until al dente. Reserve 1/2 cup of pasta water before draining.",
    "While pasta cooks, combine avocado, spinach, lemon juice, garlic, and olive oil in a blender. Blend until smooth and creamy.",
    "Drain the pasta and return it to the pot. Pour the green sauce over the pasta. Add the reserved pasta water a little at a time to loosen the sauce if needed.",
    "Toss gently until well coated. Season with salt and pepper to taste. Serve immediately topped with optional parmesan or pine nuts.",
  ];
  

  // ================= ADD TO CALENDAR LOGIC =================
  Future<void> _addToCalendar() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });

    // DEMO: hiển thị kết quả
    CustomToast.show(
      context,
      "Meal added to ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
    );

    // 👉 Ở đây trong app thật:
    // - Add meal vào planner list
    // - Gọi provider / bloc / database
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= BOTTOM BUTTON =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF214130),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              "Save your order",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: _addToCalendar, // 👈 GỌI DEMO
          ),
        ),
      ),

      body: Stack(
        children: [
          // ================= IMAGE HEADER =================
          SizedBox(
            height: 320,
            width: double.infinity,
            child: Image.network(
              "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
              fit: BoxFit.cover,
            ),
          ),

          // ================= TOP BUTTONS =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  _CircleButton(
                    icon: Icons.more_vert,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ================= CONTENT SHEET =================
          DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.72,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= TITLE =================
                      const Text(
                        "Creamy Avocado & Spinach\nPesto Pasta",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "By GreenChef • Italian Inspired",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      // ================= TAGS =================
                      Row(
                        children: const [
                          _InfoChip(
                            icon: Icons.schedule,
                            text: "15 Mins",
                            bgColor: Color(0xFFE9F5EC),
                            textColor: Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.flash_on,
                            text: "Easy",
                            bgColor: Color(0xFFFFF1E6),
                            textColor: Color(0xFFF57C00),
                          ),
                          SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.local_fire_department,
                            text: "320 Kcal",
                            bgColor: Color(0xFFE8F0FE),
                            textColor: Color(0xFF1A73E8),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ================= INGREDIENTS =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ingredients",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (servings > 1) {
                                    setState(() => servings--);
                                  }
                                },
                              ),
                              Text("$servings Servings"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() => servings++);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ...ingredients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: item["checked"],
                                activeColor: const Color(0xFF214130),
                                onChanged: (val) {
                                  setState(() {
                                    ingredients[index]["checked"] = val;
                                  });
                                },
                              ),
                              Expanded(child: Text(item["name"])),
                              if (item["inFridge"])
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9F5EC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "In Fridge",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ================= INSTRUCTIONS =================
                      const Text(
                        "Instructions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...instructions.asMap().entries.map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16),
                              child: _InstructionStep(
                                number: e.key + 1,
                                text: e.value,
                              ),
                            ),
                          ),

                      const SizedBox(height: 100), // space for button
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}



//

// ======================= SMALL WIDGETS =======================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF214130),
            shape: BoxShape.circle,
          ),
          child: Text(
            "$number",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(height: 1.5),
          ),
        ),
      ],
    );
  }
}
