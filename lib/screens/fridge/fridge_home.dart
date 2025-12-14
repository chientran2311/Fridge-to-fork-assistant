import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

class FridgeHomeScreen extends StatefulWidget {
  const FridgeHomeScreen({super.key});

  @override
  State<FridgeHomeScreen> createState() => _FridgeHomeScreenState();
}

class _FridgeHomeScreenState extends State<FridgeHomeScreen> {
  // Màu sắc chủ đạo lấy từ ảnh thiết kế
  final Color bgCream = const Color(0xFFF9F9F7);
  final Color darkGreen = const Color(0xFF1B3B36);
  final Color badgeRed = const Color(0xFFFF8A80);
  final Color badgeOrange = const Color(0xFFFFCC80);

  // Dữ liệu mẫu (Giả lập DB)
  final List<Map<String, dynamic>> eatMeFirstItems = [
    {
      "image": "https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=300&q=80", // Milk
      "title": "Whole Milk",
      "subtitle": "Expiring soon",
      "tag": "1 DAY",
      "tagColor": const Color(0xFFFFEBEE),
      "tagTextColor": Colors.red,
    },
    {
      "image": "https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80", // Spinach
      "title": "Baby Spinach",
      "subtitle": "Plan a meal",
      "tag": "2 DAYS",
      "tagColor": const Color(0xFFFFF3E0),
      "tagTextColor": Colors.orange,
    },
    {
       "image": "https://images.unsplash.com/photo-1587049359535-b64d3d865c49?auto=format&fit=crop&w=300&q=80", // Yogurt
      "title": "Greek Yogurt",
      "subtitle": "Expiring soon",
      "tag": "3 DAYS",
      "tagColor": const Color(0xFFFFF3E0),
      "tagTextColor": Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> inStockItems = [
    {
      "image": "https://images.unsplash.com/photo-1523049673856-388668a7550d?auto=format&fit=crop&w=300&q=80", // Avocado
      "title": "Avocados",
      "qty": "2 pcs",
    },
    {
      "image": "https://images.unsplash.com/photo-1506976785307-8732e854ad03?auto=format&fit=crop&w=300&q=80", // Eggs
      "title": "Large Eggs",
      "qty": "6 pcs",
    },
    {
      "image": "https://images.unsplash.com/photo-1618164436241-4473940d1f5c?auto=format&fit=crop&w=300&q=80", // Cheddar
      "title": "Cheddar",
      "qty": "1 block",
    },
    {
      "image": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80", // Tomatoes
      "title": "Tomatoes",
      "qty": "500g",
    },
    {
      "image": "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=300&q=80", // Strawberries
      "title": "Strawberries",
      "qty": "1 pack",
    },
    {
      "image": "https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80", // Peppers
      "title": "Peppers",
      "qty": "3 pcs",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      
      // Floating Action Button (Nút dấu cộng xanh)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: darkGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: SafeArea(
        bottom: false,
        child: ResponsiveLayout(
          // --- MOBILE BODY ---
          mobileBody: _buildBodyContent(crossAxisCount: 2, isMobile: true),
          
          // --- DESKTOP BODY ---
          desktopBody: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              // Trên desktop tăng số cột lên 4 để đẹp hơn
              child: _buildBodyContent(crossAxisCount: 4, isMobile: false),
            ),
          ),
        ),
      ),
    );
  }

  // Widget chứa toàn bộ nội dung chính (Header, Search, Lists)
  Widget _buildBodyContent({required int crossAxisCount, required bool isMobile}) {
    return CustomScrollView(
      slivers: [
        // 1. Header & Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Fridge",
                      style: GoogleFonts.merriweather(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: darkGreen,
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        color: Colors.black,
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search ingredients...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Section "Eat Me First"
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Eat Me First",
                      style: GoogleFonts.merriweather(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Horizontal Scroll List
              SizedBox(
                height: 220, // Chiều cao cố định cho list ngang
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: eatMeFirstItems.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = eatMeFirstItems[index];
                    return _buildUrgentCard(item);
                  },
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),

        // 3. Section "In Stock" Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "In Stock",
              style: GoogleFonts.merriweather(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // 4. Grid "In Stock" Items
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Responsive số cột
              childAspectRatio: 0.85, // Tỷ lệ khung hình
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = inStockItems[index];
                return _buildStockCard(item);
              },
              childCount: inStockItems.length,
            ),
          ),
        ),
        
        // Khoảng trống dưới cùng để không bị che bởi BottomNav hoặc FAB
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // --- Widget Card: Eat Me First ---
  Widget _buildUrgentCard(Map<String, dynamic> item) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Badge
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['tag'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          // Texts
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: item['tagTextColor'], // Màu chữ cảnh báo
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Widget Card: In Stock ---
  Widget _buildStockCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Image Section (chiếm phần lớn)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  item['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Text Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['qty'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}