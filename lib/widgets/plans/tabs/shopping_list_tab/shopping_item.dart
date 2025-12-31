import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditableShoppingItem extends StatefulWidget {
  final String itemId;
  final String title;
  final String category;
  final int quantity;
  final String unit;
  final bool isChecked;
  final VoidCallback onDelete;
  final Function(bool) onToggleCheck;
  final Function(int) onQuantityChange;
  final String householdId;

  const EditableShoppingItem({
    required this.itemId,
    required this.title,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.isChecked,
    required this.onDelete,
    required this.onToggleCheck,
    required this.onQuantityChange,
    required this.householdId,
  });

  @override
  State<EditableShoppingItem> createState() => EditableShoppingItemState();
}

class EditableShoppingItemState extends State<EditableShoppingItem> {
  late bool isEditing;
  late int quantity;
  late String itemName;
  late String selectedUnit;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  List<String> availableUnits = [];

  @override
  void initState() {
    super.initState();
    isEditing = false;
    quantity = widget.quantity;
    itemName = widget.title;
    selectedUnit = widget.unit;
    _nameController = TextEditingController(text: itemName);
    _quantityController = TextEditingController(text: quantity.toString());
    _loadUnits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    try {
      final unitsSnapshot = await _firestore.collection('units').get();
      final units = unitsSnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() => availableUnits = units);
    } catch (e) {
      debugPrint('Error loading units: $e');
      // Fallback units
      setState(() => availableUnits = ['g', 'kg', 'ml', 'l', 'pcs', 'cup', 'tbsp']);
    }
  }

  Future<void> _updateQuantity(int newQuantity) async {
    // ✅ Chỉ update local state, không ghi lên Firebase
    setState(() => quantity = newQuantity);
    _quantityController.text = quantity.toString();
    widget.onQuantityChange(newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() => isEditing = true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isEditing
              ? Border.all(
                  color: const Color(0xFF214130),
                  width: 2.5,
                )
              : null,
        ),
        child: isEditing ? _editMode() : _viewMode(),
      ),
    );
  }

  Widget _viewMode() {
    return Row(
      children: [
        Checkbox(
          value: widget.isChecked,
          onChanged: (newValue) {
            if (newValue != null) {
              widget.onToggleCheck(newValue);
            }
          },
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: widget.isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${widget.category} • ${widget.quantity}${widget.unit}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== HEADER =====
        Row(
          children: [
            const Icon(Icons.edit, size: 18, color: Color(0xFF214130)),
            const SizedBox(width: 6),
            const Text("Edit Item", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Item?"),
                    content: Text("Remove '${widget.title}' from shopping list?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete();
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ===== ITEM NAME EDIT =====
        const Text("Item Name", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter item name",
            filled: true,
            fillColor: const Color(0xFFF6F8F6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() => itemName = value),
        ),
        const SizedBox(height: 16),

        // ===== QUANTITY & UNIT =====
        Row(
          children: [
            // Quantity Input
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Quantity", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Decrease Button
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) {
                            _updateQuantity(quantity - 1);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove, size: 16, color: Color(0xFF214130)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Number Input
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF6F8F6),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            final newQty = int.tryParse(value) ?? quantity;
                            if (newQty > 0) {
                              _updateQuantity(newQty);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Increase Button
                      GestureDetector(
                        onTap: () => _updateQuantity(quantity + 1),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF214130),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Unit Dropdown
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Unit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: availableUnits.contains(selectedUnit) ? selectedUnit : (availableUnits.isNotEmpty ? availableUnits[0] : selectedUnit),
                        items: availableUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (newUnit) {
                          if (newUnit != null) {
                            setState(() => selectedUnit = newUnit);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ===== CATEGORY DISPLAY =====
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF214130).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Category: ${widget.category.toUpperCase()}",
            style: const TextStyle(fontSize: 12, color: Color(0xFF214130), fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),

        // ===== ACTION BUTTONS =====
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                // Reset to original values
                _nameController.text = widget.title;
                _quantityController.text = widget.quantity.toString();
                setState(() {
                  itemName = widget.title;
                  quantity = widget.quantity;
                  selectedUnit = widget.unit;
                  isEditing = false;
                });
              },
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Update state with new values
                widget.onQuantityChange(quantity);
                setState(() => isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Updated: $itemName ($quantity$selectedUnit)"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF214130),
              ),
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}