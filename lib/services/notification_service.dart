import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _tokenKey = 'fcm_token';
  
  String? _fcmToken;
  
  NotificationService._init();

  String? get fcmToken => _fcmToken;

  // Initialize FCM
  Future<void> initialize() async {
    try {
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

  // Set up message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received foreground message: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
      }

      // You can show a local notification here if needed
      // For now, we'll just log it
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notification tapped: ${message.messageId}');
        print('Data: ${message.data}');
      }

      // Navigate to specific screen based on notification data
      _handleNotificationTap(message);
    });

    // Handle notification tap when app is terminated
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print('App opened from terminated state via notification: ${message.messageId}');
        }
        _handleNotificationTap(message);
      }
    });
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
}


