import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/models/household_recipe.dart';
import 'package:provider/provider.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Providers & Models
import '../../providers/inventory_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../models/household_recipe.dart';

// Import Widgets
import '../../widgets/recipe/ai_recipe/ai_recipe_header.dart';
import '../../widgets/recipe/ai_recipe/recipe_card.dart';

class AIRecipeScreen extends StatefulWidget {
  const AIRecipeScreen({super.key});

  @override
  State<AIRecipeScreen> createState() => _AIRecipeScreenState();
}

class _AIRecipeScreenState extends State<AIRecipeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm load dữ liệu ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });
  }

  void _loadRecipes() {
    // 1. Lấy nguyên liệu từ InventoryProvider
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final ingredients = inventory.ingredientNames;

    // 2. Gọi API thông qua RecipeProvider
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (ingredients.isNotEmpty) {
      recipeProvider.getRecipesByIngredients(ingredients);
    } else {
      // Nếu tủ lạnh trống, không làm gì hoặc reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: ResponsiveLayout(
          // Truyền logic hiển thị vào cả mobile và desktop
          mobileBody: _buildBody(isGrid: false),
          desktopBody: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _buildBody(isGrid: true),
            ),
          ),
        ),
      ),
      // Fix: Thêm nút Generate để người dùng chủ động tìm kiếm công thức
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadRecipes,
        backgroundColor: const Color(0xFF0FBD3B),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("Gợi ý món mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Tách hàm build chính để tái sử dụng
  Widget _buildBody({required bool isGrid}) {
    return CustomScrollView(
      slivers: [
        // 1. Header (Giữ nguyên)
        const SliverToBoxAdapter(
          child: AIRecipeHeader(),
        ),

        // 2. Nội dung chính (Dùng Consumer)
        Consumer2<RecipeProvider, InventoryProvider>(
          builder: (context, recipeProvider, inventoryProvider, child) {
            
            // TRƯỜNG HỢP 1: Tủ lạnh trống
            if (inventoryProvider.items.isEmpty) {
              return const SliverFillRemaining( // Dùng SliverFillRemaining để căn giữa màn hình
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 100), // Đẩy lên một chút cho đẹp
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Tủ lạnh trống trơn!", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Hãy thêm nguyên liệu để nhận gợi ý.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }

            // TRƯỜNG HỢP 2: Đang tải
            if (recipeProvider.isLoading) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: Color(0xFF0FBD3B))),
              );
            }

            // TRƯỜNG HỢP 3: Có lỗi
            if (recipeProvider.errorMessage.isNotEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          "Đã có lỗi xảy ra",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipeProvider.errorMessage, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // TRƯỜNG HỢP 4: Không tìm thấy công thức nào
            if (recipeProvider.recipes.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Không tìm thấy món ăn nào phù hợp :(", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            // TRƯỜNG HỢP 5: Hiển thị danh sách (Thành công)
            return isGrid
                ? _buildGridList(recipeProvider.recipes)
                : _buildVerticalList(recipeProvider.recipes);
          },
        ),

        // Khoảng trống dưới cùng
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // Widget hiển thị dạng Grid (Tablet/Web)
  Widget _buildGridList(List<HouseholdRecipe> recipes) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
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

  // Widget hiển thị dạng List (Mobile)
  Widget _buildVerticalList(List<HouseholdRecipe> recipes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          child: RecipeCard(recipe: recipes[index]),
        ),
        childCount: recipes.length,
      ),
    );
  }
}