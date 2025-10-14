import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/firebase_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService.instance;
  final FirebaseService _firebaseService = FirebaseService.instance;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;

  // Send a message
  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String senderEmail,
    required String receiverId,
  }) async {
    try {
      final message = Message(
        text: text,
        senderId: senderId,
        senderEmail: senderEmail,
        receiverId: receiverId,
        timestamp: DateTime.now(),
      );

      await _chatService.sendMessage(message);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Load messages for a conversation
  Future<void> loadConversationMessages(String userId1, String userId2) async {
    try {
      _messages = await _chatService.getConversationMessages(userId1, userId2);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load messages: $e';
      _messages = [];
      notifyListeners();
    }
  }

  // Stream messages for a conversation
  Stream<List<Message>> streamConversationMessages(
    String userId1,
    String userId2,
  ) {
    return _firebaseService.streamConversationMessages(userId1, userId2);
  }

  // Delete all messages
  Future<void> deleteAllMessages() async {
    try {
      await _chatService.deleteAllMessages();
      _messages = [];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete messages: $e';
      notifyListeners();
    }
  }

  // Delete conversation messages
  Future<void> deleteConversationMessages(String userId1, String userId2) async {
    try {
      await _chatService.deleteConversationMessages(userId1, userId2);
      _messages = [];
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete messages: $e';
      notifyListeners();
    }
  }

  // Sync messages
  Future<void> syncMessages() async {
    try {
      await _chatService.syncToFirebase();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sync messages: $e';
      notifyListeners();
    }
  }

  // Set online status (only update if changed)
  void setOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      // Don't notify listeners to prevent rebuild loops
      // The status is read directly when needed
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

