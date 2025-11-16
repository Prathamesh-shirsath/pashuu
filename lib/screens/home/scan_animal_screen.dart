// D:/flutter projects/pashuu/lib/screens/home/scan_animal_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanAnimalScreen extends StatefulWidget {
  const ScanAnimalScreen({super.key});

  @override
  State<ScanAnimalScreen> createState() => _ScanAnimalScreenState();
}

class _ScanAnimalScreenState extends State<ScanAnimalScreen> {
  File? _image;
  List<double>? _output;
  Interpreter? _interpreter;
  bool _loading = true;
  List<String>? _labels;

  @override
  void initState() {
    super.initState();
    loadModelAndLabels();
  }

  Future<void> loadModelAndLabels() async {
    await loadModel();
    await loadLabels();
    setState(() {
      _loading = false;
    });
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/breed_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> loadLabels() async {
    try {
      final labelsData =
      await DefaultAssetBundle.of(context).loadString('assets/ml/labels.txt');
      _labels = labelsData.split('\n');
      print('Labels loaded successfully');
    } catch (e) {
      print('Failed to load labels: $e');
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _loading = true;
        _image = File(pickedFile.path);
        _output = null;
      });
      classifyImage(_image!);
    }
  }

  Future<void> classifyImage(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      print('Interpreter or labels not initialized.');
      setState(() { _loading = false; });
      return;
    }
    img.Image? originalImage = img.decodeImage(imageFile.readAsBytesSync());
    if (originalImage == null) return;
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];
    img.Image resizedImage =
    img.copyResize(originalImage, width: inputWidth, height: inputHeight);
    var inputBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);
    var inputAsList = inputBytes.map((byte) => byte / 255.0).toList();
    final input = [
      List.generate(
          inputHeight,
              (y) => List.generate(inputWidth, (x) {
            final pixelIndex = (y * inputWidth + x) * 3;
            return [
              inputAsList[pixelIndex],
              inputAsList[pixelIndex + 1],
              inputAsList[pixelIndex + 2],
            ];
          }))
    ];
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    var output =
    List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);
    _interpreter!.run(input, output);
    setState(() {
      final results = output[0] as List;
      _output = results.map((e) => e as double).toList();
      _loading = false;
    });
  }

  Future<void> _saveToHerd(String label, double confidence, String imagePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save to your herd.')),
      );
      return;
    }
    if (_image == null) return;
    setState(() { _loading = true; });
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('herd_images')
          .child(user.uid)
          .child(fileName);
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();
      final herdCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('herd');
      await herdCollection.add({
        'name': label,
        'breed': label,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('$label added to My Herd!'),
        ),
      );
      _reset();
    } catch (e) {
      print('Failed to save to herd: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: Could not save animal.')),
      );
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _output = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pashu Scanner'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image == null)
                _buildInitialView()
              else
                _buildResultView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        const Icon(Icons.camera_alt_outlined, size: 100, color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          'Scan an Animal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Use your camera or select a photo from your gallery.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () => _getImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take a Photo'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(250, 50),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _getImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose from Gallery'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(250, 50),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    String topLabel = 'Unknown';
    double maxConfidence = 0.0;
    if (_output != null && _labels != null && _output!.isNotEmpty) {
      maxConfidence = _output!.reduce((a, b) => a > b ? a : b);
      int topIndex = _output!.indexOf(maxConfidence);
      if (topIndex < _labels!.length) {
        topLabel = _labels![topIndex];
      }
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(_image!),
          ),
        ),
        const SizedBox(height: 20),
        if (_output != null)
          Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Top Prediction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topLabel,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${(maxConfidence * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _saveToHerd(topLabel, maxConfidence, _image!.path),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add to My Herd'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Scan Another Image'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}