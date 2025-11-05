// lib/screens/home/my_herd_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
// Removed direct import of 'package:pashuu/theme.dart' as colors will be derived from Theme.of(context)

class MyHerdScreen extends StatefulWidget {
  const MyHerdScreen({super.key});

  @override
  State<MyHerdScreen> createState() => _MyHerdScreenState();
}

class _MyHerdScreenState extends State<MyHerdScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final double _borderRadius = 12.0; // Consistent border radius from settings screen

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Herd'),
        backgroundColor: primaryColor, // Consistent with settings screen
        foregroundColor: Colors.white, // Consistent with settings screen
        elevation: 4, // Consistent with settings screen
      ),
      body: _currentUser == null
          ? Center(
        child: Text(
          'Please log in to see your herd.',
          style: TextStyle(fontSize: 16, color: onSurfaceColor.withOpacity(0.7)),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        // Listen for real-time updates from the 'herd' sub-collection
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('herd')
            .orderBy('timestamp', descending: true) // Show newest first
            .snapshots(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}',
                    style: TextStyle(color: onSurfaceColor.withOpacity(0.7))));
          }

          // Handle no data state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grass, size: 80, color: onSurfaceColor.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('Your herd is empty.',
                      style: TextStyle(fontSize: 18, color: onSurfaceColor.withOpacity(0.8))),
                  Text('Use the "Scan Animal" feature to add animals.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: onSurfaceColor.withOpacity(0.6))),
                ],
              ),
            );
          }

          // Display the list of animals
          final herdDocs = snapshot.data!.docs;

          return SingleChildScrollView( // Added SingleChildScrollView for consistent padding
            padding: const EdgeInsets.all(16.0), // Consistent with settings screen
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('My Animals', onSurfaceColor),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Important
                  itemCount: herdDocs.length,
                  itemBuilder: (context, index) {
                    final animalData = herdDocs[index].data() as Map<String, dynamic>;
                    final timestamp = animalData['timestamp'] as Timestamp?;

                    return _buildAnimalCard(
                      context,
                      animalData['imageUrl'],
                      animalData['breed'], // Assuming 'breed' is the correct field
                      animalData['confidence'],
                      timestamp,
                      primaryColor,
                      onSurfaceColor,
                      _borderRadius,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build section titles, consistent with settings screen
  Widget _buildSectionTitle(String title, Color onSurfaceColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, top: 10.0, left: 5.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor.withOpacity(0.8), // Muted color for section title
        ),
      ),
    );
  }

  // Reusable widget to build each animal card, inspired by settings screen's card
  Widget _buildAnimalCard(
      BuildContext context,
      String imageUrl,
      String breedName,
      double confidence,
      Timestamp? timestamp,
      Color primaryColor,
      Color onSurfaceColor,
      double borderRadius,
      ) {
    return Card(
      elevation: 3, // Consistent with settings screen cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.only(bottom: 15.0), // Spacing between cards
      child: InkWell(
        onTap: () {
          // TODO: Implement navigation to Animal Detail screen or other action
          // Removed snackbar as per request
        },
        borderRadius: BorderRadius.circular(borderRadius), // Apply radius to InkWell's ripple
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              // Image on the left (CircleAvatar for a softer look, like profile pic)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: primaryColor.withOpacity(0.1),
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback to an icon if image fails to load
                  print('Error loading image: $exception');
                },
                child: imageUrl.isEmpty
                    ? Icon(Icons.pets, color: primaryColor.withOpacity(0.7), size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              // Details in the middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breedName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: onSurfaceColor, // Main text color
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 14, color: onSurfaceColor.withOpacity(0.7)),
                    ),
                    if (timestamp != null)
                      Text(
                        'Added: ${DateFormat('MMM d, yyyy').format(timestamp.toDate())}',
                        style: TextStyle(fontSize: 12, color: onSurfaceColor.withOpacity(0.5)),
                      ),
                  ],
                ),
              ),
              // Trailing arrow on the right
              Icon(Icons.arrow_forward_ios, color: onSurfaceColor.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}