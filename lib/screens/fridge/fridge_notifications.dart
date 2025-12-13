import 'package:flutter/material.dart';

class FridgeNotificationScreen extends StatelessWidget {
  const FridgeNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF0F1F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: const Color(0xFF214130),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          
          // TODAY Section
          _buildSectionHeader('TODAY'),
          const SizedBox(height: 12),
          
          _buildNotificationItem(
            icon: Icons.arrow_right_alt_outlined,
            iconColor: const Color(0xFFB72323),
            iconBgColor: const Color.fromARGB(255, 255, 225, 226),
            title: '50g Raw Pork has been taken out from the fridge.',
            time: '1:00 AM',
          ),
          
          const SizedBox(height: 12),
          
          _buildNotificationItem(
            icon: Icons.add,
            iconColor: const Color.fromARGB(255, 26, 180, 64),
            iconBgColor: const Color.fromARGB(255, 202, 246, 213),
            title: '30g Raw Beef has been added to the fridge.',
            time: '1:00 AM',
          ),
          
          const SizedBox(height: 12),
          
          _buildNotificationItem(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFFFA726),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Your ingredient: Milk is about to expire soon.',
            time: '2:21 AM',
          ),
          
          const SizedBox(height: 24),
          
          // YESTERDAY Section
          _buildSectionHeader('YESTERDAY'),
          const SizedBox(height: 12),
          
          _buildNotificationItem(
            icon: Icons.arrow_right_alt_outlined,
            iconColor: const Color(0xFFB72323),
            iconBgColor: const Color.fromARGB(255, 255, 225, 226),
            title: '50g Raw Pork has been taken out from the fridge.',
            time: '1:00 AM',
          ),
          
          const SizedBox(height: 12),
          
          _buildNotificationItem(
            icon: Icons.add,
            iconColor: const Color.fromARGB(255, 26, 180, 64),
            iconBgColor: const Color.fromARGB(255, 202, 246, 213),
            title: '30g Raw Beef has been added to the fridge.',
            time: '1:00 AM',
          ),
          
          const SizedBox(height: 12),
          
          _buildNotificationItem(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFFFA726),
            iconBgColor: const Color(0xFFFFF3E0),
            title: 'Your ingredient: Milk is about to expire soon.',
            time: '2:21 AM',
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: const Color(0xFFE7EAE9),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}