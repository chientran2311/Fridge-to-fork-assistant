import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:fridge_to_fork_assistant/utils/responsive_ui.dart';

// Import Models & Providers
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item.dart';

// Import các widget con
import '../../widgets/fridge/fridge_item_card.dart'; // Widget Card mới đã fix
import '../../widgets/fridge/fridge_header.dart';
import '../../widgets/fridge/fridge_search_bar.dart';
import '../../widgets/fridge/fridge_section_header.dart';
import '../../widgets/fridge/fridge_delete_bar.dart';
import '../../widgets/fridge/add_item_bottom_sheet.dart';
import '../../widgets/fridge/edit_item_bottom_sheet.dart'; // Import Edit Sheet nếu có
import '../../widgets/fridge/delete_confirmation_modal.dart';
import 'package:fridge_to_fork_assistant/screens/settings/settings.dart';

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
      // TODO: Mở Edit Bottom Sheet
      // _showEditBottomSheet(item);
    }
  }

  void _onItemLongPress(InventoryItem item) {
    if (!_isMultiSelectMode) {
      _enterMultiSelectMode(item.id);
    }
  }

  // ==================== ACTIONS ====================
  void _showAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Đảm bảo AddItemBottomSheet đã được cập nhật để gọi Provider khi add
      builder: (context) => const AddItemBottomSheet(), 
    );
  }

  void _showEditBottomSheet(InventoryItem item) {
    // TODO: Cập nhật EditItemBottomSheet để nhận InventoryItem
    /*
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditItemBottomSheet(item: item),
    );
    */
  }

  void _deleteSelectedItems() {
    // Gọi Provider để xóa items (Bạn cần implement hàm deleteItems trong InventoryProvider)
    // Provider.of<InventoryProvider>(context, listen: false).deleteItems(_selectedItems.toList());
    
    // Tạm thời chỉ clear selection UI
    _exitMultiSelectMode();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa (Cần cập nhật Provider để xóa thật)')),
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
      desktopBody: _buildLayout(), // Có thể tùy biến layout desktop sau
    );
  }

  Widget _buildLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header & Search
            FridgeHeader(
              isMultiSelectMode: _isMultiSelectMode,
              onCancel: _exitMultiSelectMode,
              onSave: _exitMultiSelectMode,
              onSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const FridgeSearchBar(),
            
            // 2. Nội dung chính (Dùng Consumer để lắng nghe dữ liệu thật)
            Expanded(
              child: Consumer<InventoryProvider>(
                builder: (context, provider, child) {
                  // A. Trạng thái Loading
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allItems = provider.items;

                  // B. Trạng thái Trống
                  if (allItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text("Tủ lạnh trống trơn!", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }

                  // C. Phân loại dữ liệu
                  // Eat Me First: Hết hạn hoặc còn <= 3 ngày
                  final eatMeFirst = allItems.where((item) => item.daysLeft <= 3).toList();
                  // In Stock: Các món còn lại
                  final inStock = allItems.where((item) => item.daysLeft > 3).toList();

                  // Nếu đang Multi-select, hiển thị gộp chung để dễ chọn
                  final displayInStock = _isMultiSelectMode ? allItems : inStock;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Section: Eat Me First (Chỉ hiện nếu có món sắp hết hạn và không đang chọn nhiều)
                        if (eatMeFirst.isNotEmpty && !_isMultiSelectMode) ...[
                          const FridgeSectionHeader(title: 'Eat Me First ⚠️'),
                          const SizedBox(height: 12),
                          _buildEatMeFirstSection(eatMeFirst),
                          const SizedBox(height: 28),
                        ],

                        // Section: In Stock
                        if (!_isMultiSelectMode) ...[
                          const FridgeSectionHeader(title: 'In Stock 🥑'),
                          const SizedBox(height: 12),
                        ],
                        
                        _buildInStockGrid(displayInStock),

                        // Padding đáy để không bị che bởi BottomNav chính hoặc DeleteBar
                        const SizedBox(height: 100), 
                      ],
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
              onPressed: _showAddItemBottomSheet,
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF2D5F4F),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Thanh xóa khi Multi-select
      bottomNavigationBar: _isMultiSelectMode
          ? FridgeDeleteBar(
              onDelete: _showDeleteConfirmation,
              isEnabled: _selectedItems.isNotEmpty,
            )
          : null,
    );
  }

  // ==================== SUB-WIDGETS ====================

  // Danh sách ngang (Eat Me First)
  Widget _buildEatMeFirstSection(List<InventoryItem> items) {
    return SizedBox(
      height: 220, // Chiều cao phải khớp với FridgeItemCard
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

  // Grid (In Stock)
  Widget _buildInStockGrid(List<InventoryItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80, // Tỷ lệ khung hình thẻ
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