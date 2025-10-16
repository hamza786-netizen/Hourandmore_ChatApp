import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static const String _tokenKey = 'fcm_token';
  
  String? _fcmToken;
  
  NotificationService._init();

  String? get fcmToken => _fcmToken;

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Request notification permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permission');
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('User granted provisional notification permission');
        }
      } else {
        if (kDebugMode) {
          print('User declined or has not accepted notification permission');
        }
      }

      // Get FCM token
      _fcmToken = await _fcm.getToken();
      if (_fcmToken != null) {
        await _saveFcmToken(_fcmToken!);
        if (kDebugMode) {
          print('FCM Token: $_fcmToken');
        }
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFcmToken(newToken);
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
      });

      // Set up message handlers
      _setupMessageHandlers();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FCM: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android settings with proper channel
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      final bool? result = await _localNotifications.initialize(initSettings);
      
      if (kDebugMode) {
        print('🔔 Local notifications initialization result: $result');
        if (result == true) {
          print('✅ Local notifications initialized successfully');
        } else {
          print('❌ Local notifications initialization failed');
        }
      }
      
      // Create notification channels for Android
      await _createNotificationChannel();
      await _createChatNotificationChannel();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing local notifications: $e');
      }
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'fcm_channel',
        'FCM Notifications',
        description: 'Notifications from Firebase Cloud Messaging',
        importance: Importance.high,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      
      if (kDebugMode) {
        print('✅ FCM notification channel created');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating FCM notification channel: $e');
      }
    }
  }

  // Create chat notification channel for Android
  Future<void> _createChatNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'chat_channel',
        'Chat Messages',
        description: 'Notifications for new chat messages',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF6C63FF),
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      
      if (kDebugMode) {
        print('✅ Chat notification channel created');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating chat notification channel: $e');
      }
    }
  }

  // Set up message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Received foreground message: ${message.messageId}');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Data: ${message.data}');
      }

      // Show local notification for foreground messages
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Notification tapped (background): ${message.messageId}');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Data: ${message.data}');
      }

      // Navigate to specific screen based on notification data
      _handleNotificationTap(message);
    });

    // Handle notification tap when app is terminated
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print('🔔 App opened from terminated state via notification: ${message.messageId}');
          print('   Title: ${message.notification?.title}');
          print('   Body: ${message.notification?.body}');
          print('   Data: ${message.data}');
        }
        _handleNotificationTap(message);
      }
    });
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      if (kDebugMode) {
        print('🔔 Attempting to show local notification...');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
      }

      final title = message.notification?.title ?? 'New Message';
      final body = message.notification?.body ?? 'You have a new notification';
      
      const androidDetails = AndroidNotificationDetails(
        'fcm_channel',
        'FCM Notifications',
        channelDescription: 'Notifications from Firebase Cloud Messaging',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
      );
      
      if (kDebugMode) {
        print('✅ Local notification displayed successfully');
        print('   ID: ${message.hashCode}');
        print('   Title: $title');
        print('   Body: $body');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing local notification: $e');
        print('   Error details: $e');
      }
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    // You can navigate to specific screens based on message.data
    if (kDebugMode) {
      print('Handling notification tap with data: ${message.data}');
    }
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }

  // Save FCM token to local storage
  Future<void> _saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  // Get saved FCM token
  Future<String?> getSavedFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting saved FCM token: $e');
      }
      return null;
    }
  }

  // Delete FCM token
  Future<void> deleteFcmToken() async {
    try {
      await _fcm.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _fcmToken = null;
      if (kDebugMode) {
        print('FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
    }
  }

  // Test local notification directly
  Future<void> testLocalNotification() async {
    try {
      if (kDebugMode) {
        print('🧪 Testing local notification...');
      }

      const androidDetails = AndroidNotificationDetails(
        'fcm_channel',
        'FCM Notifications',
        channelDescription: 'Notifications from Firebase Cloud Messaging',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        999,
        'Test Notification',
        'This is a test notification to verify local notifications work!',
        notificationDetails,
      );
      
      if (kDebugMode) {
        print('✅ Test local notification sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending test local notification: $e');
        print('   Error details: $e');
      }
    }
  }

  // Check notification permissions
  Future<bool> checkNotificationPermissions() async {
    try {
      final settings = await _fcm.getNotificationSettings();
      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      if (kDebugMode) {
        print('🔔 Notification permissions check:');
        print('   Authorization Status: ${settings.authorizationStatus}');
        print('   Alert: ${settings.alert}');
        print('   Badge: ${settings.badge}');
        print('   Sound: ${settings.sound}');
        print('   Is Authorized: $isAuthorized');
      }
      
      return isAuthorized;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking notification permissions: $e');
      }
      return false;
    }
  }

  // Send chat notification to specific user
  Future<void> sendChatNotification({
    required String receiverToken,
    required String senderName,
    required String messageText,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      if (kDebugMode) {
        print('💬 Sending chat notification:');
        print('   To: $receiverId');
        print('   From: $senderName');
        print('   Message: $messageText');
      }

      // This would typically call your backend API
      // For now, we'll just log it since you already have the API working
      if (kDebugMode) {
        print('📤 Chat notification would be sent via your API:');
        print('   URL: https://staging.hourandmore.sa/api/send-fcm-notification');
        print('   Title: $senderName');
        print('   Body: $messageText');
        print('   Token: ${receiverToken.substring(0, 20)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending chat notification: $e');
      }
    }
  }

  // Show chat notification locally (for received messages)
  Future<void> showChatNotification({
    required String senderName,
    required String messageText,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      if (kDebugMode) {
        print('💬 Showing chat notification:');
        print('   From: $senderName');
        print('   Message: $messageText');
      }

      final androidDetails = AndroidNotificationDetails(
        'chat_channel',
        'Chat Messages',
        channelDescription: 'Notifications for new chat messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        category: AndroidNotificationCategory.message,
        actions: [
          AndroidNotificationAction(
            'reply',
            'Reply',
            icon: DrawableResourceAndroidBitmap('ic_reply'),
            inputs: [
              AndroidNotificationActionInput(
                label: 'Type a message...',
              ),
            ],
          ),
          AndroidNotificationAction(
            'mark_read',
            'Mark as Read',
            icon: DrawableResourceAndroidBitmap('ic_mark_read'),
          ),
        ],
      );
      
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
        categoryIdentifier: 'CHAT_MESSAGE',
        threadIdentifier: 'chat_$senderId',
      );
      
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Use a unique ID based on sender and receiver
      final notificationId = '$senderId-$receiverId'.hashCode;
      
      await _localNotifications.show(
        notificationId,
        senderName,
        messageText,
        notificationDetails,
        payload: 'chat_${senderId}_${receiverId}',
      );
      
      if (kDebugMode) {
        print('✅ Chat notification displayed successfully');
        print('   ID: $notificationId');
        print('   From: $senderName');
        print('   Message: $messageText');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing chat notification: $e');
        print('   Error details: $e');
      }
    }
  }

  // Handle notification actions (reply, mark as read, etc.)
  void setupNotificationActionHandlers() {
    _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('🔔 Notification action tapped:');
          print('   Action: ${response.actionId}');
          print('   Payload: ${response.payload}');
          print('   Input: ${response.input}');
        }

        if (response.actionId == 'reply' && response.input != null) {
          // Handle reply action
          _handleReplyAction(response.payload, response.input!);
        } else if (response.actionId == 'mark_read') {
          // Handle mark as read action
          _handleMarkAsReadAction(response.payload);
        } else {
          // Handle regular notification tap
          _handleChatNotificationTap(response.payload);
        }
      },
    );
  }

  void _handleReplyAction(String? payload, String input) {
    if (kDebugMode) {
      print('💬 Reply action: $input');
      print('   Payload: $payload');
    }
    // TODO: Implement reply functionality
    // This would typically send the reply message
  }

  void _handleMarkAsReadAction(String? payload) {
    if (kDebugMode) {
      print('✅ Mark as read action');
      print('   Payload: $payload');
    }
    // TODO: Implement mark as read functionality
  }

  void _handleChatNotificationTap(String? payload) {
    if (kDebugMode) {
      print('💬 Chat notification tapped');
      print('   Payload: $payload');
    }
    // TODO: Navigate to chat screen
    // This would typically open the specific chat conversation
  }
}


