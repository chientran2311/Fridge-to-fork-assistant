import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import 'package:go_router/go_router.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Provider và Model
import '../../providers/recipe_provider.dart';
import '../../models/household_recipe.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  final Color mainColor = const Color(0xFF1B3B36);
  String _selectedFilter = "All";

  // Mock filters 
  final List<String> filters = ["All", "Breakfast", "Lunch", "Dinner", "Snacks"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).listenToFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      body: SafeArea(
        child: Consumer<RecipeProvider>(
          builder: (context, recipeProvider, child) {
            final favorites = recipeProvider.favoriteRecipes;

            if (favorites.isEmpty && !recipeProvider.isLoading) {
               return _buildEmptyState(); 
            }

            return ResponsiveLayout(
              mobileBody: _buildMobileList(favorites),
              tabletBody: _buildGridContent(favorites, crossAxisCount: 2, aspectRatio: 0.8),
              desktopBody: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _buildGridContent(favorites, crossAxisCount: 3, aspectRatio: 0.85),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- [FIXED] Hàm này dùng Column nên child phải là Box Widget ---
  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildHeader(), // Đã sửa hàm này trả về Padding (Box) nên không lỗi nữa
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Chưa có món yêu thích nào", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/recipes'),
                  child: const Text("Khám phá ngay"),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(List<HouseholdRecipe> favorites) {
    return CustomScrollView(
      slivers: [
        // [FIXED] Vì Header giờ là Box, cần bọc lại bằng SliverToBoxAdapter khi dùng trong CustomScrollView
        SliverToBoxAdapter(child: _buildHeader()), 
        _buildFilterChips(), // Widget này vẫn trả về Sliver nên để nguyên
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
                    height: 310,
                    child: FavoriteRecipeCard(recipe: favorites[index]),
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

  Widget _buildGridContent(List<HouseholdRecipe> favorites, {required int crossAxisCount, required double aspectRatio}) {
    return CustomScrollView(
      slivers: [
        // [FIXED] Bọc Header lại
        SliverToBoxAdapter(child: _buildHeader()),
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
                return FavoriteRecipeCard(recipe: favorites[index]);
              },
              childCount: favorites.length + 1,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // --- [FIXED] Đã xóa SliverToBoxAdapter bao quanh, trả về Padding thuần ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Món Yêu Thích",
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    // Widget này vẫn giữ SliverToBoxAdapter vì chỉ dùng trong CustomScrollView
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

class FavoriteRecipeCard extends StatelessWidget {
  final HouseholdRecipe recipe;

  const FavoriteRecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);

    return GestureDetector(
      onTap: () {
        context.go('/recipes/detail', extra: recipe);
      },
      child: Container(
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
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        recipe.imageUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                         Provider.of<RecipeProvider>(context, listen: false).toggleFavorite(recipe, context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, size: 16, color: Color(0xFFE57373)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${recipe.readyInMinutes} min  •  ${recipe.calories?.toInt() ?? '?'} kcal",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.merriweather(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Difficulty: ${recipe.difficulty ?? 'Medium'}", 
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                    const Spacer(), 
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
                              onPressed: () {
                                context.go('/recipes/detail', extra: recipe);
                              },
                              icon: const Icon(Icons.restaurant_menu, size: 14, color: Colors.white),
                              label: const Text("Cook Now", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}

class DiscoverMoreCard extends StatelessWidget {
  const DiscoverMoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/recipes'),
      child: CustomPaint(
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
      ),
    );
  }
}

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