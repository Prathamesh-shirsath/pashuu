import 'package:flutter/material.dart';
import 'package:pashuu/screens/auth/login_screen.dart'; // Make sure the path is correct
import 'package:pashuu/theme.dart'; // Make sure the path is correct

void main() {
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
      home: const LoginScreen(), // The first screen the user sees
    );
  }
}
