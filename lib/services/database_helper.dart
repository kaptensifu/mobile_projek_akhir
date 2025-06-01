import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:projek_akhir/models/user_model.dart';
import 'package:projek_akhir/models/competition_model.dart';

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
    
    // For development: uncomment this line to always recreate database
    // await deleteDatabase(path);
    
    return await openDatabase(
      path,
      version: 3, // Increment version to trigger upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');
    
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        favorite_driver_id TEXT,
        profile_image TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE competitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        circuit_id TEXT NOT NULL,
        circuit_name TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        created_by INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');
    
    print('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 3) {
      // Previous upgrade logic for competitions table
      try {
        List<Map<String, dynamic>> existingData = await db.query('competitions');
        print('Found ${existingData.length} existing competitions');
        
        await db.execute('DROP TABLE IF EXISTS competitions');
        
        await db.execute('''
          CREATE TABLE competitions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            circuit_id TEXT NOT NULL,
            circuit_name TEXT NOT NULL,
            start_time INTEGER NOT NULL,
            created_by INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (created_by) REFERENCES users (id)
          )
        ''');
        
        for (var competition in existingData) {
          try {
            await db.insert('competitions', {
              'title': competition['title'] ?? 'Migrated Competition',
              'description': competition['description'],
              'circuit_id': 'unknown',
              'circuit_name': 'Unknown Circuit',
              'start_time': competition['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
              'created_by': competition['created_by'] ?? 1,
              'created_at': competition['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
              'updated_at': competition['updated_at'] ?? DateTime.now().millisecondsSinceEpoch,
            });
          } catch (e) {
            print('Error migrating competition: $e');
          }
        }
        
      } catch (e) {
        print('Error during database upgrade: $e');
        await db.execute('DROP TABLE IF EXISTS competitions');
        await db.execute('''
          CREATE TABLE competitions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            circuit_id TEXT NOT NULL,
            circuit_name TEXT NOT NULL,
            start_time INTEGER NOT NULL,
            created_by INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (created_by) REFERENCES users (id)
          )
        ''');
      }
    }
    
    if (oldVersion < 3) {
      // Add profile_image column to users table
      try {
        await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
        print('Added profile_image column to users table');
      } catch (e) {
        print('Error adding profile_image column: $e');
      }
    }
  }

  // Method to completely reset database (for development)
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'f1_app.db');
    await deleteDatabase(path);
    _database = null;
    print('Database deleted and will be recreated on next access');
  }

  // Method to check current database structure (for debugging)
  Future<void> checkDatabaseStructure() async {
    final db = await database;
    
    print('=== DATABASE STRUCTURE ===');
    
    // Check competitions table structure
    try {
      final result = await db.rawQuery("PRAGMA table_info(competitions)");
      print('Competitions table columns:');
      for (var column in result) {
        print('  - ${column['name']}: ${column['type']} (nullable: ${column['notnull'] == 0})');
      }
    } catch (e) {
      print('Error checking competitions table: $e');
    }
    
    // Check users table structure
    try {
      final result = await db.rawQuery("PRAGMA table_info(users)");
      print('Users table columns:');
      for (var column in result) {
        print('  - ${column['name']}: ${column['type']} (nullable: ${column['notnull'] == 0})');
      }
    } catch (e) {
      print('Error checking users table: $e');
    }
    
    print('=== END DATABASE STRUCTURE ===');
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

  Future<bool> updateFavoriteDriver(int userId, String? driverId) async {
  final db = await database;
  
  try {
    final result = await db.update(
      'users',
      {
        'favorite_driver_id': driverId?.isEmpty == true ? null : driverId,
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

  Future<bool> updateProfileImage(int userId, String imagePath) async {
    final db = await database;
    
    try {
      final result = await db.update(
        'users',
        {
          'profile_image': imagePath,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile({
    required int userId,
    String? username,
    String? email,
    String? profileImage,
  }) async {
    final db = await database;
    
    try {
      Map<String, dynamic> updates = {
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (username != null) updates['username'] = username;
      if (email != null) updates['email'] = email;
      if (profileImage != null) updates['profile_image'] = profileImage;
      
      final result = await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      return result > 0;
    } catch (e) {
      print('Error updating user profile: $e');
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

  // Competition operations (unchanged)
  Future<Competition?> createCompetition({
    required String title,
    String? description,
    required String circuitId,
    required String circuitName,
    required DateTime startTime,
    required int createdBy,
  }) async {
    final db = await database;
    
    try {
      final now = DateTime.now();
      
      final id = await db.insert('competitions', {
        'title': title,
        'description': description,
        'circuit_id': circuitId,
        'circuit_name': circuitName,
        'start_time': startTime.millisecondsSinceEpoch,
        'created_by': createdBy,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });

      return Competition(
        id: id,
        title: title,
        description: description,
        circuitId: circuitId,
        circuitName: circuitName,
        startTime: startTime,
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      print('Error creating competition: $e');
      return null;
    }
  }

  Future<List<Competition>> getAllCompetitions() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'competitions',
        orderBy: 'start_time ASC',
      );

      return List.generate(maps.length, (i) {
        return Competition.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting competitions: $e');
      return [];
    }
  }

  Future<Competition?> getCompetitionById(int id) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'competitions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Competition.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting competition by id: $e');
      return null;
    }
  }

  Future<bool> updateCompetition(Competition competition) async {
    final db = await database;
    
    try {
      final result = await db.update(
        'competitions',
        {
          'title': competition.title,
          'description': competition.description,
          'circuit_id': competition.circuitId,
          'circuit_name': competition.circuitName,
          'start_time': competition.startTime.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [competition.id],
      );
      
      return result > 0;
    } catch (e) {
      print('Error updating competition: $e');
      return false;
    }
  }

  Future<bool> deleteCompetition(int id) async {
    final db = await database;
    
    try {
      final result = await db.delete(
        'competitions',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return result > 0;
    } catch (e) {
      print('Error deleting competition: $e');
      return false;
    }
  }

  Future<List<Competition>> getCompetitionsByUser(int userId) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'competitions',
        where: 'created_by = ?',
        whereArgs: [userId],
        orderBy: 'start_time ASC',
      );

      return List.generate(maps.length, (i) {
        return Competition.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting competitions by user: $e');
      return [];
    }
  }
}