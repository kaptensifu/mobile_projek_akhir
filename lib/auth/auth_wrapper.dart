import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/session_manager.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/services/database_helper.dart'; // Import DatabaseHelper
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import this
import 'dart:async'; // Import for Timer

// Get the instance from main.dart
import '../main.dart'; // Assuming main.dart is in the parent directory

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Timer? _notificationTimer; // Declare a Timer
  bool _notificationsEnabled = false; // To track if notifications are enabled

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _requestNotificationPermissions(); // Request permissions on startup
  }

  @override
  void dispose() {
    _notificationTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _requestNotificationPermissions() async {
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // For iOS
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    setState(() {
      _notificationsEnabled = result ?? false; // Update the state based on permission
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final sessionManager = await SessionManager.getInstance();
      final isLoggedIn = sessionManager.isLoggedIn();

      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });

      if (isLoggedIn) {
        _startFavoriteDriverCheckTimer(); // Start timer if logged in
      }
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  void _startFavoriteDriverCheckTimer() {
    // Cancel any existing timer to avoid duplicates
    _notificationTimer?.cancel();

    // Start a periodic timer that runs every 2 minutes
    _notificationTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      if (!_notificationsEnabled) {
        print('Notifications not enabled, skipping check.');
        return;
      }

      final prefs = await SessionManager.getInstance();
      final userId = prefs.getCurrentUserId();

      if (userId != null) {
        final user = await DatabaseHelper().getUserById(userId);
        if (user != null && (user.favoriteDriverId == null || user.favoriteDriverId!.isEmpty)) {
          // User is logged in but hasn't chosen a favorite driver
          _showFavoriteDriverNotification();
        } else {
          // If a favorite driver is chosen, we can cancel the timer
          _notificationTimer?.cancel();
        }
      } else {
        // If somehow not logged in (should be caught by AuthWrapper), cancel timer
        _notificationTimer?.cancel();
      }
    });
  }

  Future<void> _showFavoriteDriverNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'favorite_driver_channel', // id
      'Favorite Driver Reminders', // name
      channelDescription: 'Reminders to set your favorite F1 driver', // description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: 'ic_launcher', // Make sure this matches your app icon name in drawable
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Choose Your Favorite Driver!', // Title
      'Don\'t miss out! Select your favorite Formula 1 driver in your profile.', // Body
      platformChannelSpecifics,
      payload: 'favorite_driver_prompt', // Custom payload for handling taps
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.red[700]!, Colors.red[900]!],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_motorsports,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _isLoggedIn ? widget.child : const LoginPage();
  }
}