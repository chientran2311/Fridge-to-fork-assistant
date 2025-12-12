import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Đảm bảo bạn đã có package này

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  // Màu sắc chủ đạo lấy từ ảnh
  final Color darkGreen = const Color(0xFF1B3B36);
  final Color bgLight = const Color(0xFFF2F4F3); // Màu nền trắng xám nhẹ

  @override
  Widget build(BuildContext context) {
    // Sử dụng Align để đẩy Dialog sang sát bên phải
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          // Kích thước modal: Chiếm 85% chiều rộng màn hình hoặc max 320px
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.only(right: 16), // Cách lề phải một chút cho đẹp
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(-4, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Co giãn theo nội dung
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Cooking Time ---
              _buildTitle("Cooking time"),
              const SizedBox(height: 8),
              _buildTextField(hint: "", suffix: "min"),

              const SizedBox(height: 20),

              // --- 2. Country Food ---
              _buildTitle("Country food"),
              const SizedBox(height: 8),
              _buildTextField(hint: "Vietnam, Korea,..."),

              const SizedBox(height: 20),

              // --- 3. Level ---
              _buildTitle("Level"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildOptionBtn("Easy"),
                  _buildOptionBtn("Medium"),
                  _buildOptionBtn("Hard"),
                ],
              ),

              const SizedBox(height: 20),

              // --- 4. Meals ---
              _buildTitle("Meals"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildOptionBtn("Breakfast"),
                  _buildOptionBtn("Lunch"),
                  _buildOptionBtn("Dinner"),
                  _buildOptionBtn("Snack"),
                ],
              ),

              const SizedBox(height: 32),

              // --- 5. Footer Buttons ---
              Row(
                children: [
                  // Nút Reset
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                         // Logic Reset sau này
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: darkGreen, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Reset",
                        style: GoogleFonts.merriweather(
                          color: darkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nút Save
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic Save sau này
                        Navigator.pop(context); // Đóng modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.merriweather(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Con: Tiêu đề ---
  Widget _buildTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.w900, // Đậm như ảnh mẫu
        color: darkGreen,
      ),
    );
  }

  // --- Widget Con: Ô nhập liệu ---
  Widget _buildTextField({required String hint, String? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          suffixText: suffix,
          suffixStyle: TextStyle(
              color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: darkGreen, width: 2), // Viền đậm
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: darkGreen, width: 2.5),
          ),
        ),
      ),
    );
  }

  // --- Widget Con: Nút chọn (Easy, Medium...) ---
  Widget _buildOptionBtn(String text) {
    return InkWell(
      onTap: () {
        // Logic chọn sau này
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: darkGreen, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent, // Chưa chọn thì nền trong suốt
        ),
        child: Text(
          text,
          style: GoogleFonts.merriweather(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
      ),
    );
  }
}