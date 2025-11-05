// lib/scan_animal_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:image_picker/image_picker.dart';

// ML Kit Imports
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

// Firebase Imports for saving results
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// For copying asset -> file
import 'package:path_provider/path_provider.dart';

/// Helper: copy the model asset to a device file and return an ImageLabeler
// Helper: copy asset model to device file and return an initialized ImageLabeler
Future<ImageLabeler> createLabelerFromFileWithLogs({double confidenceThreshold = 0.7}) async {
  try {
    // 1) Load .tflite from flutter assets
    final data = await rootBundle.load('assets/ml/breed_model.tflite');
    final bytes = data.buffer.asUint8List();

    // 2) Write to a temp file on device
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/breed_model.tflite';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    final exists = await file.exists();
    final length = exists ? await file.length() : -1;
    print('DEBUG: Model copied to: $path  exists=$exists  size=$length');

    // 3) Create ImageLabeler using the modelPath string (no LocalModel object)
    final options = LocalLabelerOptions(
      modelPath: path,
      confidenceThreshold: confidenceThreshold,
    );

    final labeler = ImageLabeler(options: options);
    print('DEBUG: ImageLabeler initialized with modelPath: $path');

    return labeler;
  } catch (e, st) {
    print('ERROR in createLabelerFromFileWithLogs: $e\n$st');
    rethrow;
  }
}


class ScanAnimalScreen extends StatefulWidget {
  const ScanAnimalScreen({Key? key}) : super(key: key);

  @override
  State<ScanAnimalScreen> createState() => _ScanAnimalScreenState();
}

class _ScanAnimalScreenState extends State<ScanAnimalScreen> {
  ImageLabeler? _imageLabeler;
  List<String>? _labels; // Local labels text file
  File? _image; // The image file picked by the user
  String _predictionResult = "Select an image to scan...";
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final double _confidenceThreshold = 0.7; // Minimum confidence to accept a prediction

  // IMPORTANT: Local model asset path (kept for reference)
  static const String _localModelPath = 'assets/ml/breed_model.tflite';

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  @override
  void dispose() {
    _imageLabeler?.close(); // Close the ImageLabeler
    super.dispose();
  }

  // --- Model Loading (updated to use createLabelerFromFileWithLogs) ---
  Future<void> _loadModelAndLabels() async {
    setState(() {
      _isProcessing = true;
      _predictionResult = "Loading ML Kit model...";
    });
    try {
      // 1. Load labels (still needed to display breed names correctly)
      final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 2. Initialize ImageLabeler by copying the .tflite to device storage first
      _imageLabeler = await createLabelerFromFileWithLogs();

      print('ML Kit ImageLabeler initialized and labels loaded.');
      setState(() {
        _predictionResult = "Model ready! Select an image.";
      });
    } catch (e, st) {
      print('Failed to load ML Kit model or labels: $e\n$st');
      setState(() {
        _predictionResult = "Error loading ML Kit model: $e";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // --- Image Picking ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _predictionResult = "Image selected. Processing...";
          _isProcessing = true;
        });
        await _runInference(_image!);
      }
    } catch (e) {
      print('Image pick error: $e');
      setState(() {
        _predictionResult = 'Image pick failed: $e';
      });
    }
  }

  // --- Inference Logic ---
  Future<void> _runInference(File imageFile) async {
    if (_imageLabeler == null || _labels == null || _labels!.isEmpty) {
      setState(() {
        _predictionResult = "ML Kit model not loaded correctly. Please restart.";
        _isProcessing = false;
      });
      return;
    }

    try {
      // Create an InputImage from the file
      final inputImage = InputImage.fromFile(imageFile);

      // Process the image with ML Kit
      final List<ImageLabel> imageLabels = await _imageLabeler!.processImage(inputImage);

      String predictedBreed = "Unknown";
      double maxConfidence = 0.0; // Initialize to 0.0

      if (imageLabels.isNotEmpty) {
        // Find the label with the highest confidence
        ImageLabel topLabel = imageLabels.reduce((a, b) => a.confidence > b.confidence ? a : b);

        // Use topLabel.label
        predictedBreed = topLabel.label;
        maxConfidence = topLabel.confidence;

        // Optionally, check against your _labels list if mapping is needed
        if (!_labels!.contains(predictedBreed)) {
          print("Warning: ML Kit label '$predictedBreed' not found in local _labels list. (Model's internal labels might differ from local labels.txt)");
        }

        if (maxConfidence >= _confidenceThreshold) {
          setState(() {
            _predictionResult =
            "Breed: $predictedBreed\nConfidence: ${(maxConfidence * 100).toStringAsFixed(2)}%";
          });
          // Call function to save to Firestore & Storage
          _saveAnimalToFirestore(predictedBreed, maxConfidence, imageFile);
        } else {
          setState(() {
            _predictionResult =
            "Could not confidently identify breed (below ${(_confidenceThreshold * 100).toStringAsFixed(0)}% confidence).";
          });
        }
      } else {
        setState(() {
          _predictionResult = "No breed could be identified.";
        });
      }
    } catch (e, st) {
      print('Error during ML Kit inference: $e\n$st');
      setState(() {
        _predictionResult = "Error processing image with ML Kit: $e";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // --- Firebase Save Function ---
  Future<void> _saveAnimalToFirestore(String breed, double confidence, File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save animals.')),
      );
      return;
    }

    try {
      // 1. Upload image to Firebase Storage
      String fileName = 'animals/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // 2. Save data to Cloud Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('herd')
          .add({
        'breed': breed,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Animal saved to Firestore!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal saved to your herd!')),
      );
    } catch (e, st) {
      print('Error saving animal to Firebase: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save animal: $e')),
      );
    }
  }

  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Animal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Display Area
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: _image == null
                  ? Center(
                child: Text(
                  'No image selected.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image Picking Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Image'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Image'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Prediction Result Display
            _isProcessing
                ? const CircularProgressIndicator()
                : Text(
              _predictionResult,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _predictionResult.contains("Error") ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
