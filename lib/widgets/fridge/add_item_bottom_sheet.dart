import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge_to_fork_assistant/screens/fridge/fridge_barcode_scan.dart';
import '../../models/ingredient.dart';
import '../../data/services/firebase_service.dart';
import '../../providers/inventory_provider.dart';
import '../notification.dart';

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
  
  String _selectedUnit = 'kg';
  DateTime? _selectedExpiryDate;
  String _selectedCategory = 'Rau củ';
  bool _isLoading = false;
  
  // Store scanned ingredient data
  Ingredient? _scannedIngredient;

  final List<String> _units = ['cái', 'g', 'kg', 'ml', 'L', 'hộp', 'gói'];
  final List<String> _categories = ['Rau củ', 'Sữa/Trứng', 'Thịt', 'Trái cây', 'Khác'];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _selectExpiryDate() async {
    // Ẩn bàn phím trước khi mở lịch
    FocusScope.of(context).unfocus();
    
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0FBD3B)),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _selectedExpiryDate = date);
    }
  }

  void _addItem() async {
    if (_nameController.text.trim().isEmpty) {
      CustomToast.show(context, 'Vui lòng nhập tên thực phẩm', isError: true);
      return;
    }

    if (_selectedExpiryDate == null) {
      CustomToast.show(context, 'Vui lòng chọn ngày hết hạn', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sử dụng Provider để thêm item (MVVM pattern)
      await context.read<InventoryProvider>().addItem(
        name: _nameController.text.trim(),
        quantity: double.tryParse(_quantityController.text) ?? 1,
        unit: _mapUnitToDB(_selectedUnit), // Convert UI unit to DB unit
        expiryDate: _selectedExpiryDate!,
        category: _selectedCategory,
      );

      if (mounted) {
        // [FIX] Hiển thị toast TRƯỚC khi pop BottomSheet
        // Vì sau khi pop, context của BottomSheet sẽ bị dispose
        CustomToast.show(context, '${_nameController.text} đã được thêm!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Lỗi: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      
      if (ingredient != null && mounted) {
        setState(() {
          _scannedIngredient = ingredient;
          _nameController.text = ingredient.name;
          _selectedUnit = _mapUnitToUI(ingredient.defaultUnit); // Convert DB unit to UI unit
          _selectedCategory = _mapCategoryToUI(ingredient.category);
        });
        
        CustomToast.show(context, 'Đã tìm thấy: ${ingredient.name}');
      } else if (mounted) {
        CustomToast.show(context, 'Không tìm thấy sản phẩm: $barcode', isError: true);
      }
    }
  }

  String _mapCategoryToUI(String category) {
    switch (category.toLowerCase()) {
      case 'vegetable':
        return 'Rau củ';
      case 'dairy':
        return 'Sữa/Trứng';
      case 'meat':
        return 'Thịt';
      case 'fruit':
        return 'Trái cây';
      default:
        return 'Khác';
    }
  }

  // Map đơn vị từ tiếng Anh (DB) sang tiếng Việt (UI)
  String _mapUnitToUI(String unit) {
    switch (unit.toLowerCase()) {
      case 'pcs':
      case 'piece':
      case 'pieces':
        return 'cái';
      case 'g':
      case 'gram':
      case 'grams':
        return 'g';
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return 'kg';
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        return 'ml';
      case 'l':
      case 'liter':
      case 'liters':
        return 'L';
      case 'box':
      case 'boxes':
        return 'hộp';
      case 'pack':
      case 'package':
      case 'packages':
        return 'gói';
      default:
        return 'cái'; // Default fallback
    }
  }

  // Map đơn vị từ tiếng Việt (UI) sang tiếng Anh (DB)
  String _mapUnitToDB(String unit) {
    switch (unit) {
      case 'cái':
        return 'pcs';
      case 'g':
        return 'g';
      case 'kg':
        return 'kg';
      case 'ml':
        return 'ml';
      case 'L':
        return 'L';
      case 'hộp':
        return 'box';
      case 'gói':
        return 'pack';
      default:
        return 'pcs'; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= DRAG HANDLE =================
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ================= HEADER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thêm thực phẩm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= TÊN MÓN =================
                const Text(
                  'Tên nguyên liệu',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên (VD: Sữa tươi, Thịt bò...)',
                    filled: true,
                    fillColor: const Color(0xFFF6F8F6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= SỐ LƯỢNG + HẾT HẠN =================
                Row(
                  children: [
                    // Số lượng
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số lượng',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8F6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _quantityController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: _selectedUnit,
                                  underline: const SizedBox(),
                                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                  onChanged: (val) => setState(() => _selectedUnit = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Ngày hết hạn
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hết hạn',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectExpiryDate,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F8F6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedExpiryDate == null
                                          ? 'Chọn ngày'
                                          : '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}',
                                      style: TextStyle(
                                        color: _selectedExpiryDate == null ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, color: Color(0xFF0FBD3B)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= PHÂN LOẠI (QUICK TAGS) =================
                const Text(
                  'Phân loại',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE6F4EA) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF1B5E20) : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                    // + Add Tag button (chỉ hiển thị, không có chức năng)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+ Thêm tag',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ================= QUÉT MÃ VẠCH =================
                GestureDetector(
                  onTap: _scanBarcode,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF7AD39B),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Color(0xFF1B5E20)),
                        SizedBox(width: 8),
                        Text(
                          'Quét mã vạch',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= NÚT THÊM =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF214130),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      _isLoading ? 'Đang thêm...' : 'Thêm vào Tủ Lạnh',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _isLoading ? null : _addItem,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
