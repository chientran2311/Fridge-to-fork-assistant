import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import 'package:fridge_to_fork_assistant/widgets/common/primary_button.dart';
import 'package:fridge_to_fork_assistant/models/household_recipe.dart';
import 'package:fridge_to_fork_assistant/providers/inventory_provider.dart';

import '../../data/services/spoonacular_service.dart';

import 'package:fridge_to_fork_assistant/widgets/recipe/detail/ingredients_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/instructions_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/recipe_detail_app_bar.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/recipe_tags_section.dart';
import 'package:fridge_to_fork_assistant/widgets/recipe/detail/recipe_title_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  final HouseholdRecipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Color mainColor = const Color(0xFF1B3B36);
  final SpoonacularService _spoonacularService = SpoonacularService();

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _processedIngredients = [];
  List<String> _processedInstructions = [];
  int _readyInMinutes = 0;
  
  // Quản lý trạng thái servings
  int _originalServings = 1;
  int _currentServings = 1;
  
  String _description = "";

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    setState(() => _isLoading = true);
    print("🚀 BẮT ĐẦU: Đang lấy chi tiết món ID: ${widget.recipe.apiRecipeId}");

    try {
      final data = await _spoonacularService
          .getRecipeInformation(widget.recipe.apiRecipeId);

      if (data != null) {
        // 1. Instructions
        if (data['analyzedInstructions'] != null &&
            (data['analyzedInstructions'] as List).isNotEmpty) {
          final List steps = data['analyzedInstructions'][0]['steps'];
          _processedInstructions = steps.map<String>((step) {
            return step['step'].toString();
          }).toList();
        } else if (data['instructions'] != null) {
          _processedInstructions =
              data['instructions'].toString().split(RegExp(r'\. |\n'));
          _processedInstructions
              .removeWhere((element) => element.trim().isEmpty);
        }

        // 2. Ingredients & Fridge Check
        final inventoryProvider =
            Provider.of<InventoryProvider>(context, listen: false);

        final myFridgeItems = inventoryProvider.items
            .map((e) => e.name.toLowerCase().trim())
            .toList();

        if (data['extendedIngredients'] != null) {
          List<dynamic> rawIngs = data['extendedIngredients'];

          _processedIngredients = rawIngs.map((ing) {
            double amount = (ing['amount'] as num?)?.toDouble() ?? 0.0;
            String unit = ing['unit'] ?? "";
            String nameClean = ing['name'] ?? "";
            String original = ing['original'] ?? "$amount $unit $nameClean";

            String ingNameClean = nameClean.toLowerCase();
            bool isInFridge = myFridgeItems.any((myFridgeItem) =>
                ingNameClean.contains(myFridgeItem) ||
                myFridgeItem.contains(ingNameClean));

            return {
              "original": original,
              "name": nameClean,
              "amount": amount,
              "unit": unit,
              "inFridge": isInFridge,
            };
          }).toList();
        }

        // 3. Meta Data
        _readyInMinutes = (data['readyInMinutes'] as num?)?.toInt() ?? 
                          widget.recipe.readyInMinutes ?? 30;
            
        // [FIX] Ép kiểu an toàn cho servings từ API
        int apiServings = (data['servings'] as num?)?.toInt() ?? 
                          widget.recipe.servings ?? 1;
                          
        _originalServings = apiServings;
        _currentServings = apiServings;

        String summaryHtml = data['summary'] ?? "";
        _description = summaryHtml.replaceAll(RegExp(r'<[^>]*>'), '');
        if (_description.length > 150) {
          _description = "${_description.substring(0, 150)}...";
        }

        setState(() => _isLoading = false);
      } else {
        setState(() {
          _errorMessage = "Không tìm thấy chi tiết món ăn này.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi fetch detail: $e");
      setState(() {
        _errorMessage = "Lỗi kết nối hoặc ID món ăn không hợp lệ.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: !_isLoading ? _buildBottomBar() : null,
      body: ResponsiveLayout(
        mobileBody: _buildContent(),
        desktopBody: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        RecipeDetailAppBar(
          imageUrl:
              widget.recipe.imageUrl ?? "https://via.placeholder.com/600x400",
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            transform: Matrix4.translationValues(0, -30, 0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: _buildBodyContent(),
          ),
        )
      ],
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return Column(
        children: [
          const SizedBox(height: 50),
          const CircularProgressIndicator(color: Color(0xFF0FBD3B)),
          const SizedBox(height: 16),
          Text(
            "Đang lấy công thức chuẩn từ Spoonacular...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 200),
        ],
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.broken_image_outlined,
                size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRecipeDetails,
              child: const Text("Thử lại"),
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecipeTitleSection(
          title: widget.recipe.title,
          author: "Source: Spoonacular",
          mainColor: mainColor,
        ),
        if (_description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _description,
            style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.4),
          ),
        ],
        const SizedBox(height: 20),
        
        RecipeTagsSection(
          readyInMinutes: _readyInMinutes,
          servings: _currentServings, 
        ),
        
        const SizedBox(height: 32),
        
        // Truyền state và callback xuống dưới
        IngredientsSection(
          ingredients: _processedIngredients,
          mainColor: mainColor,
          currentServings: _currentServings,
          originalServings: _originalServings,
          onServingsChanged: (newValue) {
            setState(() {
              _currentServings = newValue;
            });
          },
        ),
        
        const SizedBox(height: 32),
        InstructionsSection(
          instructions: _processedInstructions,
          mainColor: mainColor,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: PrimaryButton(
        text: "Lưu công thức",
        icon: Icons.bookmark_border,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chức năng lưu đang phát triển")),
          );
        },
        backgroundColor: mainColor,
      ),
    );
  }
}