import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileCard(context, 'Anjali Sharma', 'Sharma Farms'),
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
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String farmName) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://via.placeholder.com/150/FFC107/000000?text=AS'), // Placeholder
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(farmName),
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

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        // Logout logic here
      },
      child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
