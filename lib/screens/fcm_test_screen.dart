import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';

class FCMTestScreen extends StatefulWidget {
  const FCMTestScreen({super.key});

  @override
  State<FCMTestScreen> createState() => _FCMTestScreenState();
}

class _FCMTestScreenState extends State<FCMTestScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  
  String? _fcmToken;
  bool _isLoading = false;
  List<String> _logs = [];
  String _apiResponse = '';

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
    _setupNotificationListeners();
    _checkPermissions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadFCMToken() async {
    try {
      _fcmToken = _notificationService.fcmToken ?? await _notificationService.getSavedFcmToken();
      if (_fcmToken != null) {
        _tokenController.text = _fcmToken!;
        _addLog('FCM Token loaded: ${_fcmToken!.substring(0, 20)}...');
      } else {
        _addLog('No FCM token found. Make sure notifications are enabled.');
      }
    } catch (e) {
      _addLog('Error loading FCM token: $e');
    }
  }

  void _setupNotificationListeners() {
    // This will help us see when notifications are received
    _addLog('Notification listeners set up. Waiting for notifications...');
    _addLog('💡 TIP: Foreground notifications will now show as local notifications!');
    _addLog('💡 TIP: Test with app in foreground, background, and terminated states');
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 20) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _testNotification() async {
    if (_fcmToken == null) {
      _addLog('Error: No FCM token available');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://staging.hourandmore.sa/api/send-fcm-notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text.isNotEmpty ? _titleController.text : 'Test Notification',
          'message': _messageController.text.isNotEmpty ? _messageController.text : 'This is a test notification from your Flutter app!',
          'token': _fcmToken!,
        }),
      );

      setState(() {
        _apiResponse = 'Status: ${response.statusCode}\nBody: ${response.body}';
      });

      if (response.statusCode == 200) {
        _addLog('✅ Notification sent successfully!');
        _addLog('Response: ${response.body}');
        _addLog('📱 Check your device for the notification!');
      } else {
        _addLog('❌ Failed to send notification. Status: ${response.statusCode}');
        _addLog('Response: ${response.body}');
      }
    } catch (e) {
      _addLog('❌ Error sending notification: $e');
      setState(() {
        _apiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLocalNotification() async {
    _addLog('🧪 Testing local notification...');
    try {
      await _notificationService.testLocalNotification();
      _addLog('✅ Test local notification sent!');
      _addLog('📱 Check your device notification tray!');
    } catch (e) {
      _addLog('❌ Error testing local notification: $e');
    }
  }

  Future<void> _testChatNotification() async {
    _addLog('💬 Testing chat notification...');
    try {
      await _notificationService.showChatNotification(
        senderName: 'John Doe',
        messageText: 'Hey! How are you doing?',
        senderId: 'test_sender_123',
        receiverId: 'test_receiver_456',
      );
      _addLog('✅ Test chat notification sent!');
      _addLog('📱 Check your device for chat notification!');
    } catch (e) {
      _addLog('❌ Error testing chat notification: $e');
    }
  }

  Future<void> _checkPermissions() async {
    _addLog('🔍 Checking notification permissions...');
    try {
      final hasPermissions = await _notificationService.checkNotificationPermissions();
      if (hasPermissions) {
        _addLog('✅ Notification permissions granted');
      } else {
        _addLog('❌ Notification permissions denied');
        _addLog('💡 Go to Settings > Apps > Your App > Notifications to enable');
      }
    } catch (e) {
      _addLog('❌ Error checking permissions: $e');
    }
  }

  Future<void> _refreshToken() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.initialize();
      await _loadFCMToken();
      _addLog('FCM token refreshed');
    } catch (e) {
      _addLog('Error refreshing token: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Test'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshToken,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FCM Token Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FCM Token',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_fcmToken != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: SelectableText(
                          _fcmToken!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Token length: ${_fcmToken!.length} characters',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Text(
                          'No FCM token available. Make sure notifications are enabled.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Notification Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (optional)',
                        hintText: 'Test Notification',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message (optional)',
                        hintText: 'This is a test notification!',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _fcmToken != null && !_isLoading ? _testNotification : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Send FCM Notification'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _testLocalNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          child: const Text('Test Local'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _testChatNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          child: const Text('Test Chat'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkPermissions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Check Permissions'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // API Response Section
            if (_apiResponse.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Response',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          _apiResponse,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Logs Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _logs.clear();
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text(
                                'No logs yet...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    _logs[index],
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '📋 TESTING STEPS:\n'
                      '1. Check permissions first (blue button)\n'
                      '2. Test local notifications (orange button)\n'
                      '3. Test chat notifications (green button)\n'
                      '4. Test FCM notifications (purple button)\n'
                      '5. Test in different app states\n\n'
                      '🔧 TROUBLESHOOTING:\n'
                      '• No notifications? Check device settings\n'
                      '• Foreground: Local notification should appear\n'
                      '• Background: System notification should appear\n'
                      '• Terminated: System notification + app opens\n'
                      '• Chat notifications have reply actions\n'
                      '• Check logs below for detailed info',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
