import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import generated Firebase options
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart'; // Import HomeScreen
import 'screens/scan_screen.dart'; // Import ScanScreen
import 'screens/history_screen.dart'; // Import HistoryScreen
import 'screens/notifications_screen.dart'; // Import NotificationsScreen
import 'screens/settings_screen.dart'; // Import SettingsScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions
              .currentPlatform, // Use Firebase options for all platforms
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'AI Text Digitizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Initial route set to LoginScreen
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/home': (context) => HomeScreen(), // HomeScreen route
        '/scan': (context) => ScanScreen(), // ScanScreen route
        '/history': (context) => HistoryScreen(), // HistoryScreen route
        '/notifications':
            (context) => NotificationsScreen(), // NotificationsScreen route
        '/settings': (context) => SettingsScreen(), // SettingsScreen route
      },
    );
  }
}
