// =============================================================================
// FILTER MODAL - RECIPE SEARCH FILTERS
// =============================================================================
// File: lib/screens/recipe/filter_modal.dart
// Feature: Recipe Filter Options for Search
// Description: Bottom sheet modal cho phép user filter recipes theo
//              cuisine, difficulty, meal type và prep time.
//
// Filter Options:
//   - Cuisine: Italian, Mexican, Asian, Mediterranean, Vegan
//   - Difficulty: Easy, Medium, Hard
//   - Meal Type: Breakfast, Lunch, Dinner, Snack
//   - Max Prep Time: 15-120 minutes slider
//
// Author: Fridge to Fork Team
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../widgets/common/primary_button.dart';
import '../../models/RecipeFilter.dart';

// =============================================================================
// FILTER MODAL WIDGET
// =============================================================================
class FilterModal extends StatefulWidget {
  final RecipeFilter currentFilter;

  const FilterModal({super.key, required this.currentFilter});

  /// Show filter modal and return updated filter
  static Future<RecipeFilter?> show(BuildContext context, RecipeFilter currentFilter) async {
    return showModalBottomSheet<RecipeFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(currentFilter: currentFilter),
    );
  }

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final Color mainColor = const Color(0xFF1B3B36);

  // State cục bộ trong Modal
  String? _difficulty;
  String? _mealType;
  String? _cuisine;
  double _maxPrepTime = 120; // Mặc định max

  @override
  void initState() {
    super.initState();
    // Load dữ liệu từ Filter hiện tại vào Modal
    _difficulty = widget.currentFilter.difficulty;
    _mealType = widget.currentFilter.mealType;
    _cuisine = widget.currentFilter.cuisine;
    _maxPrepTime = (widget.currentFilter.maxPrepTime).toDouble();
  }

  // Hàm Reset về trạng thái trắng
  void _resetFilters() {
    setState(() {
      _difficulty = null;
      _mealType = null;
      _cuisine = null;
      _maxPrepTime = 120;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!; // Tạm tắt để demo text cứng, bạn mở lại sau
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HANDLE BAR ---
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Recipes", // l10n.filterTitle
                  style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.w900, color: mainColor),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    "Reset", // l10n.reset
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // --- CONTENT ---
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Difficulty
                  _buildSectionTitle("Difficulty Level"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildChip("Easy", "Easy", Icons.check),
                      _buildChip("Medium", "Medium", null),
                      _buildChip("Hard", "Hard", null),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Meal Type
                  _buildSectionTitle("Meal Type"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildChip("Breakfast", "breakfast", Icons.bedroom_parent_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                      _buildChip("Lunch", "lunch", Icons.soup_kitchen_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                      _buildChip("Dinner", "dinner", Icons.dinner_dining_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                      _buildChip("Snack", "snack", Icons.cookie_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Cuisine (Thêm Mediterranean như ảnh)
                  _buildSectionTitle("Cuisine"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                       _buildChip("Italian", "Italian", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                       _buildChip("Mexican", "Mexican", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                       _buildChip("Asian", "Asian", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                       _buildChip("Vegan", "Vegan", Icons.eco, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                       _buildChip("Mediterranean", "Mediterranean", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Max Prep Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Max Prep Time"),
                      Text(
                        _maxPrepTime >= 120 ? "All" : "${_maxPrepTime.toInt()} min",
                        style: TextStyle(fontWeight: FontWeight.bold, color: mainColor),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: mainColor,
                      inactiveTrackColor: Colors.grey[200],
                      thumbColor: mainColor,
                      overlayColor: mainColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _maxPrepTime,
                      min: 15,
                      max: 120,
                      divisions: 7, // 15, 30, 45, 60, 75, 90, 105, 120
                      label: _maxPrepTime >= 120 ? "2+ hours" : "${_maxPrepTime.toInt()} min",
                      onChanged: (val) {
                        setState(() {
                          _maxPrepTime = val;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("15 min", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      Text("2+ hours", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- BOTTOM BUTTON ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                text: "Apply Filters", // (${_countFilters()}) logic đếm filter
                onPressed: () {
                  final result = RecipeFilter(
                    difficulty: _difficulty,
                    mealType: _mealType,
                    cuisine: _cuisine,
                    maxPrepTime: _maxPrepTime.toInt(),
                  );
                  Navigator.pop(context, result);
                },
                backgroundColor: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1B3B36)));
  }

  // Hàm tạo Chip tổng quát
  Widget _buildChip(
    String label, 
    String value, 
    IconData? icon, 
    {String? groupValue, Function(String?)? onChanged}
  ) {
    // Xử lý riêng cho Difficulty vì biến state khác nhau
    if (onChanged == null) {
      // Logic cũ cho difficulty (tạm dùng local state _difficulty)
      final isSelected = _difficulty == value;
      return GestureDetector(
        onTap: () {
            // Cho phép toggle tắt
             setState(() => _difficulty = isSelected ? null : value);
        },
        child: _chipDesign(label, icon, isSelected),
      );
    } 
    
    // Logic chung cho mealType và cuisine
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () {
        // Nếu đang chọn thì click lại sẽ bỏ chọn (về null)
        onChanged(isSelected ? null : value);
      },
      child: _chipDesign(label, icon, isSelected),
    );
  }

  Widget _chipDesign(String label, IconData? icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? mainColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? mainColor : Colors.grey.shade300, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? Colors.white : Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}