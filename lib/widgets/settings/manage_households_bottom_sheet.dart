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
                Icon(Icons.kitchen, color: mainColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'My Fridges',
                  style: GoogleFonts.merriweather(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
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
                  Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No fridges found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  isOwner ? 'Owner' : 'Member',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.vpn_key, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Invite Code: ${household['invite_code'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          final code = household['invite_code']?.toString() ?? '';
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invite code copied!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Icon(Icons.copy, size: 14, color: mainColor),
                      ),
                    ],
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
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onSwitchHousehold(household['id']);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mainColor,
                        side: BorderSide(color: mainColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Switch'),
                    ),
                  ),
                if (!isCurrentHousehold && !isOwner) const SizedBox(width: 8),
                if (!isOwner && !isCurrentHousehold)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showLeaveConfirmation(context, household['id'], household['name']);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Leave'),
                    ),
                  ),
                if (isOwner && isCurrentHousehold)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onRegenerateCode(household['id']);
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('New Code'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mainColor,
                        side: BorderSide(color: mainColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
        title: const Text('Leave Fridge?'),
        content: Text('Are you sure you want to leave "${householdName ?? 'this fridge'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLeaveHousehold(householdId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
