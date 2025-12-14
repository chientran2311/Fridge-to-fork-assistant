import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import các file cần thiết của bạn
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'detail_recipe.dart';
import 'filter_modal.dart';
class AIRecipeScreen extends StatefulWidget {
  const AIRecipeScreen({super.key});

  @override
  State<AIRecipeScreen> createState() => _AIRecipeScreenState();
}

class _AIRecipeScreenState extends State<AIRecipeScreen> {
  final Color mainColor = const Color(0xFF1B3B36); // Xanh rêu đậm
  final Color greenBadgeColor =
      const Color(0xFFE8F5E9); // Nền xanh nhạt của banner

  // Dữ liệu mẫu y hệt trong ảnh
  final List<Map<String, dynamic>> recipes = [
    {
      "image":
          "https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=600&auto=format&fit=crop", // Ảnh Pasta Bơ
      "matchTag": "100% Match",
      "tagIcon": Icons.check_circle_outline,
      "title": "Creamy Avocado & Spinach Pesto Pasta",
      "desc":
          "A quick, protein-packed breakfast perfectly using your leftover sourdough.",
      "time": "15 min",
      "kcal": "320 kcal",
      "missing": 0,
      "isUrgent": false,
    },
    {
      "image":
          "https://images.unsplash.com/photo-1626844131082-256783844137?q=80&w=600&auto=format&fit=crop", // Ảnh Pasta Lemon Basil
      "matchTag": "Use Basil Soon",
      "tagIcon": Icons.access_time,
      "title": "Zesty Lemon Basil Pasta",
      "desc": "Fresh and light dinner. Use up that basil before it wilts!",
      "time": "25 min",
      "kcal": "500 kcal",
      "missing": 1,
      "isUrgent": true, // Để đổi màu badge
    },
    {
      "image":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop", // Ảnh Rau củ xào
      "matchTag": "100% Match",
      "tagIcon": Icons.check_circle_outline,
      "title": "Zero-Waste Veggie Stir-fry",
      "desc": "Delicious way to clear out the fridge veggies in one go.",
      "time": "20 min",
      "kcal": "410 kcal",
      "missing": 0,
      "isUrgent": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Để bottom nav nổi đẹp như thiết kế trước
      body: SafeArea(
        bottom: false, // Để nội dung tràn xuống dưới bottom nav
        child: ResponsiveLayout(
          // --- MOBILE: Dạng list dọc ---
          mobileBody: _buildContent(isGrid: false),

          // --- TABLET/WEB: Dạng lưới 2 cột ---
          desktopBody: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _buildContent(isGrid: true),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isGrid}) {
    // Header + Banner + List
    return CustomScrollView(
      slivers: [
        // 1. Header & Banner (Không cuộn mất, hoặc cuộn cùng nội dung tùy ý)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chef AI Suggestions",
                      style: GoogleFonts.merriweather(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    // Nút Filter Icon
                    GestureDetector(
                      onTap: () {
                        // Gọi hàm static thông minh này, nó tự check Web/Mobile để hiển thị đúng kiểu
                        FilterModal.show(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                          // Thêm shadow nhẹ khi hover/bấm nếu muốn
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(Icons.tune, size: 20, color: mainColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Green Summary Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EFE5), // Màu xanh nhạt nền banner
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco_outlined, color: mainColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: mainColor, fontSize: 13, height: 1.4),
                            children: const [
                              TextSpan(
                                  text:
                                      "Found 3 recipes to rescue your expiring ingredients. "),
                              TextSpan(
                                text: "You saved 250g of food this week!",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // 2. Recipe List (Grid hoặc List)
        isGrid
            ? SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột cho Desktop/Tablet
                    childAspectRatio: 0.85, // Tỷ lệ khung hình
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RecipeCard(data: recipes[index]),
                    childCount: recipes.length,
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    child: RecipeCard(data: recipes[index]),
                  ),
                  childCount: recipes.length,
                ),
              ),

        // Khoảng trống dưới cùng để không bị BottomNav che mất nội dung cuối
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// --- WIDGET RIÊNG: THẺ MÓN ĂN (RECIPE CARD) ---
class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecipeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF1B3B36);

    // 1. Bọc Container bằng GestureDetector để xử lý sự kiện click
    return GestureDetector(
      onTap: () {
        // 2. Thực hiện điều hướng sang trang chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            // Truyền data vào đây nếu RecipeDetailScreen sau này cần nhận dữ liệu
            builder: (context) => const RecipeDetailScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          // Shadow nhẹ giống ảnh
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ẢNH MÓN ĂN + BADGES ---
            Stack(
              children: [
                // Ảnh nền
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10, // Tỷ lệ khung ảnh
                    child: Image.network(
                      data['image'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                            color: Colors.grey[200]); // Placeholder
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image)),
                    ),
                  ),
                ),

                // Badge trái trên (100% Match / Use Basil Soon)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          data['tagIcon'],
                          size: 14,
                          color: mainColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['matchTag'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Badge tim phải trên
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),

            // --- 2. NỘI DUNG CHỮ ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên món
                  Text(
                    data['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mô tả
                  Text(
                    data['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hàng thông tin (Time, Kcal, Missing)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.access_time, text: data['time']),
                      _InfoChip(
                          icon: Icons.local_fire_department_outlined,
                          text: data['kcal']),
                      _InfoChip(
                        icon: Icons.shopping_bag_outlined,
                        text: "Missing: ${data['missing']}",
                        isHighlight: data['missing'] >
                            0, // Đổi màu nếu thiếu nguyên liệu
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET NHỎ: CHIP THÔNG TIN (Time, Kcal...) ---
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isHighlight;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFFFF4E5)
            : const Color(0xFFF5F5F5), // Cam nhạt nếu highlight
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isHighlight ? const Color(0xFFD86D35) : Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFFD86D35) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
