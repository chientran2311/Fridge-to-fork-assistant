import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

import 'package:fridge_to_fork_assistant/widgets/common/primary_button.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  // --- HÀM STATIC ĐỂ GỌI MODAL RESPONSIVE ---
  // Gọi hàm này từ màn hình cha, nó sẽ tự quyết định hiện Dialog hay BottomSheet
  static void show(BuildContext context) {
    if (ResponsiveLayout.isDesktop(context)) {
      // WEB: Hiện Dialog giữa màn hình
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (context) => const Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 450, // Chiều rộng cố định cho Web
            child: FilterModal(),
          ),
        ),
      );
    } else {
      // MOBILE: Hiện BottomSheet từ dưới lên
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Cho phép modal cao theo nội dung
        backgroundColor: Colors.transparent,
        builder: (context) => const FilterModal(),
      );
    }
  }

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final Color mainColor = const Color(0xFF1B3B36);
  
  // State quản lý lựa chọn
  String _difficulty = 'Easy';
  String _mealType = 'Lunch';
  String _cuisine = 'Italian';
  double _maxPrepTime = 45.0; // Slider value

  @override
  Widget build(BuildContext context) {
    // Xác định bo góc tùy theo Web hay Mobile
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final BorderRadius borderRadius = isDesktop
        ? BorderRadius.circular(24) // Web: Bo tròn 4 góc
        : const BorderRadius.vertical(top: Radius.circular(24)); // Mobile: Chỉ bo góc trên

    return Container(
      // Giới hạn chiều cao max trên mobile để không che hết màn hình
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. HANDLE BAR (Chỉ Mobile mới cần) ---
          if (!isDesktop)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // --- 2. HEADER ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Recipes",
                  style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: mainColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Reset logic
                      _difficulty = 'Easy';
                      _maxPrepTime = 15;
                    });
                  },
                  child: Text(
                    "Reset",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),

          const Divider(height: 1),

          // --- 3. SCROLLABLE CONTENT ---
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- DIFFICULTY ---
                  _buildSectionTitle("Difficulty Level"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      _buildChip("Easy", Icons.check),
                      _buildChip("Medium", null),
                      _buildChip("Hard", null),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- MEAL TYPE ---
                  _buildSectionTitle("Meal Type"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildChip("Breakfast", Icons.bedroom_parent_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                      _buildChip("Lunch", Icons.soup_kitchen_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                      _buildChip("Dinner", Icons.dinner_dining_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                      _buildChip("Snack", Icons.cookie_outlined, groupValue: _mealType, onChanged: (v) => setState(() => _mealType = v)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- CUISINE ---
                  _buildSectionTitle("Cuisine"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildChip("Italian", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                      _buildChip("Mexican", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                      _buildChip("Asian", null, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                      _buildChip("Vegan", Icons.eco, groupValue: _cuisine, onChanged: (v) => setState(() => _cuisine = v)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- MAX PREP TIME ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Max Prep Time"),
                      Text(
                        "${_maxPrepTime.toInt()} min",
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
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _maxPrepTime,
                      min: 5,
                      max: 120,
                      divisions: 23,
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

          // --- 4. BOTTOM BUTTON ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                text: "Apply Filters (3)",
                onPressed: () {
                  // Apply logic here
                  Navigator.pop(context);
                },
                backgroundColor: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1B3B36),
      ),
    );
  }

  // Widget tạo Chip (Nút chọn)
  Widget _buildChip(
    String label, 
    IconData? icon, 
    {String? groupValue, Function(String)? onChanged}
  ) {
    // Nếu không truyền groupValue thì mặc định dùng cho Difficulty
    final bool isSelected = (groupValue == null) 
        ? _difficulty == label 
        : groupValue == label;

    return GestureDetector(
      onTap: () {
        if (groupValue == null) {
          setState(() => _difficulty = label);
        } else {
          onChanged?.call(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? mainColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? mainColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}