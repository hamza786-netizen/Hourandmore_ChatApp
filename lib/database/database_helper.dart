import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        sender TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  // Insert a message
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  // Get all messages ordered by timestamp
  Future<List<Message>> getAllMessages() async {
    final db = await database;
    final result = await db.query(
      'messages',
      orderBy: 'timestamp ASC',
    );

    return result.map((map) => Message.fromMap(map)).toList();
  }

  // Delete a message
  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all messages
  Future<int> deleteAllMessages() async {
    final db = await database;
    return await db.delete('messages');
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}


