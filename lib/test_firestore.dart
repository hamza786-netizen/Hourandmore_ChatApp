// TEMPORARY TEST FILE - Delete after debugging
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreTest {
  static Future<void> testConnection() async {
    try {
      debugPrint('🧪 Testing Firestore connection...');
      
      final firestore = FirebaseFirestore.instance;
      
      // Try to read all messages
      final snapshot = await firestore.collection('messages').get();
      
      debugPrint('✅ Firestore connected!');
      debugPrint('   Total messages in database: ${snapshot.docs.length}');
      
      // Print all messages
      for (var doc in snapshot.docs) {
        final data = doc.data();
        debugPrint('\n   Message ${doc.id}:');
        debugPrint('      senderId: ${data['senderId']}');
        debugPrint('      receiverId: ${data['receiverId']}');
        debugPrint('      text: ${data['text']}');
        debugPrint('      senderEmail: ${data['senderEmail']}');
      }
      
    } catch (e) {
      debugPrint('❌ Firestore test failed: $e');
    }
  }
}


