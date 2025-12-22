import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/models/fridge_item.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_barcode_scan.dart';

class EditItemBottomSheet extends StatefulWidget {
  final FridgeItem item;
  final Function(FridgeItem) onSave;

  const EditItemBottomSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditItemBottomSheet> createState() => _EditItemBottomSheetState();
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  String _selectedUnit = 'pcs';
  DateTime? _selectedExpiryDate;
  String _selectedCategory = 'Vegetables';

  final List<String> _units = ['pcs', 'g', 'kg', 'ml', 'L', 'pack', 'block'];
  final List<String> _categories = [
    'Vegetables',
    'Dairy',
    'Meat',
    'Fruit',
    '+ Add Tag'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _selectedUnit = widget.item.unit;
    _selectedCategory = widget.item.category;
    _selectedExpiryDate = widget.item.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
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

  void _save() {
    final updatedItem = widget.item.copyWith(
      name: _nameController.text,
      quantity: int.tryParse(_quantityController.text) ?? widget.item.quantity,
      unit: _selectedUnit,
      category: _selectedCategory,
      expiryDate: _selectedExpiryDate,
    );

    widget.onSave(updatedItem);
    Navigator.pop(context);
    showSuccessSnackbar();
  }

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Item added successfully!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
                    'Edit Item',
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                              color: isSelected
                                  ? const Color(0xFF0A8A2B)
                                  : const Color(0xFF2D3436),
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
                  // DottedBorder(
                  //   borderType: BorderType.RRect,
                  //   radius: const Radius.circular(12), // Bo góc giống code cũ
                  //   padding: EdgeInsets.zero, // Quan trọng để inkwell tràn viền
                  //   color: const Color.fromARGB(150, 15, 189,
                  //       59), // Màu viền (đậm hơn chút cho rõ nét đứt)
                  //   strokeWidth: 1.5, // Độ dày nét đứt
                  //   dashPattern: const [6, 4], // [độ dài nét, khoảng cách]
                  //   child: Material(
                  //     color: const Color.fromARGB(
                  //         5, 15, 189, 59), // Màu nền (backgroundColor cũ)
                  //     borderRadius: BorderRadius.circular(12),
                  //     child: InkWell(
                  //       onTap: () {
                  //         Navigator.pushReplacement(context,
                  //             MaterialPageRoute(builder: (context) {
                  //           return const FridgeBarcodeScanScreen();
                  //         }));
                  //       },
                  //       borderRadius: BorderRadius.circular(12),
                  //       child: Container(
                  //         width:
                  //             double.infinity, // minimumSize: width infinity cũ
                  //         padding: const EdgeInsets.symmetric(
                  //             vertical: 14), // padding cũ
                  //         alignment: Alignment.center,
                  //         child: Row(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: const [
                  //             Icon(
                  //               Icons.qr_code_scanner,
                  //               color: Color(0xFF0A8A2B), // foregroundColor cũ
                  //             ),
                  //             SizedBox(
                  //                 width: 8), // Khoảng cách giữa icon và text
                  //             Text(
                  //               'Scan Barcode',
                  //               style: TextStyle(
                  //                 color:
                  //                     Color(0xFF0A8A2B), // foregroundColor cũ
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 12),

                  // Add to Fridge Button
                  ElevatedButton(
                    onPressed: _save,
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

