import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> recipes;
  final Function(DateTime date, String recipeId, String mealType, int servings)
      onAddMealPlan;

  const AddRecipeScreen({
    super.key,
    required this.selectedDate,
    required this.recipes,
    required this.onAddMealPlan,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm công thức vào kế hoạch',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text('Add Recipe to Calendar'),
      ),
    );
  }
}
      body: const Center(
        child: Text('Add Recipe to Calendar'),
      ),
    );
  }
}
