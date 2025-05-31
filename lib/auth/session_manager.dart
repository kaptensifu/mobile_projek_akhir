import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir/models/user_model.dart';
import 'package:projek_akhir/services/database_helper.dart';

class SessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyFirstTimeUser = 'first_time_user';

  static SessionManager? _instance;
  static SharedPreferences? _prefs;

  static Future<SessionManager> getInstance() async {
    _instance ??= SessionManager._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  SessionManager._();

  // Login user and save session
  Future<bool> loginUser(User user) async {
    try {
      await _prefs!.setInt(_keyUserId, user.id!);
      await _prefs!.setString(_keyUsername, user.username);
      await _prefs!.setString(_keyEmail, user.email);
      await _prefs!.setBool(_keyIsLoggedIn, true);
      return true;
    } catch (e) {
      print('Error saving user session: $e');
      return false;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs!.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  int? getCurrentUserId() {
    if (!isLoggedIn()) return null;
    return _prefs!.getInt(_keyUserId);
  }

  // Get current username
  String? getCurrentUsername() {
    if (!isLoggedIn()) return null;
    return _prefs!.getString(_keyUsername);
  }

  // Get current email
  String? getCurrentEmail() {
    if (!isLoggedIn()) return null;
    return _prefs!.getString(_keyEmail);
  }

  // Get current user from database
  Future<User?> getCurrentUser() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    
    final dbHelper = DatabaseHelper();
    return await dbHelper.getUserById(userId);
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await _prefs!.remove(_keyUserId);
      await _prefs!.remove(_keyUsername);
      await _prefs!.remove(_keyEmail);
      await _prefs!.setBool(_keyIsLoggedIn, false);
      return true;
    } catch (e) {
      print('Error logging out user: $e');
      return false;
    }
  }

  // Check if this is first time user opens the app
  bool isFirstTimeUser() {
    return _prefs!.getBool(_keyFirstTimeUser) ?? true;
  }

  // Set first time user flag
  Future<void> setFirstTimeUser(bool isFirstTime) async {
    await _prefs!.setBool(_keyFirstTimeUser, isFirstTime);
  }

  // Clear all session data
  Future<bool> clearSession() async {
    try {
      await _prefs!.clear();
      return true;
    } catch (e) {
      print('Error clearing session: $e');
      return false;
    }
  }

  // Update session when user data changes
  Future<bool> updateSession(User user) async {
    if (!isLoggedIn()) return false;
    
    try {
      await _prefs!.setString(_keyUsername, user.username);
      await _prefs!.setString(_keyEmail, user.email);
      return true;
    } catch (e) {
      print('Error updating session: $e');
      return false;
    }
  }
}