
// lib/screens/home/scan_animal_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pashuu/theme.dart'; // Using your AppTheme

class ScanAnimalScreen extends StatefulWidget {
  const ScanAnimalScreen({super.key});

  @override
  State<ScanAnimalScreen> createState() => _ScanAnimalScreenState();
}

class _ScanAnimalScreenState extends State<ScanAnimalScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isDetecting = false;
  String? _detectionResult;
  double? _confidence;

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 800);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _resetDetectionState();
      });
    }
  }

  Future<void> _uploadFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _resetDetectionState();
      });
    }
  }

  void _resetDetectionState() {
    setState(() {
      _detectionResult = null;
      _confidence = null;
    });
  }

  /// This is the core new logic
  Future<void> _detectAndSaveBreed() async {
    if (_selectedImage == null) return;

    setState(() { _isDetecting = true; });

    // --- 1. SIMULATE MODEL PREDICTION (Placeholder) ---
    await Future.delayed(const Duration(seconds: 2));
    final predictedBreed = "Gir"; // Simulated result
    final predictionConfidence = 0.92; // Simulated result

    // --- 2. UPLOAD IMAGE TO FIREBASE STORAGE ---
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { // Safety check
      setState(() { _isDetecting = false; });
      return;
    }

    try {
      // Create a unique file name for the image
      final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('animal_images/$fileName');

      // Upload the file
      final uploadTask = await storageRef.putFile(_selectedImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // --- 3. SAVE DATA TO FIRESTORE ---
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('herd')
          .add({
        'breedName': predictedBreed,
        'confidence': predictionConfidence,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(), // Use server time for consistency
      });

      // Update UI with results
      setState(() {
        _detectionResult = predictedBreed;
        _confidence = predictionConfidence;
        _isDetecting = false;
      });

    } catch (e) {
      setState(() { _isDetecting = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Animal Breed')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image Display Area (no changes) ---
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Center(
                child: _selectedImage == null
                    ? Icon(Icons.image_outlined, size: 80, color: AppTheme.lightTextColor)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 300),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // --- Action Buttons (no changes) ---
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: _captureImage, icon: const Icon(Icons.camera_alt), label: const Text('Capture'))),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton.icon(onPressed: _uploadFile, icon: const Icon(Icons.upload_file), label: const Text('Upload'))),
              ],
            ),
            const SizedBox(height: 32),
            // --- Detect Button ---
            ElevatedButton(
              onPressed: (_selectedImage != null && !_isDetecting) ? _detectAndSaveBreed : null, // Calls the new function
              child: _isDetecting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Detect and Save Breed'),
            ),
            const SizedBox(height: 32),
            // --- Results Display Section (no changes) ---
            if (_detectionResult != null && _confidence != null)
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    // This widget remains the same
    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved to Your Herd', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Breed:', style: TextStyle(fontSize: 18)),
                Text(_detectionResult!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Confidence:', style: TextStyle(fontSize: 18)),
                Text('${(_confidence! * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
