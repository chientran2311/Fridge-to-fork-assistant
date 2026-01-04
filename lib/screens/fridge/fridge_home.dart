import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Import Localization
import '../../l10n/app_localizations.dart';
import '../../utils/responsive_ui.dart';

// Import Models & Providers
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item.dart';

// Import Widgets
import '../../widgets/fridge/fridge_item_card.dart'; 
import '../../widgets/fridge/fridge_header.dart';
import '../../widgets/fridge/fridge_search_bar.dart';
import '../../widgets/fridge/fridge_section_header.dart';
import '../../widgets/fridge/fridge_delete_bar.dart';
import '../../widgets/fridge/add_item_bottom_sheet.dart';
import '../../widgets/fridge/edit_item_bottom_sheet.dart';
import '../../widgets/fridge/delete_confirmation_modal.dart';

class FridgeHomeScreen extends StatefulWidget {
  const FridgeHomeScreen({super.key});

  @override
  State<FridgeHomeScreen> createState() => _FridgeHomeScreenState();
}

class _FridgeHomeScreenState extends State<FridgeHomeScreen> {
  bool _isMultiSelectMode = false;
  final Set<String> _selectedItems = {};

  // ==================== MULTI-SELECT METHODS ====================
  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
        if (_selectedItems.isEmpty) _isMultiSelectMode = false;
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

  // ==================== INTERACTIONS ====================
  void _onItemTap(InventoryItem item) {
    if (_isMultiSelectMode) {
      _toggleItemSelection(item.id);
    } else {
      // Mở bottom sheet để sửa item
      _showEditBottomSheet(item);
    }
  }

  void _onItemLongPress(InventoryItem item) {
    if (!_isMultiSelectMode) {
      _enterMultiSelectMode(item.id);
    }
  }

  // ==================== EDIT ITEM ====================
  void _showEditBottomSheet(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemBottomSheet(
        item: item,
        onSave: (updatedItem) async {
          // Gọi provider để cập nhật
          await context.read<InventoryProvider>().updateItem(updatedItem);
        },
      ),
    );
  }

  // ==================== ACTIONS ====================
  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddItemBottomSheet(), 
    );
  }

  void _navigateToSettings() {
    context.go('/fridge/settings'); 
  }

  void _deleteSelectedItems() {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    provider.deleteItems(_selectedItems.toList());
    
    _exitMultiSelectMode();

    final s = AppLocalizations.of(context);
    final msg = s?.itemsDeleted ?? 'Đã xóa các món đã chọn';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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

  // ==================== UI BUILDER ====================
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildLayout(),
      desktopBody: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildLayout(),
        ),
      ),
    );
  }

  Widget _buildLayout() {
    final s = AppLocalizations.of(context);

    // Text fallback nếu localization chưa load
    final titleEatMe = s?.eatMeFirst ?? 'Ăn ngay';
    final titleInStock = s?.inStock ?? 'Còn trong kho';
    final msgEmpty = s?.emptyFridge ?? 'Tủ lạnh trống';
    final msgAddFirst = s?.addFirstItem ?? 'Thêm món đầu tiên nào!';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FridgeHeader(
              isMultiSelectMode: _isMultiSelectMode,
              onCancel: _exitMultiSelectMode,
              onSave: _exitMultiSelectMode,
              onSettings: _navigateToSettings,
            ),
            const FridgeSearchBar(),
            
            // Main Content với Consumer
            Expanded(
              child: Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  // Loading
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0FBD3B)),
                    );
                  }

                  final allItems = provider.items;

                  // Empty State
                  if (allItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(msgEmpty, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(msgAddFirst, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    );
                  }

                  // Phân loại items
                  final eatMeFirst = allItems.where((item) => item.daysLeft <= 3).toList();
                  final inStock = allItems.where((item) => item.daysLeft > 3).toList();
                  final displayInStock = _isMultiSelectMode ? allItems : inStock;

                  return RefreshIndicator(
                    onRefresh: () async {
                      provider.listenToInventory(); 
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Section: Eat Me First (Sắp hết hạn)
                          if (eatMeFirst.isNotEmpty && !_isMultiSelectMode) ...[
                            FridgeSectionHeader(title: titleEatMe),
                            const SizedBox(height: 12),
                            _buildEatMeFirstSection(eatMeFirst),
                            const SizedBox(height: 28),
                          ],

                          // Section: In Stock
                          if (!_isMultiSelectMode) ...[
                            FridgeSectionHeader(title: titleInStock),
                            const SizedBox(height: 12),
                          ],
                          
                          _buildInStockGrid(displayInStock),

                          const SizedBox(height: 100), 
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // FAB Thêm món
      floatingActionButton: _isMultiSelectMode 
          ? null 
          : FloatingActionButton(
              onPressed: _showAddItemDialog,
              shape: const CircleBorder(),
              backgroundColor: const Color.fromARGB(255, 36, 75, 45),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom Bar khi Multi-Select
      bottomNavigationBar: _isMultiSelectMode
          ? FridgeDeleteBar(
              onDelete: _showDeleteConfirmation,
              isEnabled: _selectedItems.isNotEmpty,
            )
          : null,
    );
  }

  // ==================== SUB-WIDGETS ====================

  /// Section ngang cho các món sắp hết hạn
  Widget _buildEatMeFirstSection(List<InventoryItem> items) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(
              right: index < items.length - 1 ? 12 : 0,
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

  /// Grid cho các món trong kho
  Widget _buildInStockGrid(List<InventoryItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
