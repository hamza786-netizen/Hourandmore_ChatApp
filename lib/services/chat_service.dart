import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../database/database_helper.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class ChatService {
  static final ChatService instance = ChatService._init();
  
  final DatabaseHelper _localDb = DatabaseHelper.instance;
  final FirebaseService _firebaseService = FirebaseService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  ChatService._init();

  // Send message (saves to both local and Firebase)
  Future<void> sendMessage(Message message) async {
    // Save to local database first (for offline support)
    final localId = await _localDb.insertMessage(message);
    
    // Try to sync with Firebase
    try {
      final firebaseId = await _firebaseService.sendMessage(message);
      if (firebaseId != null) {
        // Update local message with Firebase ID and mark as synced
        await _localDb.updateMessageSyncStatus(localId, true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync with Firebase: $e');
      }
      // Message is still saved locally
    }
  }

  // Get messages stream from Firebase (real-time)
  Stream<List<Message>> getMessagesStream() {
    return _firebaseService.getMessagesStream();
  }

  // Get conversation messages stream
  Stream<List<Message>> streamConversationMessages(
    String userId1,
    String userId2,
  ) {
    return _firebaseService.streamConversationMessages(userId1, userId2);
  }

  // Get local messages (for offline mode)
  Future<List<Message>> getLocalMessages() async {
    return await _localDb.getAllMessages();
  }

  // Handle incoming message and show notification
  Future<void> handleIncomingMessage(Message message, String currentUserId) async {
    try {
      // Only show notification if the message is for the current user
      if (message.receiverId == currentUserId) {
        if (kDebugMode) {
          print('💬 Handling incoming message:');
          print('   From: ${message.senderEmail}');
          print('   To: ${message.receiverId}');
          print('   Text: ${message.text}');
        }

        // Extract sender name from email (remove @domain.com)
        final senderName = message.senderEmail.split('@').first;
        
        // Show chat notification
        await _notificationService.showChatNotification(
          senderName: senderName,
          messageText: message.text,
          senderId: message.senderId,
          receiverId: message.receiverId,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling incoming message: $e');
      }
    }
  }

  // Send notification to receiver when message is sent
  Future<void> sendMessageNotification(Message message, String receiverToken) async {
    try {
      // Extract sender name from email
      final senderName = message.senderEmail.split('@').first;
      
      if (kDebugMode) {
        print('📤 Sending message notification:');
        print('   To: ${message.receiverId}');
        print('   From: $senderName');
        print('   Message: ${message.text}');
      }

      // Send notification via your API
      await _notificationService.sendChatNotification(
        receiverToken: receiverToken,
        senderName: senderName,
        messageText: message.text,
        senderId: message.senderId,
        receiverId: message.receiverId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message notification: $e');
      }
    }
  }

  // Get conversation messages from local database
  Future<List<Message>> getConversationMessages(
    String userId1,
    String userId2,
  ) async {
    return await _localDb.getConversationMessages(userId1, userId2);
  }

  // Delete all messages (both local and Firebase)
  Future<void> deleteAllMessages() async {
    await _localDb.deleteAllMessages();
    
    try {
      await _firebaseService.deleteAllMessages();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete from Firebase: $e');
      }
    }
  }

  // Delete conversation messages
  Future<void> deleteConversationMessages(String userId1, String userId2) async {
    await _localDb.deleteConversationMessages(userId1, userId2);
    
    try {
      await _firebaseService.deleteConversationMessages(userId1, userId2);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete conversation from Firebase: $e');
      }
    }
  }

  // Sync local messages to Firebase
  Future<void> syncToFirebase() async {
    try {
      final unsyncedMessages = await _localDb.getUnsyncedMessages();
      
      for (var message in unsyncedMessages) {
        try {
          final firebaseId = await _firebaseService.sendMessage(message);
          if (firebaseId != null && message.id != null) {
            await _localDb.updateMessageSyncStatus(message.id!, true);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync message: $e');
          }
        }
      }
      
      if (kDebugMode) {
        print('Synced ${unsyncedMessages.length} messages to Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync failed: $e');
      }
    }
  }

  // Sync Firebase messages to local database
  Future<void> syncFromFirebase(String userId1, String userId2) async {
    try {
      final firebaseMessages = await _firebaseService.getConversationMessages(
        userId1,
        userId2,
      );

      for (var message in firebaseMessages) {
        await _localDb.insertMessage(message.copyWith(isSynced: true));
      }
      
      if (kDebugMode) {
        print('Synced ${firebaseMessages.length} messages from Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync from Firebase: $e');
      }
    }
  }
}


