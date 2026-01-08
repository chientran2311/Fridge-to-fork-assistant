import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../models/fridge_notification.dart';

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
            color: Color(0xFF214130),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Nút đánh dấu tất cả đã đọc
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: Color(0xFF214130),
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Nhóm thông báo theo ngày
          final groupedNotifications = _groupNotificationsByDate(provider.notifications);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedNotifications.length,
            itemBuilder: (context, index) {
              final group = groupedNotifications[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSectionHeader(group['label'] as String),
                  const SizedBox(height: 12),
                  ...((group['notifications'] as List<FridgeNotification>).map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNotificationItem(
                        context,
                        notification,
                        provider,
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Nhóm thông báo theo ngày
  List<Map<String, dynamic>> _groupNotificationsByDate(List<FridgeNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayNotifs = <FridgeNotification>[];
    final yesterdayNotifs = <FridgeNotification>[];
    final olderNotifs = <FridgeNotification>[];

    for (var notification in notifications) {
      final notifDate = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );

      if (notifDate == today) {
        todayNotifs.add(notification);
      } else if (notifDate == yesterday) {
        yesterdayNotifs.add(notification);
      } else {
        olderNotifs.add(notification);
      }
    }

    final result = <Map<String, dynamic>>[];
    if (todayNotifs.isNotEmpty) {
      result.add({'label': 'TODAY', 'notifications': todayNotifs});
    }
    if (yesterdayNotifs.isNotEmpty) {
      result.add({'label': 'YESTERDAY', 'notifications': yesterdayNotifs});
    }
    if (olderNotifs.isNotEmpty) {
      result.add({'label': 'OLDER', 'notifications': olderNotifs});
    }

    return result;
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

  Widget _buildNotificationItem(
    BuildContext context,
    FridgeNotification notification,
    NotificationProvider provider,
  ) {
    // Xác định icon và màu dựa trên loại thông báo
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (notification.type) {
      case NotificationType.added:
        icon = Icons.add;
        iconColor = const Color.fromARGB(255, 26, 180, 64);
        iconBgColor = const Color.fromARGB(255, 202, 246, 213);
        break;
      case NotificationType.removed:
        icon = Icons.arrow_right_alt_outlined;
        iconColor = const Color(0xFFB72323);
        iconBgColor = const Color.fromARGB(255, 255, 225, 226);
        break;
      case NotificationType.updated:
        icon = Icons.edit_outlined;
        iconColor = const Color(0xFF2196F3);
        iconBgColor = const Color(0xFFE3F2FD);
        break;
      case NotificationType.expiring:
        icon = Icons.warning_amber_outlined;
        iconColor = const Color(0xFFFFA726);
        iconBgColor = const Color(0xFFFFF3E0);
        break;
      default:
        icon = Icons.info_outline;
        iconColor = Colors.grey;
        iconBgColor = Colors.grey.shade200;
    }

    // Format thời gian
    final timeFormat = DateFormat('h:mm a');
    final timeStr = timeFormat.format(notification.timestamp);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDC3545),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white 
                : const Color(0xFFF0F8FF), // Màu nhạt hơn cho chưa đọc
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead 
                ? null 
                : Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    width: 1,
                  ),
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
                      notification.title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: notification.isRead 
                            ? FontWeight.w500 
                            : FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, left: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}