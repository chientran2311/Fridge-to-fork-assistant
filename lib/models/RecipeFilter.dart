// =============================================================================
// RECIPE FILTER MODEL - SEARCH FILTER OPTIONS
// =============================================================================
// File: lib/models/RecipeFilter.dart
// Feature: Filter Configuration for Recipe Search
// Description: Model lưu trữ các filter options cho recipe search.
//              Được dùng bởi FilterModal và truyền đến SpoonacularService.
//
// Filter Properties:
//   - difficulty: Easy, Medium, Hard (maps to maxReadyTime in API)
//   - mealType: breakfast, lunch, dinner, snack (maps to type in API)
//   - cuisine: Italian, Mexican, Asian, etc. (maps to cuisine in API)
//   - maxPrepTime: 15-120 minutes (maps to maxReadyTime in API)
//
// Author: Fridge to Fork Team
// =============================================================================

// =============================================================================
// RECIPE FILTER CLASS
// =============================================================================
class RecipeFilter {
  final String? difficulty; // 'Easy', 'Medium', 'Hard' or null
  final String? mealType;   // 'breakfast', 'lunch', 'dinner', 'snack' or null
  final String? cuisine;    // 'Italian', 'Mexican', 'Asian', 'Mediterranean', 'Vegan'
  final int maxPrepTime;    // Default 120 (max slider value)

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------
  RecipeFilter({
    this.difficulty,
    this.mealType,
    this.cuisine,
    this.maxPrepTime = 120,
  });

  // ---------------------------------------------------------------------------
  // COMPUTED PROPERTIES
  // ---------------------------------------------------------------------------
  /// Count how many filters are currently applied (for UI badge)
  int get appliedFilterCount {
    int count = 0;
    if (difficulty != null && difficulty!.isNotEmpty) count++;
    if (mealType != null && mealType!.isNotEmpty) count++;
    if (cuisine != null && cuisine!.isNotEmpty) count++;
    if (maxPrepTime < 120) count++;
    return count;
  }

  // ---------------------------------------------------------------------------
  // COPY METHOD
  // ---------------------------------------------------------------------------
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