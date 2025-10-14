import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  final String _messagesCollection = 'messages';

  FirebaseService._init();

  // Send a message to Firebase
  Future<String?> sendMessage(Message message) async {
    try {
      final messageData = message.toFirebaseMap();
      if (kDebugMode) {
        print('📤 Sending message to Firebase:');
        print('   Text: ${message.text}');
        print('   SenderId: ${message.senderId}');
        print('   ReceiverId: ${message.receiverId}');
        print('   Data: $messageData');
      }
      
      final docRef = await _firestore.collection(_messagesCollection).add(messageData);
      
      if (kDebugMode) {
        print('✅ Message sent successfully! Firebase ID: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message to Firebase: $e');
      }
      rethrow;
    }
  }

  // Get messages stream (real-time updates)
  Stream<List<Message>> getMessagesStream() {
    return _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Message.fromFirebaseMap(data, doc.id);
      }).toList();
    });
  }

  // Stream messages for a specific conversation
  Stream<List<Message>> streamConversationMessages(
    String userId1,
    String userId2,
  ) {
    if (kDebugMode) {
      print('📡 Setting up message stream for conversation:');
      print('   User 1: $userId1');
      print('   User 2: $userId2');
    }
    
    // Query all messages and filter in memory to avoid composite index requirement
    return _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          if (kDebugMode) {
            print('\n🔄 Processing Firestore snapshot...');
            print('   Total docs in snapshot: ${snapshot.docs.length}');
          }
          
          final allMessages = snapshot.docs.map((doc) {
            final data = doc.data();
            if (kDebugMode) {
              print('   Doc ${doc.id}: sender="${data['senderId']}", receiver="${data['receiverId']}", text="${data['text']}"');
            }
            return Message.fromFirebaseMap(data, doc.id);
          }).toList();
          
          if (kDebugMode) {
            print('\n🔍 Filtering messages for conversation:');
            print('   Looking for: ($userId1 ↔ $userId2)');
          }
          
          final conversationMessages = allMessages.where((message) {
            final match = (message.senderId == userId1 && message.receiverId == userId2) ||
                         (message.senderId == userId2 && message.receiverId == userId1);
            if (kDebugMode && match) {
              print('   ✓ Match: ${message.senderId} → ${message.receiverId}: "${message.text}"');
            }
            return match;
          }).toList();
          
          if (kDebugMode) {
            print('\n📨 Result: ${conversationMessages.length} messages in conversation');
            print('   Total messages in DB: ${allMessages.length}');
            if (conversationMessages.isEmpty && allMessages.isNotEmpty) {
              print('   ⚠️  WARNING: Messages exist but none match the conversation filter!');
            }
          }
          
          return conversationMessages;
        });
  }

  // Get conversation messages once
  Future<List<Message>> getConversationMessages(
    String userId1,
    String userId2,
  ) async {
    try {
      // Query all messages and filter to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_messagesCollection)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return Message.fromFirebaseMap(data, doc.id);
          })
          .where((message) =>
              (message.senderId == userId1 && message.receiverId == userId2) ||
              (message.senderId == userId2 && message.receiverId == userId1))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting conversation messages: $e');
      }
      return [];
    }
  }

  // Delete all messages
  Future<void> deleteAllMessages() async {
    try {
      final batch = _firestore.batch();
      final snapshots = await _firestore.collection(_messagesCollection).get();
      
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      if (kDebugMode) {
        print('All messages deleted from Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting messages: $e');
      }
      rethrow;
    }
  }

  // Delete conversation messages
  Future<void> deleteConversationMessages(String userId1, String userId2) async {
    try {
      final batch = _firestore.batch();
      final snapshots = await _firestore
          .collection(_messagesCollection)
          .where('senderId', whereIn: [userId1, userId2])
          .get();

      for (var doc in snapshots.docs) {
        final data = doc.data();
        final message = Message.fromFirebaseMap(data, doc.id);
        if ((message.senderId == userId1 && message.receiverId == userId2) ||
            (message.senderId == userId2 && message.receiverId == userId1)) {
          batch.delete(doc.reference);
        }
      }
      
      await batch.commit();
      if (kDebugMode) {
        print('Conversation messages deleted from Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting conversation messages: $e');
      }
      rethrow;
    }
  }

  // Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_messagesCollection).doc(messageId).delete();
      if (kDebugMode) {
        print('Message deleted from Firebase: $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message: $e');
      }
      rethrow;
    }
  }

  // Get all messages once (for offline support)
  Future<List<Message>> getAllMessages() async {
    try {
      final snapshot = await _firestore
          .collection(_messagesCollection)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Message.fromFirebaseMap(data, doc.id);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting messages: $e');
      }
      return [];
    }
  }

  // Update message read status
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection(_messagesCollection).doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message as read: $e');
      }
    }
  }
}


