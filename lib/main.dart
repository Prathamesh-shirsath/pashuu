// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pashuu/screens/auth/auth_gate.dart'; // We will create this file next
import 'package:pashuu/theme.dart';

// Add these for web configuration
import 'package:flutter/foundation.dart' show kIsWeb;



void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for the correct platform
  if (kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyA0DodXEj9oUPhp4Xrz5xQl5xTTlB-Sx5g", // From firebaseConfig
        authDomain: "pashuapp-9363b.firebaseapp.com", // From firebaseConfig
        projectId: "pashuapp-9363b", // From firebaseConfig
        storageBucket: "pashuapp-9363b.firebasestorage.app", // From firebaseConfig
        messagingSenderId: "988478593263", // From firebaseConfig
        appId: "1:988478593263:web:b91b958f9c607366c2a31a" // From firebaseConfig

    ));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PashuKalyan',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // Changed from LoginScreen to AuthGate
    );
  }
}
