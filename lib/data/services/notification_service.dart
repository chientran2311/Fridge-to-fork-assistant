import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/router/app_router.dart';
import 'dart:convert'; // Để encode/decode JSON payload

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

      // Xử lý khi App đang mở (Foreground) - Hiện local notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('☀️ Nhận thông báo Foreground: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // Xử lý khi bấm vào thông báo FCM (từ background/terminated)
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
  Future<void> saveTokenToDatabase({String? token}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? fcmToken = token ?? await _firebaseMessaging.getToken();
    print("🔑 FCM Token: $fcmToken");

    if (fcmToken != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'fcm_token': fcmToken,
        'updated_at': FieldValue.serverTimestamp(),
        'platform': 'flutter_client',
      }, SetOptions(merge: true));
      
      print("💾 Đã lưu Token lên Firestore cho User: ${user.uid}");
    }
  }

  // 3. Xử lý khi bấm notification FCM (background/terminated)
  void _setupInteractedMessage(GlobalKey<NavigatorState> navigatorKey) async {
    // Trường hợp 1: App đang tắt hoàn toàn -> Bấm notification -> App mở
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("📱 App mở từ terminated state");
      _handleNavigate(initialMessage.data);
    }

    // Trường hợp 2: App đang chạy ngầm -> Bấm notification -> App hiện lên
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📱 App mở từ background state");
      _handleNavigate(message.data);
    });
  }

  // 4. [QUAN TRỌNG] Logic điều hướng chung - Dùng cho mọi trường hợp
  void _handleNavigate(Map<String, dynamic> data) async {
    print("🔍 Checking data: $data");
    
    if (data['action_id'] == 'FIND_RECIPE') {
      final String ingredientsStr = data['ingredients_list'] ?? data['ingredient'] ?? '';
      
      print("🚀 Navigate: Tìm công thức với -> $ingredientsStr");
      
      // Đợi app sẵn sàng
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final encodedQuery = Uri.encodeComponent(ingredientsStr);
        final path = '/recipes?search=$encodedQuery';
        
        // Dùng appRouter.go() để navigate
        appRouter.go(path);
        print("✅ Đã navigate tới: $path");
      } catch (e) {
        print("❌ Lỗi navigate: $e");
      }
    }
  }

  // 5. Setup Local Notification với handler khi bấm
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = 
        InitializationSettings(android: androidSettings);
    
    await _localNotificationsPlugin.initialize(
      settings,
      // [QUAN TRỌNG] Handler khi bấm vào local notification (foreground case)
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("🔔 Bấm vào Local Notification, payload: ${details.payload}");
        
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            // Parse payload (đã encode thành JSON string)
            final Map<String, dynamic> data = jsonDecode(details.payload!);
            _handleNavigate(data);
          } catch (e) {
            print("❌ Lỗi parse payload: $e");
          }
        }
      },
    );
  }

  // 6. Hiện thông báo Local (khi app đang mở)
  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // [QUAN TRỌNG] Encode data thành JSON string để truyền qua payload
      final String payloadJson = jsonEncode(message.data);
      
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Thông báo quan trọng',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: payloadJson, // Truyền data qua payload
      );
    }
  }
}