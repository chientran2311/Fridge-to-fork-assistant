import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Hàm xử lý khi App đang tắt (Background/Terminated)
// Bắt buộc phải là Top-level function (nằm ngoài class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🌙 Nhận thông báo ngầm: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 1. Khởi tạo Service (Gọi ở main.dart)
  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // Xin quyền thông báo (Quan trọng cho iOS/Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Người dùng đã cấp quyền thông báo.');
      
      // Setup thông báo Local (để hiện tin khi App đang mở)
      await _setupLocalNotifications();
      
      // Đăng ký hàm xử lý Background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Xử lý khi App đang mở (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('☀️ Nhận thông báo Foreground: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // Xử lý khi bấm vào thông báo (Deep Link)
      _setupInteractedMessage(navigatorKey);
      
      // Lấy Token và lưu ngay (nếu đã login)
      await saveTokenToDatabase();
      
      // Lắng nghe thay đổi Token (ít khi xảy ra, nhưng cần thiết)
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        saveTokenToDatabase(token: newToken);
      });
      
    } else {
      print('❌ Người dùng từ chối quyền thông báo.');
    }
  }

  // 2. Logic Lưu Token lên Firestore
  // Backend sẽ quét collection 'users', tìm field 'fcm_token' để gửi tin.
  Future<void> saveTokenToDatabase({String? token}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Chưa login thì thôi

    String? fcmToken = token ?? await _firebaseMessaging.getToken();
    print("🔑 FCM Token: $fcmToken");

    if (fcmToken != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'fcm_token': fcmToken,
        'updated_at': FieldValue.serverTimestamp(), // Để biết token còn mới không
        'platform': 'flutter_client',
      }, SetOptions(merge: true)); // Merge: Chỉ cập nhật field này, giữ nguyên data khác
      
      print("💾 Đã lưu Token lên Firestore cho User: ${user.uid}");
    }
  }

  // 3. Xử lý Deep Link (Chuyển màn hình)
  void _setupInteractedMessage(GlobalKey<NavigatorState> navigatorKey) async {
    // Trường hợp 1: App đang tắt hoàn toàn -> Bấm thông báo -> App mở
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRedirect(initialMessage, navigatorKey);
    }

    // Trường hợp 2: App đang chạy ngầm -> Bấm thông báo -> App hiện lên
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRedirect(message, navigatorKey);
    });
  }

  // Logic điều hướng dựa trên Data từ Backend gửi về
  void _handleRedirect(RemoteMessage message, GlobalKey<NavigatorState> navigatorKey) {
    if (message.data.containsKey('screen')) {
      final String screen = message.data['screen'];
      final String ingredient = message.data['ingredient'] ?? '';

      print("🚀 Deep Link tới: $screen với món: $ingredient");

      // Điều hướng
      if (screen == '/recipe_suggestions') {
        // Giả sử bạn có route này, truyền argument vào
        navigatorKey.currentState?.pushNamed(
          '/recipe_suggestions', 
          arguments: ingredient // Truyền tên nguyên liệu sang màn hình gợi ý
        );
      }
    }
  }

  // Helper: Setup Local Notification
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(settings,
      onDidReceiveNotificationResponse: (details) {
         // Xử lý bấm vào thông báo local ở đây nếu cần
      }
    );
  }

  // Helper: Hiện thông báo Local
  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Id
            'Thông báo quan trọng', // Name
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
}