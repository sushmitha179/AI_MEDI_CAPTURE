import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color(0xFF4e2a6e), // Your preferred color
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF4e2a6e).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.home, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Welcome to Home Screen!',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Quick Access Cards or Buttons
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust crossAxisCount based on available width
                  int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return HomeCard(
                        icon: _getIconForCard(index),
                        label: _getLabelForCard(index),
                        onTap: () {
                          // Navigate to respective screen
                          _navigateToScreen(index, context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to return icon based on index
  IconData _getIconForCard(int index) {
    switch (index) {
      case 0:
        return Icons.document_scanner;
      case 1:
        return Icons.history;
      case 2:
        return Icons.notifications;
      case 3:
        return Icons.settings;
      default:
        return Icons.help;
    }
  }

  // Helper method to return label based on index
  String _getLabelForCard(int index) {
    switch (index) {
      case 0:
        return 'Scan Now';
      case 1:
        return 'History';
      case 2:
        return 'Notifications';
      case 3:
        return 'Settings';
      default:
        return 'Unknown';
    }
  }

  // Navigate to different screens based on the card tapped
  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/scan');
        break;
      case 1:
        Navigator.pushNamed(context, '/history');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
      default:
        break;
    }
  }
}

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onTap;

  const HomeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Ensures cards are square
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Color(0xFF4e2a6e)),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
