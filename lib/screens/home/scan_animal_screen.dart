import 'package:flutter/material.dart';

class ScanAnimalScreen extends StatefulWidget {
  const ScanAnimalScreen({super.key});

  @override
  State<ScanAnimalScreen> createState() => _ScanAnimalScreenState();
}

class _ScanAnimalScreenState extends State<ScanAnimalScreen> {
  bool _isAnalyzing = false;

  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });
    // Simulate network request
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isAnalyzing = false;
        // Show result dialog or navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis Complete: Holstein Friesian')),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Animal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Text(
              'Add a photo to identify your animal',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose how to add an animal\'s photo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 60),
            OutlinedButton.icon(
              onPressed: () {
                // Logic to upload from gallery
              },
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload From Gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Logic to open camera and take picture
                _startAnalysis();
              },
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              label: const Text('Capture Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const Spacer(),
            if (_isAnalyzing)
              Column(
                children: [
                  const Text('Analyzing Image...'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
