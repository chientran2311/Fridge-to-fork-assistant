import 'package:flutter/material.dart';


class AddItemBottomSheet extends StatefulWidget {
  const AddItemBottomSheet({super.key});

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final TextEditingController nameController = TextEditingController();

  int quantity = 1;
  String unit = "pcs";
  DateTime? expiryDate;
  String selectedTag = "Vegetables";

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (date != null) {
      setState(() => expiryDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
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
                    "Add New Item",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= INGREDIENT NAME =================
              const Text(
                "Ingredient Name",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText:
                      "Enter ingredient name (e.g. Homemade Pesto)",
                  filled: true,
                  fillColor: const Color(0xFFF6F8F6),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= QUANTITY + EXPIRY =================
              Row(
                children: [
                  // Quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8F6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "$quantity",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              DropdownButton<String>(
                                value: unit,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                      value: "pcs", child: Text("pcs")),
                                  DropdownMenuItem(
                                      value: "kg", child: Text("kg")),
                                  DropdownMenuItem(
                                      value: "g", child: Text("g")),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => unit = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Expiry date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Expiry Date",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8F6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  expiryDate == null
                                      ? "Select Date"
                                      : "${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}",
                                  style: TextStyle(
                                    color: expiryDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.calendar_today,
                                    color: Colors.green),
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

              // ================= QUICK TAGS =================
              const Text(
                "Quick Tags",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagChip(
                    text: "Vegetables",
                    active: selectedTag == "Vegetables",
                    onTap: () =>
                        setState(() => selectedTag = "Vegetables"),
                  ),
                  _TagChip(
                    text: "Dairy",
                    active: selectedTag == "Dairy",
                    onTap: () =>
                        setState(() => selectedTag = "Dairy"),
                  ),
                  _TagChip(
                    text: "Meat",
                    active: selectedTag == "Meat",
                    onTap: () =>
                        setState(() => selectedTag = "Meat"),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("+ Add Tag"),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ================= SCAN BARCODE =================
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF7AD39B),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.qr_code_scanner,
                        color: Color(0xFF1B5E20)),
                    SizedBox(width: 8),
                    Text(
                      "Scan Barcode",
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================= ADD BUTTON =================
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
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Add to shopping list",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= TAG CHIP =================

class _TagChip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TagChip({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              active ? const Color(0xFFE6F4EA) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? const Color(0xFF1B5E20) : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
