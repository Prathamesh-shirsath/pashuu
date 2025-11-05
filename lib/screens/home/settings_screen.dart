// lib/screens/home/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // State for notifications toggle
  String _selectedLanguage = 'English'; // State for selected language

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final double borderRadius = 12.0; // Consistent border radius for cards/inputs

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: primaryColor, // Consistent with your app's style
        foregroundColor: Colors.white, // White text/icons on primary background
        elevation: 4, // Add some elevation
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            _buildProfileCard(context, user, borderRadius, onSurfaceColor),
            const SizedBox(height: 30),

            // General Settings Section Title
            _buildSectionTitle('General Settings', onSurfaceColor),
            const SizedBox(height: 10),

            // Language Setting Card
            _buildSettingCard(
              context: context,
              icon: Icons.language,
              title: 'Language',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                      // TODO: Implement actual language change logic here
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Language changed to $newValue')),
                      // );
                    });
                  }
                },
                items: <String>['English', 'Marathi', 'Hindi'] // Example languages
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: onSurfaceColor)),
                  );
                }).toList(),
                underline: Container(), // Remove default underline for cleaner look
                icon: Icon(Icons.arrow_drop_down, color: onSurfaceColor.withOpacity(0.6)), // Muted icon
                style: TextStyle(color: onSurfaceColor, fontSize: 16), // Text style for selected value
              ),
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            // Notifications Toggle Card
            _buildSettingCard(
              context: context,
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                    // TODO: Implement actual notification toggle logic here (e.g., Firebase Messaging)
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Notifications ${value ? 'Enabled' : 'Disabled'}')),
                    // );
                  });
                },
                activeColor: primaryColor, // Use app's primary color for active state
              ),
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 30),

            // Legal & Support Section Title
            _buildSectionTitle('Legal & Support', onSurfaceColor),
            const SizedBox(height: 10),

            // Medical Support Card
            _buildSettingCard(
              context: context,
              icon: Icons.support_agent,
              title: 'Medical Support',
              onTap: () {
                // TODO: Navigate to a Medical Support screen or show contact info
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Navigating to Medical Support')),
                // );
              },
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            // Privacy Policy Card
            _buildSettingCard(
              context: context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Navigate to a Privacy Policy screen or open a URL
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Opening Privacy Policy')),
                // );
                // Example for opening URL:
                // import 'package:url_launcher/url_launcher.dart';
                // launchUrl(Uri.parse('https://www.yourwebsite.com/privacy'));
              },
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            // Terms of Service Card
            _buildSettingCard(
              context: context,
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                // TODO: Navigate to a Terms of Service screen or open a URL
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Opening Terms of Service')),
                // );
                // Example for opening URL:
                // import 'package:url_launcher/url_launcher.dart';
                // launchUrl(Uri.parse('https://www.yourwebsite.com/terms'));
              },
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 30),

            // Logout Button
            _buildLogoutButton(context, borderRadius),
          ],
        ),
      ),
    );
  }

  // Helper widget for the user profile card
  Widget _buildProfileCard(
      BuildContext context, User? user, double borderRadius, Color onSurfaceColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : const NetworkImage('https://via.placeholder.com/150/FFC107/000000?text=A') // Placeholder
          as ImageProvider, // Cast to ImageProvider
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: user?.photoURL == null && user?.displayName == null
              ? Icon(Icons.person, color: Theme.of(context).primaryColor.withOpacity(0.7))
              : null,
        ),
        title: Text(
          user?.displayName ?? 'Anonymous User',
          style: TextStyle(fontWeight: FontWeight.bold, color: onSurfaceColor),
        ),
        subtitle: Text(
          user?.email ?? 'No email available',
          style: TextStyle(color: onSurfaceColor.withOpacity(0.7)),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: onSurfaceColor.withOpacity(0.5), size: 18),
        onTap: () {
          // TODO: Implement navigation to a user profile editing screen
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Opening Profile Details')),
          // );
        },
      ),
    );
  }

  // Helper widget to build section titles
  Widget _buildSectionTitle(String title, Color onSurfaceColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0, top: 10.0, left: 5.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor.withOpacity(0.8), // Muted color for section title
        ),
      ),
    );
  }

  // Reusable widget to build each setting item as a styled card
  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing, // Can be a Switch, Dropdown, etc.
    VoidCallback? onTap,
    required double borderRadius,
    required Color onSurfaceColor,
  }) {
    return Card(
      elevation: 3, // Similar elevation to other cards in your app
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero, // Remove default card margin, use SizedBox for spacing
      child: InkWell(
        // Provides ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius), // Apply radius to InkWell's ripple
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor), // Icon with primary color
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: onSurfaceColor, // Text color
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(Icons.arrow_forward_ios, color: onSurfaceColor.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // The functional Log Out button
  Widget _buildLogoutButton(BuildContext context, double borderRadius) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      onPressed: () async {
        // Sign out the user from Firebase
        await FirebaseAuth.instance.signOut();
        // The AuthGate will handle navigation back to the LoginScreen automatically.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Successfully logged out.')),
        // );
      },
      child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}