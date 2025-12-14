import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../widgets/fridge/fridge_item_card.dart';
import '../../widgets/fridge/edit_item_bottom_sheet.dart';
import '../../widgets/fridge/delete_confirmation_modal.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/models/fridge_item.dart';


class FridgeHomeScreen extends StatefulWidget {
  const FridgeHomeScreen({super.key});

  @override
  State<FridgeHomeScreen> createState() => _FridgeHomeScreenState();
}

class _FridgeHomeScreenState extends State<FridgeHomeScreen> {
  bool _isMultiSelectMode = false;
  final Set<String> _selectedItems = {};
  
  // Dữ liệu mẫu
  final List<FridgeItem> _eatMeFirstItems = [
    FridgeItem(
      id: '1',
      name: 'Whole Milk',
      quantity: 1,
      unit: 'pcs',
      category: 'Dairy',
      expiryDays: 1,
      imageUrl: '🥛',
    ),
    FridgeItem(
      id: '2',
      name: 'Baby Spinach',
      quantity: 1,
      unit: 'pcs',
      category: 'Vegetables',
      expiryDays: 3,
      imageUrl: '🌿',
    ),
  ];

  final List<FridgeItem> _inStockItems = [
    FridgeItem(
      id: '3',
      name: 'Avocados',
      quantity: 2,
      unit: 'pcs',
      category: 'Vegetables',
      imageUrl: '🥑',
    ),
    FridgeItem(
      id: '4',
      name: 'Large Eg...',
      quantity: 6,
      unit: 'pcs',
      category: 'Dairy',
      imageUrl: '🥚',
    ),
    FridgeItem(
      id: '5',
      name: 'Cheddar',
      quantity: 1,
      unit: 'block',
      category: 'Dairy',
      imageUrl: '🧀',
    ),
    FridgeItem(
      id: '6',
      name: 'Tomatoes',
      quantity: 500,
      unit: 'g',
      category: 'Vegetables',
      imageUrl: '🍅',
    ),
    FridgeItem(
      id: '7',
      name: 'Strawb...',
      quantity: 1,
      unit: 'pack',
      category: 'Vegetables',
      imageUrl: '🍓',
    ),
    FridgeItem(
      id: '8',
      name: 'Peppers',
      quantity: 3,
      unit: 'pcs',
      category: 'Vegetables',
      imageUrl: '🫑',
    ),
  ];

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedItems.clear();
    });
  }

  void _showEditBottomSheet(FridgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemBottomSheet(
        item: item,
        onSave: (updatedItem) {
          setState(() {
            // Logic cập nhật item vào list
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationModal(
        itemCount: _selectedItems.length,
        onConfirm: () {
          setState(() {
            _eatMeFirstItems.removeWhere((item) => _selectedItems.contains(item.id));
            _inStockItems.removeWhere((item) => _selectedItems.contains(item.id));
            _exitMultiSelectMode();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      desktopBody: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Eat Me First Section - CHỈ hiện khi KHÔNG multi-select
                    if (_eatMeFirstItems.isNotEmpty && !_isMultiSelectMode) ...[
                      _buildSectionHeader('Eat Me First', onSeeAll: () {}),
                      const SizedBox(height: 12),
                      _buildItemGrid(_eatMeFirstItems),
                      const SizedBox(height: 28),
                    ],
                    
                    // In Stock Section - Luôn hiển thị
                    if (!_isMultiSelectMode)
                      _buildSectionHeader('In Stock'),
                    if (!_isMultiSelectMode)
                      const SizedBox(height: 12),
                    _buildItemGrid(_inStockItems),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isMultiSelectMode 
          ? null 
          : FloatingActionButton(
              onPressed: () {
                // Open add item bottom sheet
                _showEditBottomSheet(FridgeItem(
                  id: DateTime.now().toString(),
                  name: '',
                  quantity: 1,
                  unit: 'pcs',
                  category: 'Vegetables',
                  imageUrl: '🥗',
                ));
              },
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF2D5F4F),
              child: const Icon(Icons.add, size: 28, color: Colors.white,),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _isMultiSelectMode
          ? GestureDetector(
              onTap: _selectedItems.isEmpty ? null : _showDeleteConfirmation,
              child: _buildDeleteBottomBar(),
            )
          : _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: const Color(0xFFF8F9FA),
      child: Row(
        mainAxisAlignment: _isMultiSelectMode 
            ? MainAxisAlignment.spaceBetween 
            : MainAxisAlignment.spaceBetween,
        children: [
          if (_isMultiSelectMode)
            TextButton(
              onPressed: _exitMultiSelectMode,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDC3545),
                ),
              ),
            ),         
          
          const Text(
            'My Fridge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          
          if (_isMultiSelectMode)
            TextButton(
              onPressed: () {
                // Save action - có thể là confirm selection hoặc thoát
                _exitMultiSelectMode();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF28A745),
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () {},
                color: const Color(0xFF1A1A1A),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search ingredients...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See all',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemGrid(List<FridgeItem> items) {
    // Trong multi-select mode, merge cả 2 lists
    final displayItems = _isMultiSelectMode 
        ? [..._eatMeFirstItems, ..._inStockItems]
        : items;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return FridgeItemCard(
          item: item,
          isSelected: _selectedItems.contains(item.id),
          isMultiSelectMode: _isMultiSelectMode,
          showAddButton: false,
          onTap: () {
            if (_isMultiSelectMode) {
              _toggleItemSelection(item.id);
            } else {
              _showEditBottomSheet(item);
            }
          },
          onLongPress: () {
            setState(() {
              _isMultiSelectMode = true;
              _selectedItems.add(item.id);
            });
          },
        );
      },
    );
  }

  Widget _buildDeleteBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDC3545),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.kitchen_outlined, 'Fridge', true),
              _buildBottomNavItem(Icons.restaurant_menu_outlined, 'Recipes', false),
              _buildBottomNavItem(Icons.list_alt_outlined, 'Lists', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2D5F4F) : const Color(0xFFB0B0B0),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2D5F4F) : const Color(0xFFB0B0B0),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return _buildMobileLayout();
  }
}