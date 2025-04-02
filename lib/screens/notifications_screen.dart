import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color(0xFF4e2a6e),
      ),
      body: Center(child: Text("Your notifications will be shown here")),
    );
  }
}
