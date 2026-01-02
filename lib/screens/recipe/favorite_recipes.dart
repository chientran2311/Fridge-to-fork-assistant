import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import 'package:go_router/go_router.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Mock Data
  final List<Map<String, dynamic>> favorites = [
    {
      "type": "image",
      "image": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80",
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
                    height: 310, // Chiều cao cố định cho card mobile
                    child: FavoriteRecipeCard(
                      data: favorites[index],
                      onSchedule: () => _showScheduleCalendar(context, favorites[index]),
                    ),
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
                return FavoriteRecipeCard(
                  data: favorites[index],
                  onSchedule: () => _showScheduleCalendar(context, favorites[index]),
                );
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

  void _showScheduleCalendar(BuildContext context, HouseholdRecipe recipeData) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScheduleCalendarDialog(recipeData: recipeData),
    );
  }
}

class FavoriteRecipeCard extends StatelessWidget {
  final HouseholdRecipe data;
  final VoidCallback onSchedule;

  const FavoriteRecipeCard({super.key, required this.data, required this.onSchedule});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1B3B36);

    return GestureDetector(
      onTap: () {
        context.go('/recipes/detail', extra: data);
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
                        data.imageUrl ?? "",
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
                         Provider.of<RecipeProvider>(context, listen: false).toggleFavorite(data, context);
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
                      "${data.readyInMinutes} min  •  ${data.calories?.toInt() ?? '?'} kcal",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.title,
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
                      "Difficulty: ${data.difficulty ?? 'Medium'}", 
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
                              onPressed: onSchedule, 
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
                                context.go('/recipes/detail', extra: data);
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

  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.black,
    this.gap = 5.0,
  });

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

// ============== CALENDAR SCHEDULE DIALOG ==============
class ScheduleCalendarDialog extends StatefulWidget {
  final HouseholdRecipe recipeData;

  const ScheduleCalendarDialog({super.key, required this.recipeData});

  @override
  State<ScheduleCalendarDialog> createState() => _ScheduleCalendarDialogState();
}

class _ScheduleCalendarDialogState extends State<ScheduleCalendarDialog> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  String? _selectedMealType = 'Breakfast';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isScheduling = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
  }

  Future<void> _scheduleRecipe() async {
    if (_selectedDate == null || _selectedMealType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and meal type')),
      );
      return;
    }

    setState(() => _isScheduling = true);

    try {
      // Add meal plan to Firestore
      final householdId = 'house_seed_01'; // Temp hardcoded
      final dateKey = _selectedDate.toIso8601String().split('T')[0];

      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('meal_plans')
          .add({
        'date': Timestamp.fromDate(_selectedDate),
        'meal_type': _selectedMealType,
        'local_recipe_id': widget.recipeData.localRecipeId ?? widget.recipeData.apiRecipeId.toString(),
        'display_title': widget.recipeData.title,
        'display_image': widget.recipeData.imageUrl ?? '',
        'servings': 4,
        'is_cooked': false,
        'planned_by_uid': 'user_seed_01',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${widget.recipeData.title} scheduled for ${_selectedDate.day}/${_selectedDate.month}',
          ),
          backgroundColor: const Color(0xFF214130),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isScheduling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule Meal',
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // Recipe Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF214130).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.recipeData.imageUrl ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.restaurant, size: 32, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recipeData.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${widget.recipeData.calories?.toInt() ?? '?'} kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Calendar
              Text(
                'Select Date',
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDate = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFF214130),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF214130).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                    weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Meal Type Selection
              Text(
                'Select Meal Type',
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((mealType) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedMealType = mealType);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedMealType == mealType
                                    ? const Color(0xFF214130)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mealType,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedMealType == mealType
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Schedule Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isScheduling ? null : _scheduleRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF214130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isScheduling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Schedule Recipe',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}