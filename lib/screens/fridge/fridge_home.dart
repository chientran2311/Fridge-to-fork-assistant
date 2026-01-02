import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';
// Import các widget con
import '../../widgets/fridge/fridge_item_card.dart';
import '../../widgets/fridge/fridge_header.dart';
import '../../widgets/fridge/fridge_search_bar.dart';
import '../../widgets/fridge/fridge_section_header.dart';
import '../../widgets/fridge/fridge_delete_bar.dart';
import '../../widgets/fridge/edit_item_bottom_sheet.dart';
import '../../widgets/fridge/add_item_bottom_sheet.dart';
import '../../widgets/fridge/delete_confirmation_modal.dart';
import 'package:fridge_to_fork_assistant/screens/settings/settings.dart';
import 'package:fridge_to_fork_assistant/widgets/fridge/models/fridge_item.dart';
import '../../models/inventory_item.dart';
import '../../services/firebase_service.dart';

// LƯU Ý: Không cần import 'bottom_nav.dart' ở đây nữa vì MainScreen đã lo việc đó.

class FridgeHomeScreen extends StatefulWidget {
  const FridgeHomeScreen({super.key});

  @override
  State<FridgeHomeScreen> createState() => _FridgeHomeScreenState();
}

class _FridgeHomeScreenState extends State<FridgeHomeScreen> {
  bool _isMultiSelectMode = false;
  final Set<String> _selectedItems = {};
  final FirebaseService _firebaseService = FirebaseService();
  
  List<FridgeItem> _eatMeFirstItems = [];
  List<FridgeItem> _inStockItems = [];
  bool _isLoading = true;
  StreamSubscription<List<InventoryItem>>? _inventorySubscription;
  bool _hasShownError = false; // Để chỉ hiện error 1 lần

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }

  void _loadInventoryData() {
    // Cancel old subscription if exists
    _inventorySubscription?.cancel();
    _hasShownError = false; // Reset error flag
    
    setState(() => _isLoading = true);
    
    _inventorySubscription = _firebaseService.getInventoryStream().listen((inventoryItems) {
      if (!mounted) return;
      
      setState(() {
        _eatMeFirstItems = [];
        _inStockItems = [];
        
        for (final item in inventoryItems) {
          final fridgeItem = _convertToFridgeItem(item);
          if (item.isExpiringSoon) {
            _eatMeFirstItems.add(fridgeItem);
          } else {
            _inStockItems.add(fridgeItem);
          }
        }
        
        _isLoading = false;
      });
    }, onError: (error) {
      debugPrint('❌ Error loading inventory: $error');
      if (!mounted || _hasShownError) return;
      
      _hasShownError = true; // Chỉ hiện 1 lần
      setState(() => _isLoading = false);
      
      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cloud_off, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Connection error. Please check your internet and try again.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC3545),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadInventoryData,
          ),
        ),
      );
    });
  }

  FridgeItem _convertToFridgeItem(InventoryItem inventoryItem) {
    return FridgeItem(
      id: inventoryItem.inventoryId,
      name: inventoryItem.ingredientName ?? 'Unknown',
      quantity: inventoryItem.quantity.toInt(),
      unit: inventoryItem.unit,
      category: inventoryItem.ingredientCategory ?? 'Other',
      imageUrl: inventoryItem.getCategoryEmoji(),
      expiryDays: inventoryItem.expiryDays,
      expiryDate: inventoryItem.expiryDate,
      ingredientId: inventoryItem.ingredientId,
    );
  }

  // ==================== MULTI-SELECT METHODS (Giữ nguyên) ====================
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
  void _updateItem(FridgeItem updatedItem) async {
    setState(() => _isLoading = true);
    
    // For manual entries (empty ingredientId), also update name and category
    final isManualEntry = updatedItem.ingredientId == null || updatedItem.ingredientId!.isEmpty;
    
    final success = await _firebaseService.updateInventoryItem(
      inventoryId: updatedItem.id,
      quantity: updatedItem.quantity.toDouble(),
      unit: updatedItem.unit,
      expiryDate: updatedItem.expiryDate,
      name: isManualEntry ? updatedItem.name : null,
      category: isManualEntry ? updatedItem.category : null,
    );
    
    setState(() => _isLoading = false);
    
    if (success) {
      _showSuccessSnackbar('Item updated successfully');
    } else {
      _showErrorSnackbar('Could not update item. Check your internet connection.');
    }
  }

  void _deleteSelectedItems() async {
    final itemCount = _selectedItems.length;
    setState(() => _isLoading = true);
    
    final success = await _firebaseService.deleteInventoryItems(
      inventoryIds: _selectedItems.toList(),
    );
    
    setState(() => _isLoading = false);
    _exitMultiSelectMode();
    
    if (success) {
      _showSuccessSnackbar('$itemCount ${itemCount == 1 ? "item" : "items"} deleted');
    } else {
      _showErrorSnackbar('Could not delete items. Check your internet connection.');
    }
  }

  // ==================== BOTTOM SHEETS & MODALS (Giữ nguyên) ====================
  void _showAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddItemBottomSheet(),
    );
  }

  void _showEditBottomSheet(FridgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemBottomSheet(item: item, onSave: _updateItem),
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

  // ==================== UI HELPERS (Giữ nguyên) ====================
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFF28A745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFFDC3545),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        // Thêm padding bottom để nội dung không bị BottomNav của MainScreen che mất khi cuộn xuống cuối
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            FridgeHeader(
              isMultiSelectMode: _isMultiSelectMode,
              onCancel: _exitMultiSelectMode,
              onSave: _exitMultiSelectMode,
              onSettings: () async {
                // Navigate to Settings and reload when coming back
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                // Reload data after returning (user might have switched household)
                _loadInventoryData();
              },
            ),
            
            const FridgeSearchBar(),
            
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: _isMultiSelectMode 
          ? null 
          : FloatingActionButton(
              onPressed: _showAddItemBottomSheet,
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF2D5F4F),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // --- SỬA ĐỔI QUAN TRỌNG Ở ĐÂY ---
      // Nếu đang MultiSelect: Hiển thị thanh Xóa của màn hình con.
      // Nếu KHÔNG MultiSelect: Trả về null. Lúc này Scaffold con trong suốt ở đáy,
      // người dùng sẽ nhìn thấy và tương tác được với BottomNav của MainScreen.
      bottomNavigationBar: _isMultiSelectMode
          ? FridgeDeleteBar(
              onDelete: _showDeleteConfirmation,
              isEnabled: _selectedItems.isNotEmpty,
            )
          : null, 
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          if (_eatMeFirstItems.isNotEmpty && !_isMultiSelectMode) ...[
            const FridgeSectionHeader(title: 'Eat Me First'),
            const SizedBox(height: 12),
            _buildEatMeFirstSection(),
            const SizedBox(height: 28),
          ],
          
          if (!_isMultiSelectMode) ...[
            const FridgeSectionHeader(title: 'In Stock'),
            const SizedBox(height: 12),
          ],
          _buildInStockGrid(),
          
          // Khoảng trống dưới cùng quan trọng để list không bị BottomNav của MainScreen che
          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  // ... Các widget con (_buildEatMeFirstSection, _buildInStockGrid) giữ nguyên như cũ
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