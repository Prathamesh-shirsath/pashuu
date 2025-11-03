// lib/screens/auth/signup_screen.dart

import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Changed from Phone to Email
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;

  // New function to handle sign-up logic
  Future<void> createUserWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms of Service and Privacy Policy.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show a loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Use Firebase to create a new user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword( // <-- Store the result
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // --- THIS IS THE NEW, IMPORTANT LINE ---
      // Update the user's profile with the name from the text field
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      // ------------------------------------

      // The AuthGate will automatically navigate to the home screen on success.
      if (mounted) Navigator.pop(context); // Pop loading dialog
      if (mounted) Navigator.pop(context); // Pop SignUpScreen

    } on FirebaseAuthException catch (e) {
      // Pop the loading dialog
      if (mounted) Navigator.pop(context);

      // Show a more specific error message
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(Icons.eco, color: Theme.of(context).primaryColor, size: 50),
                const SizedBox(height: 20),
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Full Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController, // Using Email controller
                  decoration: const InputDecoration(hintText: 'Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'Please enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() { _isPasswordVisible = !_isPasswordVisible; });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() { _agreeToTerms = value ?? false; });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: createUserWithEmailAndPassword, // Call the new sign-up function
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context), // Go back to login
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
