import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_barcode_scan.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../models/ingredient.dart';
import '../../services/firebase_service.dart';


class AddItemBottomSheet extends StatefulWidget {
  const AddItemBottomSheet({
    super.key,
  });

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final FirebaseService _firebaseService = FirebaseService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  String _selectedUnit = 'pcs';
  DateTime? _selectedExpiryDate;
  String _selectedCategory = 'Vegetables';
  
  // Store scanned ingredient data
  Ingredient? _scannedIngredient;

  final List<String> _units = ['pcs', 'g', 'kg', 'ml', 'L', 'pack', 'block'];
  final List<String> _categories = ['Vegetables', 'Dairy', 'Meat', 'Fruit', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D5F4F),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() {
        _selectedExpiryDate = date;
      });
    }
  }

  void _addItem() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter ingredient name'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    bool success;

    // If we have scanned ingredient, add with ingredient reference
    if (_scannedIngredient != null) {
      success = await _firebaseService.addInventoryWithIngredient(
        ingredientId: _scannedIngredient!.ingredientId,
        quantity: double.tryParse(_quantityController.text) ?? 1,
        unit: _selectedUnit,
        expiryDate: _selectedExpiryDate,
      );
    } else {
      // Manual entry - add directly to inventory without touching ingredients table
      success = await _firebaseService.addInventoryManual(
        name: _nameController.text.trim(),
        category: _mapCategoryToDatabase(_selectedCategory),
        quantity: double.tryParse(_quantityController.text) ?? 1,
        unit: _selectedUnit,
        expiryDate: _selectedExpiryDate,
      );
    }

    // Hide loading
    if (mounted) Navigator.pop(context);
    
    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} added successfully!'),
            backgroundColor: const Color(0xFF28A745),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item'),
            backgroundColor: Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  void _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const FridgeBarcodeScanScreen(),
      ),
    );
    
    if (barcode != null) {
      // Fetch ingredient from Firebase
      final ingredient = await _firebaseService.getIngredientByBarcode(barcode);
      
      if (ingredient != null) {
        setState(() {
          _scannedIngredient = ingredient;
          _nameController.text = ingredient.name;
          _selectedUnit = ingredient.defaultUnit;
          _selectedCategory = _mapCategoryToUI(ingredient.category);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found: ${ingredient.name}'),
            backgroundColor: const Color(0xFF28A745),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode not found: $barcode'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  String _mapCategoryToUI(String category) {
    switch (category.toLowerCase()) {
      case 'vegetable':
        return 'Vegetables';
      case 'dairy':
        return 'Dairy';
      case 'meat':
        return 'Meat';
      case 'fruit':
        return 'Fruit';
      default:
        return 'Other';
    }
  }

  String _mapCategoryToDatabase(String uiCategory) {
    switch (uiCategory.toLowerCase()) {
      case 'vegetables':
        return 'vegetable';
      case 'dairy':
        return 'dairy';
      case 'meat':
        return 'meat';
      case 'fruit':
        return 'fruit';
      default:
        return 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: const Color(0xFF2D3436),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Form Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredient Name
                  const Text(
                    'Ingredient Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter ingredient name (e.g. Homemade Milk)',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quantity and Expiry Date Row
                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _quantityController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '1',
                                      filled: true,
                                      fillColor: const Color(0xFFF5F5F5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedUnit,
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: _units.map((String unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(unit),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedUnit = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Expiry Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expiry Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectExpiryDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedExpiryDate != null
                                          ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}'
                                          : 'Select Date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _selectedExpiryDate != null
                                            ? const Color(0xFF2D3436)
                                            : Colors.grey[400],
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: const Color(0xFF0FBD3B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Tags
                  const Text(
                    'Quick Tags',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color.fromARGB(10, 15, 189, 59) 
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color.fromARGB(20, 15, 189, 59)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0A8A2B): const Color(0xFF2D3436),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Scan Barcode Button
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12), // Bo góc giống code cũ
                    padding: EdgeInsets.zero, // Quan trọng để inkwell tràn viền
                    color: const Color.fromARGB(150, 15, 189,
                        59), // Màu viền (đậm hơn chút cho rõ nét đứt)
                    strokeWidth: 1.5, // Độ dày nét đứt
                    dashPattern: const [6, 4], // [độ dài nét, khoảng cách]
                    child: Material(
                      color: const Color.fromARGB(
                          5, 15, 189, 59), // Màu nền (backgroundColor cũ)
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _scanBarcode,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width:
                              double.infinity, // minimumSize: width infinity cũ
                          padding: const EdgeInsets.symmetric(
                              vertical: 14), // padding cũ
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Color(0xFF0A8A2B), // foregroundColor cũ
                              ),
                              SizedBox(
                                  width: 8), // Khoảng cách giữa icon và text
                              Text(
                                'Scan Barcode',
                                style: TextStyle(
                                  color:
                                      Color(0xFF0A8A2B), // foregroundColor cũ
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Add to Fridge Button
                  ElevatedButton(
                    onPressed: _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5F4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 52),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text(
                          'Add to Fridge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}