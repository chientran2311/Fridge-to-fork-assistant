import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'option_modal.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Màu sắc chủ đạo
  final Color mainColor = const Color(0xFF1B3B36);
  final Color bgCream = const Color(0xFFF9F9F7);
  final Color greenTagBg = const Color(0xFFE8F5E9);
  final Color orangeTagBg = const Color(0xFFFFF3E0);
  final Color blueTagBg = const Color(0xFFE3F2FD);

  // State
  int servings = 2;
  // Giả lập trạng thái checkbox của nguyên liệu
  List<bool> ingredientChecks = [true, false, false, true, false];

  // Dữ liệu mẫu (Hardcode theo ảnh)
  final List<Map<String, dynamic>> ingredients = [
    {"name": "2 ripe Avocados", "inFridge": true},
    {"name": "200g Spinach", "inFridge": false},
    {"name": "500g Pasta", "inFridge": false},
    {"name": "1 Lemon", "inFridge": true},
    {"name": "3 Garlic Cloves", "inFridge": false},
  ];

  final List<String> instructions = [
    "Boil the pasta in salted water according to the package instructions until al dente. Reserve 1/2 cup of pasta water before draining.",
    "While pasta cooks, combine avocado, spinach, lemon juice, garlic, and olive oil in a blender. Blend until smooth and creamy.",
    "Drain the pasta and return it to the pot. Pour the green sauce over the pasta. Add the reserved pasta water a little at a time to loosen the sauce if needed.",
    "Toss gently until well coated. Season with salt and pepper to taste. Serve immediately topped with optional parmesan or pine nuts."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Nút Add to Calendar cố định ở đáy
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text(
                "Add to calendar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),

      body: ResponsiveLayout(
        // --- MOBILE LAYOUT ---
        mobileBody: _buildContent(isMobile: true),

        // --- WEB/DESKTOP LAYOUT ---
        // Giới hạn chiều rộng và căn giữa để không bị vỡ giao diện trên màn hình lớn
        desktopBody: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: _buildContent(isMobile: false),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isMobile}) {
    return CustomScrollView(
      slivers: [
        // 1. App Bar & Image Header
        SliverAppBar(
          expandedHeight: 300,
          pinned: true, // Thanh bar dính lại khi cuộn
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          actions: [
            // Trong SliverAppBar actions:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    // Gọi hàm hiển thị Modal Option
                    OptionModal.show(context);
                  },
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              "https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=600&auto=format&fit=crop", // Ảnh Pasta Bơ
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. Nội dung chính (Title, Info, Ingredient, Steps)
        SliverToBoxAdapter(
          child: Container(
            // Bo tròn góc trên để đè lên ảnh một chút tạo hiệu ứng card
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            // Dịch chuyển lên trên đè vào ảnh (-30px)
            transform: Matrix4.translationValues(0, -30, 0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TITLE SECTION ---
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
                Text(
                  "Creamy Avocado & Spinach Pesto Pasta",
                  style: GoogleFonts.merriweather(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "By GreenChef • Italian Inspired",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),

                // --- TAGS SECTION ---
                Row(
                  children: [
                    _buildTag(
                        Icons.access_time, "15 Mins", greenTagBg, mainColor),
                    const SizedBox(width: 12),
                    _buildTag(
                        Icons.bolt, "Easy", orangeTagBg, Colors.orange[800]!),
                    const SizedBox(width: 12),
                    _buildTag(Icons.local_fire_department_outlined, "320 Kcal",
                        blueTagBg, Colors.blue[800]!),
                  ],
                ),
                const SizedBox(height: 32),

                // --- INGREDIENTS HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ingredients",
                      style: GoogleFonts.merriweather(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mainColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildServingBtn(
                              Icons.remove,
                              () => setState(
                                  () => servings > 1 ? servings-- : null)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text("$servings Servings",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          _buildServingBtn(
                              Icons.add, () => setState(() => servings++)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // --- INGREDIENTS LIST ---
                ...List.generate(ingredients.length, (index) {
                  final item = ingredients[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      activeColor: Colors.green, // Checkbox màu xanh
                      checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      title: Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          decoration: ingredientChecks[index]
                              ? TextDecoration.lineThrough
                              : null, // Gạch ngang nếu đã check
                          decorationColor: Colors.grey,
                        ),
                      ),
                      secondary: item['inFridge'] == true
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: greenTagBg,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.kitchen,
                                      size: 12, color: Colors.green),
                                  const SizedBox(width: 4),
                                  const Text("In Fridge",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          : null,
                      value: ingredientChecks[index],
                      onChanged: (val) {
                        setState(() {
                          ingredientChecks[index] = val!;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      controlAffinity: ListTileControlAffinity
                          .leading, // Checkbox nằm bên trái
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // --- INSTRUCTIONS HEADER ---
                Text(
                  "Instructions",
                  style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainColor),
                ),
                const SizedBox(height: 16),

                // --- INSTRUCTIONS LIST ---
                ...List.generate(instructions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Số thứ tự (Circle Number)
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: mainColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Nội dung bước
                        Expanded(
                          child: Text(
                            instructions[index],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Khoảng trống cuối cùng để nội dung không bị sát quá
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
      ],
    );
  }

  // Widget con: Tag thông tin (Màu nền, màu chữ, icon)
  Widget _buildTag(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget con: Nút tăng giảm số lượng (Servings)
  Widget _buildServingBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }
}
