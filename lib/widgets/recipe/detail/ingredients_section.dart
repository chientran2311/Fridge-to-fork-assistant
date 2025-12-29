import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IngredientsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final Color mainColor;
  
  // Nhận dữ liệu từ cha
  final int currentServings;
  final int originalServings;
  final Function(int) onServingsChanged;

  const IngredientsSection({
    super.key,
    required this.ingredients,
    required this.mainColor,
    required this.currentServings,
    required this.originalServings,
    required this.onServingsChanged,
  });

  @override
  State<IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection> {
  late List<bool> _ingredientChecks;

  @override
  void initState() {
    super.initState();
    _initChecks();
  }

  // Cập nhật lại checkbox khi danh sách nguyên liệu thay đổi
  @override
  void didUpdateWidget(covariant IngredientsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ingredients != oldWidget.ingredients) {
      _initChecks();
    }
  }

  void _initChecks() {
    _ingredientChecks = widget.ingredients.map((ing) {
      return ing['inFridge'] == true;
    }).toList();
  }

  // [HÀM TÍNH TOÁN MỚI - KHÔNG LÀM TRÒN]
  String _calculateAmount(double baseAmount, String unit, String name) {
    if (baseAmount == 0) return "$unit $name";

    // 1. Tính toán tỉ lệ chính xác
    double baseServing = widget.originalServings > 0 ? widget.originalServings.toDouble() : 1.0;
    double calculated = (baseAmount / baseServing) * widget.currentServings;

    // 2. Định dạng hiển thị (Format String)
    // Sử dụng toStringAsFixed(2) để giới hạn tối đa 2 số thập phân cho gọn
    // Sau đó dùng RegExp để xóa các số 0 vô nghĩa ở cuối
    
    // Ví dụ:
    // 5.00 -> "5"
    // 1.50 -> "1.5"
    // 0.25 -> "0.25"
    String amountStr = calculated.toStringAsFixed(2);
    
    // Regex: Tìm dấu chấm và các số 0 ở cuối chuỗi, rồi xóa đi
    amountStr = amountStr.replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");

    return "$amountStr $unit $name";
  }

  void _showEditServingsDialog() {
    TextEditingController controller = TextEditingController(text: widget.currentServings.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Nhập số khẩu phần"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Ví dụ: 4",
            border: OutlineInputBorder(),
            suffixText: "Người",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.mainColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              int? newVal = int.tryParse(controller.text);
              if (newVal != null && newVal > 0) {
                widget.onServingsChanged(newVal); 
                Navigator.pop(context);
              }
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ingredients",
              style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.mainColor),
            ),
            _ServingCounter(
              servings: widget.currentServings,
              onRemove: () {
                if (widget.currentServings > 1) {
                  widget.onServingsChanged(widget.currentServings - 1);
                }
              },
              onAdd: () {
                widget.onServingsChanged(widget.currentServings + 1);
              },
              onEdit: _showEditServingsDialog,
            )
          ],
        ),
        const SizedBox(height: 16),
        
        ...List.generate(widget.ingredients.length, (index) {
          final item = widget.ingredients[index];
          final bool isInFridge = item['inFridge'] == true;
          
          // Gọi hàm tính toán mới
          String displayText = _calculateAmount(
            item['amount'], 
            item['unit'], 
            item['name']
          );

          if (displayText.isNotEmpty) {
            displayText = displayText[0].toUpperCase() + displayText.substring(1);
          }

          bool isChecked = false;
          if (index < _ingredientChecks.length) {
            isChecked = _ingredientChecks[index];
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isInFridge ? Colors.green.withOpacity(0.3) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              color: isInFridge ? Colors.green.withOpacity(0.02) : Colors.white,
            ),
            child: CheckboxListTile(
              activeColor: widget.mainColor,
              checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              title: Text(
                displayText, 
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.grey,
                ),
              ),
              secondary: isInFridge
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.kitchen, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text("In Fridge",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : null,
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (index < _ingredientChecks.length) {
                    _ingredientChecks[index] = val!;
                  }
                });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
      ],
    );
  }
}

class _ServingCounter extends StatelessWidget {
  final int servings;
  final VoidCallback onRemove;
  final VoidCallback onAdd;
  final VoidCallback onEdit;

  const _ServingCounter(
      {required this.servings, 
       required this.onRemove, 
       required this.onAdd,
       required this.onEdit});

  Widget _buildServingBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _buildServingBtn(Icons.remove, onRemove),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              constraints: const BoxConstraints(minWidth: 80), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$servings Servings",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit, size: 12, color: Colors.grey[500]),
                ],
              ),
            ),
          ),
          _buildServingBtn(Icons.add, onAdd),
        ],
      ),
    );
  }
}