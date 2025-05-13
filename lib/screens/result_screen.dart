import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final String? recognizedText;

  const ResultScreen({super.key, this.recognizedText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.recognizedText != null &&
          widget.recognizedText!.trim().isNotEmpty) {
        _showFullTextDialog(context, widget.recognizedText!, 'N/A', 'Just Now');
      }
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Scans')),
        body: const Center(child: Text('Please log in to view your scans.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 AI Scan History'),
        backgroundColor: const Color(0xFF4E2A6E),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '🔍 Search scanned text...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No scans found.'));
                }

                final allScans = snapshot.data!.docs;
                final filteredScans = allScans.where((scan) {
                  final text = (scan['text'] ?? '').toString().toLowerCase();
                  return text.contains(_searchQuery);
                }).toList();

                if (filteredScans.isEmpty) {
                  return const Center(child: Text('No matching results.'));
                }

                return ListView.builder(
                  itemCount: filteredScans.length,
                  itemBuilder: (context, index) {
                    final scan = filteredScans[index];
                    final text = scan['text'] ?? '';
                    final timestamp =
                        (scan['timestamp'] as Timestamp?)?.toDate();
                    final formattedDate = timestamp != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
                        : 'Unknown';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.document_scanner_outlined,
                              color: Color(0xFF4E2A6E)),
                          title: Text(
                            text.length > 50
                                ? '${text.substring(0, 50)}...'
                                : text,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(formattedDate),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showFullTextDialog(
                            context,
                            text,
                            scan.id,
                            formattedDate,
                          ),
                          onLongPress: () =>
                              _confirmDeleteScan(context, scan.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullTextDialog(
      BuildContext context, String text, String scanId, String? timestamp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📄 Recognized Text'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Text:\n$text"),
              const SizedBox(height: 8),
              Text("Timestamp: $timestamp"),
              const SizedBox(height: 8),
              Text("Scan ID: $scanId"),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(text),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteScan(BuildContext context, String scanId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🗑️ Delete Scan"),
        content: const Text("Are you sure you want to delete this scan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('scans')
                    .doc(scanId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Scan deleted.")),
                );
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
