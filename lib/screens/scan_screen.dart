import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Now'),
        backgroundColor: Color(0xFF4e2a6e),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Implement your scan logic here
            print("Scan button pressed");
          },
          child: Text("Start Scanning"),
        ),
      ),
    );
  }
}
