import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

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
import '../../widgets/fridge/delete_confirmation_modal.dart';
import '../../utils/responsive_ui.dart';

// Import Màn hình Settings
import '../settings/settings.dart'; 

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
      // ✅ UPDATE: Dùng localization cho SnackBar
      final s = AppLocalizations.of(context);
      final msg = s?.itemSelected(item.name) ?? "Selected: ${item.name}";
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  void _onItemLongPress(InventoryItem item) {
    if (!_isMultiSelectMode) {
      _enterMultiSelectMode(item.id);
    }
  }

  // ==================== ACTIONS ====================
  void _showAddItemDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => const AddItemDialog(), 
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _deleteSelectedItems() {
    // Gọi provider để xóa item thật ở đây
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    provider.deleteItems(_selectedItems.toList());
    
    _exitMultiSelectMode();

    // ✅ UPDATE: Dùng localization cho thông báo xóa
    final s = AppLocalizations.of(context);
    final msg = s?.itemsDeleted ?? 'Deleted selected items';

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
    // 1. Lấy s (ngôn ngữ) ở chế độ nullable (có thể null)
    final s = AppLocalizations.of(context);

    // Chuẩn bị các text an toàn (Nếu s chưa tải kịp thì hiện text mặc định)
    final titleEatMe = s?.eatMeFirst ?? 'Eat Me First';
    final titleInStock = s?.inStock ?? 'In Stock';
    final msgEmpty = s?.emptyFridge ?? '...';
    final msgAddFirst = s?.addFirstItem ?? '...';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 2. Header luôn hiển thị (không bị chặn bởi loading ngôn ngữ)
            FridgeHeader(
              isMultiSelectMode: _isMultiSelectMode,
              onCancel: _exitMultiSelectMode,
              onSave: _exitMultiSelectMode,
              onSettings: _navigateToSettings,
            ),
            const FridgeSearchBar(),
            
            // 3. Nội dung chính (Chứa logic Loading của Provider)
            Expanded(
              child: Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  // A. Loading Data từ Firestore -> Chỉ xoay ở giữa màn hình body
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0FBD3B)),
                    );
                  }

                  final allItems = provider.items;

                  // B. Empty Data
                  if (allItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(msgEmpty, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          Text(msgAddFirst, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    );
                  }

                  // C. Data List
                  final eatMeFirst = allItems.where((item) => item.daysLeft <= 3).toList();
                  final inStock = allItems.where((item) => item.daysLeft > 3).toList();
                  final displayInStock = _isMultiSelectMode ? allItems : inStock;

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Gọi hàm refresh trong provider
                      provider.listenToInventory(); 
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Section: Eat Me First
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
              backgroundColor: const Color(0xFF0FBD3B),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: _isMultiSelectMode
          ? FridgeDeleteBar(
              onDelete: _showDeleteConfirmation,
              isEnabled: _selectedItems.isNotEmpty,
            )
          : null,
    );
  }

  // ==================== SUB-WIDGETS ====================

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