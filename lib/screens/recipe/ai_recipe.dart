import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/models/household_recipe.dart';
import 'package:provider/provider.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Providers & Models
import '../../providers/inventory_provider.dart';
import '../../providers/recipe_provider.dart';

// Import Widgets
import '../../widgets/recipe/ai_recipe/ai_recipe_header.dart';
import '../../widgets/recipe/ai_recipe/recipe_card.dart'; // Đảm bảo import file Card mới bên dưới

class AIRecipeScreen extends StatefulWidget {
  const AIRecipeScreen({super.key});

  @override
  State<AIRecipeScreen> createState() => _AIRecipeScreenState();
}

class _AIRecipeScreenState extends State<AIRecipeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });
  }

  void _loadRecipes() {
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final ingredients = inventory.ingredientNames;
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    // Logic: Luôn gọi API để refresh hoặc load mới nếu có nguyên liệu
    if (ingredients.isNotEmpty) {
      recipeProvider.getRecipesByIngredients(ingredients);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Màu xanh đậm giống trong ảnh nút "Generate"
    final Color darkGreenColor = const Color(0xFF1B3B36); 

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Màu nền xám rất nhạt cho hiện đại
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Nội dung chính
            ResponsiveLayout(
              mobileBody: _buildBody(isGrid: false),
              desktopBody: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: _buildBody(isGrid: true),
                ),
              ),
            ),

            // Nút Generate More Recipe (Nổi ở dưới đáy)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loadRecipes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: darkGreenColor.withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text(
                    "Tạo thêm công thức",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({required bool isGrid}) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: AIRecipeHeader(),
          ),
        ),

        Consumer2<RecipeProvider, InventoryProvider>(
          builder: (context, recipeProvider, inventoryProvider, child) {
            
            // 1. Tủ lạnh trống
            if (inventoryProvider.items.isEmpty) {
              return _buildStateMessage(
                icon: Icons.kitchen_outlined,
                message: "Tủ lạnh trống trơn!",
                subMessage: "Hãy thêm nguyên liệu để nhận gợi ý.",
              );
            }

            // 2. Đang tải
            if (recipeProvider.isLoading) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: Color(0xFF1B3B36))),
              );
            }

            // 3. Lỗi
            if (recipeProvider.errorMessage.isNotEmpty) {
              return _buildStateMessage(
                icon: Icons.error_outline,
                message: "Đã có lỗi xảy ra",
                subMessage: recipeProvider.errorMessage,
                isError: true,
              );
            }

            // 4. Không có kết quả
            if (recipeProvider.recipes.isEmpty) {
              return _buildStateMessage(
                icon: Icons.search_off,
                message: "Không tìm thấy món ăn nào",
                subMessage: "Thử cập nhật lại nguyên liệu xem sao nhé.",
              );
            }

            // 5. Hiển thị danh sách (Grid hoặc List)
            return isGrid
                ? _buildGridList(recipeProvider.recipes)
                : _buildVerticalList(recipeProvider.recipes);
          },
        ),

        // Khoảng trống để không bị nút Generate che mất item cuối
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // Widget hiển thị thông báo trạng thái (Empty/Error)
  Widget _buildStateMessage({
    required IconData icon,
    required String message,
    String? subMessage,
    bool isError = false,
  }) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: isError ? Colors.redAccent : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridList(List<HouseholdRecipe> recipes) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Tỷ lệ thẻ dài hơn chút để chứa info
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => RecipeCard(recipe: recipes[index]),
          childCount: recipes.length,
        ),
      ),
    );
  }

  Widget _buildVerticalList(List<HouseholdRecipe> recipes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: RecipeCard(recipe: recipes[index]),
        ),
        childCount: recipes.length,
      ),
    );
  }
}