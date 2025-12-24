import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';


class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  final Color mainColor = const Color(0xFF1B3B36);
  String _selectedFilter = "All";

  // Mock Data
  final List<Map<String, dynamic>> favorites = [
    {
      "type": "image",
      "image": "https://images.unsplash.com/photo-1525351484163-7529414395d8?auto=format&fit=crop&w=600&q=80",
      "category": "BREAKFAST",
      "kcal": "350 kcal",
      "title": "Avocado Toast & Egg",
      "desc": "Whole grain bread with mashed avocado.",
    },
    {
      "type": "image",
      "image": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80",
      "category": "LUNCH",
      "kcal": "420 kcal",
      "title": "Superfood Quinoa Salad",
      "desc": "Packed with protein and fresh veggies.",
    },
    {
      "type": "color",
      "color": const Color(0xFFFFF9C4),
      "icon": Icons.soup_kitchen_outlined,
      "iconColor": Colors.orange,
      "category": "DINNER",
      "kcal": "280 kcal",
      "title": "Pumpkin Soup",
      "desc": "Creamy, warming, and easy to make.",
    },
  ];

  final List<String> filters = ["All", "Breakfast", "Lunch", "Dinner", "Snacks"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      // ĐÃ XÓA bottomNavigationBar TẠI ĐÂY
      body: SafeArea(
        child: ResponsiveLayout(
          // --- MOBILE: Dùng List thay vì Grid ---
          mobileBody: _buildMobileList(),
          
          // --- TABLET: Grid 2 cột ---
          tabletBody: _buildGridContent(crossAxisCount: 2, aspectRatio: 0.8),
          
          // --- DESKTOP: Grid 3 cột, căn giữa ---
          desktopBody: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildGridContent(crossAxisCount: 3, aspectRatio: 0.85),
            ),
          ),
        ),
      ),
    );
  }

  // Layout cho Mobile: Dùng SliverList
  Widget _buildMobileList() {
    return CustomScrollView(
      slivers: [
        _buildHeader(), // Header có nút Back
        _buildFilterChips(),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == favorites.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: const SizedBox(
                      height: 150,
                      child: DiscoverMoreCard(),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: 310, // Chiều cao cố định cho card mobile
                    child: FavoriteRecipeCard(data: favorites[index]),
                  ),
                );
              },
              childCount: favorites.length + 1,
            ),
          ),
        ),
      ],
    );
  }

  // Layout cho Web/Tablet: Dùng Grid
  Widget _buildGridContent({required int crossAxisCount, required double aspectRatio}) {
    return CustomScrollView(
      slivers: [
        _buildHeader(), // Header có nút Back
        _buildFilterChips(),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == favorites.length) {
                  return const DiscoverMoreCard();
                }
                return FavoriteRecipeCard(data: favorites[index]);
              },
              childCount: favorites.length + 1,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // --- WIDGET HEADER ĐÃ SỬA ĐỔI (Thêm nút Back) ---
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 20, 10), // Giảm padding trái một chút cho icon
        child: Row(
          children: [
            // Nút Back
          CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
            // Tiêu đề
            Expanded(
              child: Text(
                "My Favorite Recipes",
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left, // Căn lề trái cho văn bản
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? mainColor : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGET: CARD MÓN ĂN YÊU THÍCH (Giữ nguyên logic Card đã tối ưu) ---
class FavoriteRecipeCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const FavoriteRecipeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // 1. ẢNH: Cố định chiều cao
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    color: data['type'] == 'color' ? data['color'] : Colors.grey[200],
                  ),
                  child: data['type'] == 'image'
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.network(data['image'], fit: BoxFit.cover),
                        )
                      : Icon(data['icon'], size: 48, color: data['iconColor']),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, size: 16, color: Color(0xFFE57373)),
                  ),
                )
              ],
            ),
          ),

          // 2. NỘI DUNG: Chiếm phần còn lại
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata
                  Text(
                    "${data['category']}  •  ${data['kcal']}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Title
                  Text(
                    data['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    data['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                  ),
                  
                  const Spacer(), // Đẩy nút xuống đáy
                  
                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                            label: const Text("Schedule", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F5),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 14, color: Colors.white),
                            label: const Text("Today", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: DISCOVER MORE CARD ---
class DiscoverMoreCard extends StatelessWidget {
  const DiscoverMoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedRectPainter(color: Colors.grey.shade300, strokeWidth: 1.5, gap: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              "Discover More",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "Browse AI suggestions",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper vẽ viền đứt nét (Simplified)
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.black, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;
    double r = 24.0;
    
    var path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, x, y), Radius.circular(r)));
    canvas.drawPath(path, dashedPaint); 
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}