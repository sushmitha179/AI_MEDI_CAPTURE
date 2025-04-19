import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view results')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Scan Results")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('scans')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No scan history found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final text = data['text'] ?? 'No text';
              final timestamp = data['timestamp'] as Timestamp?;
              final timeStr = timestamp != null
                  ? timestamp.toDate().toLocal().toString()
                  : 'No time';

              return ExpansionTile(
                title: Text(
                  text.length > 50 ? '${text.substring(0, 50)}...' : text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(timeStr),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(text),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
