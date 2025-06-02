import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_provider.dart'; // Create this provider class

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? userEmail;
  String appVersion = "";
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email;
    _loadAppVersion();
    _loadNotificationPref();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = '${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = value;
      prefs.setBool('notifications', value);
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: const Text("Logged in as"),
              subtitle: Text(userEmail ?? "Not available"),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.deepPurple),
              title: const Text("App Version"),
              subtitle: Text(appVersion),
            ),
          ),
          const SizedBox(height: 10),

          // Dark mode toggle
          Card(
            elevation: 2,
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.deepPurple),
              title: const Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 10),

          // Notifications toggle
          Card(
            elevation: 2,
            child: SwitchListTile(
              secondary:
                  const Icon(Icons.notifications, color: Colors.deepPurple),
              title: const Text("Notifications"),
              value: notificationsEnabled,
              onChanged: _toggleNotification,
            ),
          ),
          const SizedBox(height: 10),

          Card(
            color: Colors.red.shade50,
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
