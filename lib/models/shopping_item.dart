/// Model for shopping list item với tracking user adjustments
class ShoppingItem {
  String itemId;
  String ingredientName;
  double systemQuantity; // ✅ Số lượng tính từ meal_plans
  double userAdjustment; // ✅ Lượng user đã thêm/bớt (delta)
  double finalQuantity; // ✅ = systemQuantity + userAdjustment
  String unit;
  String category;
  String date; // YYYY-MM-DD format
  bool isChecked;
  bool isUserEdited; // ✅ Flag để biết user đã edit chưa
  String? recipeTitle;

  ShoppingItem({
    required this.itemId,
    required this.ingredientName,
    required this.systemQuantity,
    this.userAdjustment = 0.0,
    required this.finalQuantity,
    required this.unit,
    required this.category,
    required this.date,
    this.isChecked = false,
    this.isUserEdited = false,
    this.recipeTitle,
  });

  /// Create from JSON (for local storage)
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      itemId: json['item_id'] as String,
      ingredientName: json['ingredient_name'] as String,
      systemQuantity: (json['system_quantity'] as num?)?.toDouble() ?? 0.0,
      userAdjustment: (json['user_adjustment'] as num?)?.toDouble() ?? 0.0,
      finalQuantity: (json['final_quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      date: json['date'] as String,
      isChecked: json['is_checked'] as bool? ?? false,
      isUserEdited: json['is_user_edited'] as bool? ?? false,
      recipeTitle: json['recipe_title'] as String?,
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'ingredient_name': ingredientName,
      'system_quantity': systemQuantity,
      'user_adjustment': userAdjustment,
      'final_quantity': finalQuantity,
      'unit': unit,
      'category': category,
      'date': date,
      'is_checked': isChecked,
      'is_user_edited': isUserEdited,
      'recipe_title': recipeTitle,
    };
  }

  /// Update system quantity (từ meal_plans) while preserving user adjustment
  void updateSystemQuantity(double newSystemQty) {
    systemQuantity = newSystemQty;
    finalQuantity = systemQuantity + userAdjustment;
  }

  /// User edits the final quantity
  void updateUserQuantity(double newFinalQty) {
    userAdjustment = newFinalQty - systemQuantity;
    finalQuantity = newFinalQty;
    isUserEdited = true;
  }

  /// Reset user adjustment (back to system quantity)
  void resetToSystemQuantity() {
    userAdjustment = 0.0;
    finalQuantity = systemQuantity;
    isUserEdited = false;
  }

  @override
  String toString() {
    return 'ShoppingItem($ingredientName: sys=$systemQuantity, adj=$userAdjustment, final=$finalQuantity)';
  }
}
