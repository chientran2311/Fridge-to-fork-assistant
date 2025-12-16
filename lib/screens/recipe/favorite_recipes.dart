import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
// Reuse your existing PrimaryButton if desired, though these specific buttons have custom sizing
import '../../widgets/common/primary_button.dart'; 

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  final Color mainColor = const Color(0xFF1B3B36);
  String _selectedFilter = "All";

  // Mock Data based on image_719e60.png
  final List<Map<String, dynamic>> favorites = [
    {
      "type": "image",
      "image": "https://images.unsplash.com/photo-1525351484163-7529414395d8?auto=format&fit=crop&w=600&q=80", // Avocado Toast
      "category": "BREAKFAST",
      "kcal": "350 kcal",
      "title": "Avocado Toast & Egg",
      "desc": "Whole grain bread with mashed avocado.",
    },
    {
      "type": "image",
      "image": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80", // Quinoa Salad
      "category": "LUNCH",
      "kcal": "420 kcal",
      "title": "Superfood Quinoa Salad",
      "desc": "Packed with protein and fresh veggies.",
    },
    {
      "type": "color", // Special case for Pumpkin Soup (Yellow bg)
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
      backgroundColor: const Color(0xFFF9F9F7), // Cream background from image
      body: SafeArea(
        child: ResponsiveLayout(
          // --- MOBILE LAYOUT ---
          mobileBody: _buildContent(crossAxisCount: 1),
          
          // --- TABLET/WEB LAYOUT ---
          desktopBody: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _buildContent(crossAxisCount: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required int crossAxisCount}) {
    return CustomScrollView(
      slivers: [
        // 1. Header Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "My Favorite Recipes",
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // 2. Filter Chips (Horizontal Scroll)
        SliverToBoxAdapter(
          child: SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? mainColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
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
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // 3. Recipe Cards Grid/List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: crossAxisCount == 1 ? 0.85 : 0.9, 
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // If we are at the end, show "Discover More"
                if (index == favorites.length) {
                  return const DiscoverMoreCard();
                }
                return FavoriteRecipeCard(data: favorites[index]);
              },
              childCount: favorites.length + 1, // +1 for Discover More card
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom spacing
      ],
    );
  }
}

// --- WIDGET: FAVORITE RECIPE CARD (Custom layout for this screen) ---
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE HEADER ---
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                // Image or Colored Placeholder
                Container(
                  width: double.infinity,
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
                // Heart Icon
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 18, color: Colors.redAccent),
                  ),
                )
              ],
            ),
          ),

          // --- CONTENT ---
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata: BREAKFAST • 350 kcal
                      Text(
                        "${data['category']}  •  ${data['kcal']}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
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
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Desc
                      Text(
                        data['desc'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  
                  // Buttons Row: Schedule & Today
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                          label: const Text("Schedule", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F5F5),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 14, color: Colors.white),
                          label: const Text("Today", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

// --- WIDGET: DISCOVER MORE CARD (Dashed Border) ---
class DiscoverMoreCard extends StatelessWidget {
  const DiscoverMoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedRectPainter(color: Colors.grey.shade300, strokeWidth: 1.5, gap: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F7), // Match background to look transparent
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

// Helper for Dashed Border
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

    Path _topPath = getDashedPath(a: const Offset(0, 0), b: Offset(x, 0), gap: gap);
    Path _rightPath = getDashedPath(a: Offset(x, 0), b: Offset(x, y), gap: gap);
    Path _bottomPath = getDashedPath(a: Offset(0, y), b: Offset(x, y), gap: gap);
    Path _leftPath = getDashedPath(a: const Offset(0, 0), b: Offset(0, y), gap: gap);

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);
  }

  Path getDashedPath({required Offset a, required Offset b, required double gap}) {
    Size size = Size(b.dx - a.dx, b.dy - a.dy);
    Path path = Path();
    path.moveTo(a.dx, a.dy);
    bool shouldDraw = true;
    Offset currentPoint = a;

    double radians = (size.bottomRight(Offset.zero) - size.topLeft(Offset.zero)).direction;
    double distance = 0.0;
    double fullDistance = (size.bottomRight(Offset.zero) - size.topLeft(Offset.zero)).distance;

    while (distance < fullDistance) {
      double nextDistance = distance + gap;
      if (nextDistance > fullDistance) nextDistance = fullDistance;
      
      double dx = nextDistance * (b.dx - a.dx) / fullDistance;
      double dy = nextDistance * (b.dy - a.dy) / fullDistance;
      
      if (shouldDraw) {
        path.lineTo(a.dx + dx, a.dy + dy);
      } else {
        path.moveTo(a.dx + dx, a.dy + dy);
      }
      shouldDraw = !shouldDraw;
      distance = nextDistance;
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}