// lib/screens/home/my_herd_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class MyHerdScreen extends StatefulWidget {
  const MyHerdScreen({super.key});

  @override
  State<MyHerdScreen> createState() => _MyHerdScreenState();
}

class _MyHerdScreenState extends State<MyHerdScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final double _borderRadius = 12.0;

  Future<void> _showEditNameDialog(DocumentSnapshot animalDoc) async {
    final TextEditingController nameController =
    TextEditingController(text: animalDoc['name']);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Animal Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter new name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  animalDoc.reference
                      .update({'name': nameController.text.trim()});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnimal(DocumentSnapshot animalDoc) async {
    try {
      final imageUrl = animalDoc['imageUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
      await animalDoc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red, content: Text('Animal removed.')),
      );
    } catch (e) {
      print('Error deleting animal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove animal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Herd'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _currentUser == null
          ? const Center(
        child: Text('Please log in to see your herd.'),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('herd')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your herd is empty.'));
          }

          final herdDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: herdDocs.length,
            itemBuilder: (context, index) {
              final animalDoc = herdDocs[index];

              return Dismissible(
                key: Key(animalDoc.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteAnimal(animalDoc);
                },
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildAnimalCard(
                  context,
                  animalDoc,
                  primaryColor,
                  onSurfaceColor,
                  _borderRadius,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimalCard(
      BuildContext context,
      DocumentSnapshot animalDoc,
      Color primaryColor,
      Color onSurfaceColor,
      double borderRadius,
      ) {
    final animalData = animalDoc.data() as Map<String, dynamic>;
    final imageUrl = animalData['imageUrl'] ?? '';
    final name = animalData['name'] ?? 'Unnamed';
    final breed = animalData['breed'] ?? 'Unknown Breed';
    final confidence = animalData['confidence'] ?? 0.0;
    final timestamp = animalData['timestamp'] as Timestamp?;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () {
          _showEditNameDialog(animalDoc);
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (name.toLowerCase() != breed.toLowerCase())
                      Text(
                        breed,
                        style: TextStyle(
                            fontSize: 14,
                            color: onSurfaceColor.withOpacity(0.8)),
                      ),
                    Text(
                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 14,
                          color: onSurfaceColor.withOpacity(0.7)),
                    ),
                    if (timestamp != null)
                      Text(
                        'Added: ${DateFormat('MMM d, yyyy').format(timestamp.toDate())}',
                        style: TextStyle(
                            fontSize: 12,
                            color: onSurfaceColor.withOpacity(0.5)),
                      ),
                  ],
                ),
              ),
              Icon(Icons.edit,
                  color: onSurfaceColor.withOpacity(0.5),
                  size: 20),
            ],
          ),
        ),
      ),
    );
  }
}