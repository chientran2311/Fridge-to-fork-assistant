import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
import '../../widgets/fridge/fridge_item_card.dart';
import '../../widgets/fridge/fridge_header.dart';
import '../../widgets/fridge/fridge_search_bar.dart';
import '../../widgets/fridge/fridge_section_header.dart';
import '../../widgets/fridge/fridge_bottom_navigation.dart';
import '../../widgets/fridge/fridge_delete_bar.dart';
import '../../widgets/fridge/edit_item_bottom_sheet.dart';
import '../../widgets/fridge/add_item_bottom_sheet.dart';
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
  int _currentNavIndex = 0;
  
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

  // ==================== MULTI-SELECT METHODS ====================
  
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

  void _enterMultiSelectMode(String itemId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedItems.add(itemId);
    });
  }

  // ==================== ITEM CRUD METHODS ====================
  
  void _addItem(FridgeItem newItem) {
    setState(() {
      if (newItem.expiryDays != null && newItem.expiryDays! <= 3) {
        _eatMeFirstItems.add(newItem);
      } else {
        _inStockItems.add(newItem);
      }
    });
    _showSuccessSnackbar('Item added successfully');
  }

  void _updateItem(FridgeItem updatedItem) {
    setState(() {
      final eatMeIndex = _eatMeFirstItems.indexWhere((i) => i.id == updatedItem.id);
      final inStockIndex = _inStockItems.indexWhere((i) => i.id == updatedItem.id);
      
      if (eatMeIndex != -1) {
        _eatMeFirstItems[eatMeIndex] = updatedItem;
      } else if (inStockIndex != -1) {
        _inStockItems[inStockIndex] = updatedItem;
      }
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      _eatMeFirstItems.removeWhere((item) => _selectedItems.contains(item.id));
      _inStockItems.removeWhere((item) => _selectedItems.contains(item.id));
      _exitMultiSelectMode();
    });
  }

  // ==================== BOTTOM SHEETS & MODALS ====================
  
  void _showAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemBottomSheet(
        onAdd: _addItem,
      ),
    );
  }

  void _showEditBottomSheet(FridgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemBottomSheet(
        item: item,
        onSave: _updateItem,
      ),
    );
  }

  void _showDeleteConfirmation() {
    if (_selectedItems.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationModal(
        itemCount: _selectedItems.length,
        onConfirm: () {
          _deleteSelectedItems();
          Navigator.pop(context);
        },
      ),
    );
  }

  // ==================== UI HELPERS ====================
  
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF28A745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onItemTap(FridgeItem item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item.id);
    } else {
      _showEditBottomSheet(item);
    }
  }

  void _onItemLongPress(FridgeItem item) {
    if (!_isMultiSelectMode) {
      _enterMultiSelectMode(item.id);
    }
  }

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      desktopBody: _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            FridgeHeader(
              isMultiSelectMode: _isMultiSelectMode,
              onCancel: _exitMultiSelectMode,
              onSave: _exitMultiSelectMode,
              onSettings: () {
                // TODO: Navigate to settings
              },
            ),
            
            const FridgeSearchBar(),
            
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: _isMultiSelectMode 
          ? null 
          : FloatingActionButton(
              onPressed: _showAddItemBottomSheet,
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF2D5F4F),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _isMultiSelectMode
          ? FridgeDeleteBar(
              onDelete: _showDeleteConfirmation,
              isEnabled: _selectedItems.isNotEmpty,
            )
          : FridgeBottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
                // TODO: Handle navigation
              },
            ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Eat Me First Section - Horizontal Scroll
          if (_eatMeFirstItems.isNotEmpty && !_isMultiSelectMode) ...[
            const FridgeSectionHeader(title: 'Eat Me First'),
            const SizedBox(height: 12),
            _buildEatMeFirstSection(),
            const SizedBox(height: 28),
          ],
          
          // In Stock Section - Grid
          if (!_isMultiSelectMode) ...[
            const FridgeSectionHeader(title: 'In Stock'),
            const SizedBox(height: 12),
          ],
          _buildInStockGrid(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEatMeFirstSection() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _eatMeFirstItems.length,
        itemBuilder: (context, index) {
          final item = _eatMeFirstItems[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(
              right: index < _eatMeFirstItems.length - 1 ? 12 : 0,
            ),
            child: FridgeItemCard(
              item: item,
              isSelected: _selectedItems.contains(item.id),
              isMultiSelectMode: _isMultiSelectMode,
              showAddButton: false,
              onTap: () => _onItemTap(item),
              onLongPress: () => _onItemLongPress(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInStockGrid() {
    final displayItems = _isMultiSelectMode 
        ? [..._eatMeFirstItems, ..._inStockItems]
        : _inStockItems;
    
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
          onTap: () => _onItemTap(item),
          onLongPress: () => _onItemLongPress(item),
        );
      },
    );
  }
}