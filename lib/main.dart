import 'package:flutter/material.dart';
import 'package:projek_akhir/pages/home_page.dart';
import 'package:projek_akhir/pages/login_page.dart';
import 'package:projek_akhir/auth/auth_wrapper.dart';
import 'package:projek_akhir/services/database_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projek_akhir/pages/profile_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Define the background notification response handler as a top-level function
@pragma('vm:entry-point') // Required for background execution
void notificationBackgroundHandler(NotificationResponse notificationResponse) async {
  // This callback runs in its own isolate when the app is in the background/terminated.
  // Be careful with what you do here, as it might not have full access to Flutter context.
  debugPrint('background notification payload: ${notificationResponse.payload}');

  // You generally cannot navigate directly from here without specific setup
  // because the UI context might not be available.
  // For example, if you wanted to navigate, you'd typically need to
  // store the payload and process it when the app resumes/opens.
  // For this specific use case (prompting to set favorite driver),
  // simply logging or handling data in the background might be sufficient.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset database saat development
  // await resetDatabaseForDevelopment();

  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher'); // Change app_icon to ic_launcher

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        debugPrint('notification payload: ${notificationResponse.payload}');
        if (notificationResponse.payload == 'favorite_driver_prompt') {
          // Navigate to ProfilePage when the notification is tapped
          // This part runs when the app is in the foreground or opened from a notification
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler, // Use the top-level function here
  );

  runApp(const MyApp());
}

Future<void> resetDatabaseForDevelopment() async {
  final dbHelper = DatabaseHelper();
  await dbHelper.resetDatabase();
  print('Database has been reset');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula 1 App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorKey: navigatorKey,
      home: AuthWrapper(
        child: HomePage(),
      ),
      routes: {
        '/home': (context) => AuthWrapper(child: HomePage()),
        '/login': (context) => LoginPage(),
      },
    );
  }
}