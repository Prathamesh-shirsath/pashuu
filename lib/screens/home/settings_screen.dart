// lib/screens/home/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Use user's email if available
          _buildProfileCard(context, user?.displayName ?? 'Anonymous', user?.email ?? 'No email available'),
          const SizedBox(height: 20),
          _buildSectionHeader('Preferences'),
          _buildSettingsTile(context, 'Notifications', Icons.notifications_none),
          _buildSettingsTile(context, 'Language', Icons.language),
          const SizedBox(height: 20),
          _buildSectionHeader('Support & Legal'),
          _buildSettingsTile(context, 'Medical Support', Icons.medical_services_outlined),
          _buildSettingsTile(context, 'Privacy Policy', Icons.privacy_tip_outlined),
          _buildSettingsTile(context, 'Terms of Service', Icons.gavel_outlined),
          const SizedBox(height: 30),
          _buildLogoutButton(context), // This button is now functional
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://via.placeholder.com/150/FFC107/000000?text=A'), // Placeholder
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  // --- THIS WIDGET IS NOW FUNCTIONAL ---
  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        // Sign out the user from Firebase
        await FirebaseAuth.instance.signOut();
        // The AuthGate will handle navigation back to the LoginScreen automatically.
      },
      child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
