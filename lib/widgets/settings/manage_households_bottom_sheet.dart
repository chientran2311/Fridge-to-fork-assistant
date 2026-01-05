import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageHouseholdsBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> households;
  final String? currentHouseholdId;
  final Function(String householdId) onSwitchHousehold;
  final Function(String householdId) onLeaveHousehold;
  final Function(String householdId) onRegenerateCode;

  const ManageHouseholdsBottomSheet({
    super.key,
    required this.households,
    required this.currentHouseholdId,
    required this.onSwitchHousehold,
    required this.onLeaveHousehold,
    required this.onRegenerateCode,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xFF1B3B36);
    final bgCream = const Color(0xFFF9F9F7);

    return Container(
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, mainColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.kitchen,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Các tủ lạnh của bạn',
                        style: GoogleFonts.merriweather(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      Text(
                        '${households.length} tủ lạnh',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List of households
          if (households.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.kitchen_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chưa có tủ lạnh nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy tạo hoặc tham gia một tủ lạnh',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: households.length,
                itemBuilder: (context, index) {
                  final household = households[index];
                  final isCurrentHousehold = household['id'] == currentHouseholdId;
                  final isOwner = household['owner_id'] == household['current_user_id'];
                  
                  return _buildHouseholdCard(
                    context,
                    household: household,
                    isCurrentHousehold: isCurrentHousehold,
                    isOwner: isOwner,
                    mainColor: mainColor,
                  );
                },
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHouseholdCard(
    BuildContext context, {
    required Map<String, dynamic> household,
    required bool isCurrentHousehold,
    required bool isOwner,
    required Color mainColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentHousehold ? mainColor : Colors.grey[200]!,
          width: isCurrentHousehold ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrentHousehold ? mainColor : const Color(0xFFE8F0EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCurrentHousehold ? Icons.kitchen : Icons.kitchen_outlined,
                color: isCurrentHousehold ? Colors.white : mainColor,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    household['name'] ?? 'Unnamed Fridge',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (isCurrentHousehold)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mainColor, mainColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Đang dùng',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOwner ? Icons.star : Icons.person,
                      size: 14,
                      color: isOwner ? Colors.amber[700] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOwner ? 'Chủ sở hữu' : 'Thành viên',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isOwner ? Colors.amber[800] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.vpn_key, size: 14, color: mainColor),
                        const SizedBox(width: 6),
                        Text(
                          'Mã: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          household['invite_code'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            final code = household['invite_code']?.toString() ?? '';
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép mã mời!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.copy, size: 14, color: mainColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (!isCurrentHousehold)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onSwitchHousehold(household['id']);
                      },
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Chuyển'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: mainColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (!isCurrentHousehold && !isOwner) const SizedBox(width: 8),
                if (!isOwner && !isCurrentHousehold)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showLeaveConfirmation(context, household['id'], household['name']);
                      },
                      icon: const Icon(Icons.exit_to_app, size: 18),
                      label: const Text('Rời'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (isOwner && isCurrentHousehold)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onRegenerateCode(household['id']);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Tạo mã mới'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mainColor,
                        side: BorderSide(color: mainColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, String householdId, String? householdName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.exit_to_app, color: Colors.red[700], size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Rời khỏi tủ lạnh?',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn rời khỏi "${householdName ?? 'tủ lạnh này'}" không?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLeaveHousehold(householdId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Rời',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
