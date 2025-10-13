class Message {
  final int? id;
  final String text;
  final String sender; // 'user1' or 'user2'
  final DateTime timestamp;

  Message({
    this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  // Convert Message to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Create Message from Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      text: map['text'] as String,
      sender: map['sender'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}


