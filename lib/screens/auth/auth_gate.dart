// lib/screens/auth/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pashuu/screens/auth/login_screen.dart';import 'package:pashuu/screens/main_navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Listen to the authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the snapshot has data, it means the user is logged in
          if (snapshot.hasData) {
            // Show the main app screen
            return const MainNavigationScreen();
          } else {
            // Otherwise, show the login screen
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
