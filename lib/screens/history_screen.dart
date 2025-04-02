import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Color(0xFF4e2a6e),
      ),
      body: Center(
        child: Text("History of Scanned Documents will be shown here"),
      ),
    );
  }
}
