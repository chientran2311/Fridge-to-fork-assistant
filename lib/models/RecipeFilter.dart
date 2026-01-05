class RecipeFilter {
  final String? difficulty; // 'Easy', 'Medium', 'Hard' hoặc null
  final String? mealType;   // 'breakfast', 'lunch', 'dinner', 'snack' hoặc null
  final String? cuisine;    // 'Italian', 'Mexican', 'Asian', 'Mediterranean', 'Vegan'...
  final int maxPrepTime;    // Mặc định là 120 (hoặc giá trị max của slider), để null nếu muốn không filter

  // Constructor mặc định (khi mới vào app hoặc reset)
  RecipeFilter({
    this.difficulty, // Để null nghĩa là "All difficulties"
    this.mealType,
    this.cuisine,
    this.maxPrepTime = 120, // Mặc định max time để lấy tất cả
  });

  // Kiểm tra xem filter có đang được áp dụng không (để hiện badge số lượng filter)
  int get appliedFilterCount {
    int count = 0;
    if (difficulty != null && difficulty!.isNotEmpty) count++;
    if (mealType != null && mealType!.isNotEmpty) count++;
    if (cuisine != null && cuisine!.isNotEmpty) count++;
    if (maxPrepTime < 120) count++; // Chỉ đếm nếu user kéo time thấp xuống
    return count;
  }

  RecipeFilter copyWith({
    String? difficulty,
    String? mealType,
    String? cuisine,
    int? maxPrepTime,
  }) {
    return RecipeFilter(
      difficulty: difficulty ?? this.difficulty,
      mealType: mealType ?? this.mealType,
      cuisine: cuisine ?? this.cuisine,
      maxPrepTime: maxPrepTime ?? this.maxPrepTime,
    );
  }
}