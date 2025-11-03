
// lib/screens/home/my_herd_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pashuu/theme.dart';

class MyHerdScreen extends StatefulWidget {
  const MyHerdScreen({super.key});

  @override
  State<MyHerdScreen> createState() => _MyHerdScreenState();
}

class _MyHerdScreenState extends State<MyHerdScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Herd')),
      body: _currentUser == null
          ? const Center(child: Text('Please log in to see your herd.'))
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
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          // Handle no data state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grass, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your herd is empty.', style: TextStyle(fontSize: 18)),
                  Text('Use the "Scan Animal" feature to add animals.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Display the list of animals
          final herdDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: herdDocs.length,
            itemBuilder: (context, index) {
              final animalData = herdDocs[index].data() as Map<String, dynamic>;
              final timestamp = animalData['timestamp'] as Timestamp?;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // Image on the left
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.network(
                        animalData['imageUrl'],
                        fit: BoxFit.cover,
                        // Add a loading builder for better UX
                        loadingBuilder: (context, child, progress) {
                          return progress == null ? child : const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, color: Colors.red, size: 40);
                        },
                      ),
                    ),
                    // Details on the right
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animalData['breedName'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${(animalData['confidence'] * 100).toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 16, color: AppTheme.lightTextColor),
                            ),
                            const SizedBox(height: 8),
                            if (timestamp != null)
                              Text(
                                DateFormat('MMM d, yyyy').format(timestamp.toDate()), // Format the date
                                style: TextStyle(fontSize: 14, color: AppTheme.lightTextColor),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
