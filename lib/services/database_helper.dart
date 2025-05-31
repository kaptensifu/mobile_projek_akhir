import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:projek_akhir/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'f1_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        favorite_driver_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE competitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        created_by INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');
  }

  // Password encryption
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User operations
  Future<User?> createUser(String username, String email, String password) async {
    final db = await database;
    
    try {
      final passwordHash = _hashPassword(password);
      final now = DateTime.now();
      
      final id = await db.insert('users', {
        'username': username,
        'email': email,
        'password_hash': passwordHash,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });

      return User(
        id: id,
        username: username,
        email: email,
        passwordHash: passwordHash,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<User?> authenticateUser(String username, String password) async {
    final db = await database;
    
    try {
      final passwordHash = _hashPassword(password);
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ? AND password_hash = ?',
        whereArgs: [username, passwordHash],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  Future<bool> updateFavoriteDriver(int userId, String driverId) async {
    final db = await database;
    
    try {
      final result = await db.update(
        'users',
        {
          'favorite_driver_id': driverId,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('Error updating favorite driver: $e');
      return false;
    }
  }

  Future<bool> isUsernameExists(String username) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}