import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:dotted_border/dotted_border.dart'; // Bỏ comment nếu đã cài thư viện này
import '../../providers/inventory_provider.dart';
// import '../../screens/fridge/fridge_barcode_scan.dart'; // Bỏ comment nếu đã có file này

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  
  String _selectedUnit = 'kg'; // Đổi mặc định thành kg cho khớp list
  DateTime? _selectedExpiryDate;
  String _selectedCategory = 'Rau củ';
  bool _isLoading = false;

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
            colorScheme: const ColorScheme.light(primary: Color(0xFF0FBD3B)), // Màu xanh chủ đạo
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _selectedExpiryDate = date);
    }
  }

  // HÀM QUAN TRỌNG: Gọi Provider để đẩy lên Firestore
  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thực phẩm'), backgroundColor: Colors.red),
      );
      return;
    }

    // Ẩn bàn phím ngay lập tức
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      // Gọi hàm addItem trong InventoryProvider
      await Provider.of<InventoryProvider>(context, listen: false).addItem(
        name: name,
        quantity: double.tryParse(_quantityController.text) ?? 1.0,
        unit: _selectedUnit,
        expiryDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.pop(context); // Đóng Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã thêm món mới thành công!'),
            backgroundColor:  Color.fromARGB(255, 36, 75, 45),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bọc trong Dialog để hiển thị giữa màn hình
    return Dialog(
      backgroundColor: Colors.transparent, // Để Container bo góc hiển thị đẹp
      insetPadding: const EdgeInsets.symmetric(horizontal: 20), // Khoảng cách lề
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // Đổi thành bo tròn 4 góc (circular) thay vì chỉ vertical top
          // để phù hợp với giao diện Dialog
          borderRadius: BorderRadius.circular(24), 
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thêm thực phẩm', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))
                  ),
                  IconButton(
                    icon: const Icon(Icons.close), 
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    }
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form Fields
              const Text('Tên món', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Sữa tươi',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Số lượng', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                              child: DropdownButton<String>(
                                value: _selectedUnit,
                                underline: const SizedBox(),
                                items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (val) => setState(() => _selectedUnit = val!),
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
                        const Text('Hết hạn', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectExpiryDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedExpiryDate != null
                                      ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}'
                                      : 'Chọn ngày',
                                  style: TextStyle(color: _selectedExpiryDate != null ? Colors.black : Colors.grey),
                                ),
                                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF0FBD3B)),
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
              
              // Category Chips
              const Text('Phân loại', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color.fromARGB(10, 15, 189, 59) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFF0FBD3B) : Colors.transparent),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF0A8A2B) : const Color(0xFF2D3436),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Scan Barcode Button (Giữ lại UI của bạn)
              /* // Bỏ comment đoạn này nếu bạn đã cài dotted_border và có file scan
              DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                padding: EdgeInsets.zero,
                color: const Color.fromARGB(150, 15, 189, 59),
                strokeWidth: 1.5,
                dashPattern: const <double>[6, 4],
                child: Material(
                  color: const Color.fromARGB(5, 15, 189, 59),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FridgeBarcodeScanScreen()));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.qr_code_scanner, color: Color(0xFF0A8A2B)),
                          SizedBox(width: 8),
                          Text('Quét mã vạch', style: TextStyle(color: Color(0xFF0A8A2B), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              */
              
              // Add Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 75, 45),// Màu xanh chủ đạo
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Thêm vào Tủ Lạnh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
