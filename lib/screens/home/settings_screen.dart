// lib/screens/home/settings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_profile_screen.dart'; // 👈 NEW: import profile screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _themeMode = 'System'; // System / Light / Dark
  bool _loadingPrefs = true;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    if (_user == null) {
      setState(() {
        _loadingPrefs = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _selectedLanguage = (data['language'] as String?) ?? 'English';
          _notificationsEnabled =
              (data['notificationsEnabled'] as bool?) ?? true;
          _themeMode = (data['themeMode'] as String?) ?? 'System';
        });
      }
    } catch (e) {
      print('Error loading user settings: $e');
    } finally {
      setState(() {
        _loadingPrefs = false;
      });
    }
  }

  Future<void> _saveUserSettings() async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .set({
        'language': _selectedLanguage,
        'notificationsEnabled': _notificationsEnabled,
        'themeMode': _themeMode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user settings: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    const double borderRadius = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(
                context, _user, borderRadius, onSurfaceColor),
            const SizedBox(height: 30),

            _buildSectionTitle('General Settings', onSurfaceColor),
            const SizedBox(height: 10),

            // Language
            _buildSettingCard(
              context: context,
              icon: Icons.language,
              title: 'Language',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) async {
                  if (newValue == null) return;
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  await _saveUserSettings();
                },
                items: <String>['English', 'Marathi', 'Hindi']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: onSurfaceColor),
                    ),
                  );
                }).toList(),
                underline: Container(),
                icon: Icon(Icons.arrow_drop_down,
                    color: onSurfaceColor.withOpacity(0.6)),
                style: TextStyle(
                    color: onSurfaceColor, fontSize: 16),
              ),
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            // Theme Mode
            _buildSettingCard(
              context: context,
              icon: Icons.color_lens,
              title: 'App Theme',
              trailing: DropdownButton<String>(
                value: _themeMode,
                onChanged: (String? newValue) async {
                  if (newValue == null) return;
                  setState(() {
                    _themeMode = newValue;
                  });
                  await _saveUserSettings();
                  // TODO: actually apply theme in main app using this value
                },
                items: <String>['System', 'Light', 'Dark']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: onSurfaceColor),
                    ),
                  );
                }).toList(),
                underline: Container(),
                icon: Icon(Icons.arrow_drop_down,
                    color: onSurfaceColor.withOpacity(0.6)),
                style: TextStyle(
                    color: onSurfaceColor, fontSize: 16),
              ),
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            // Notifications
            _buildSettingCard(
              context: context,
              icon: Icons.notifications_active,
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) async {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await _saveUserSettings();
                },
                activeColor: primaryColor,
              ),
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),

            const SizedBox(height: 30),

            _buildSectionTitle('Legal & Support', onSurfaceColor),
            const SizedBox(height: 10),

            _buildSettingCard(
              context: context,
              icon: Icons.support_agent,
              title: 'Medical Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'For emergencies, contact your nearest veterinarian.'),
                  ),
                );
              },
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            _buildSettingCard(
              context: context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Open URL or dedicated screen
              },
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),
            const SizedBox(height: 15),

            _buildSettingCard(
              context: context,
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                // TODO: Open URL or dedicated screen
              },
              borderRadius: borderRadius,
              onSurfaceColor: onSurfaceColor,
            ),

            const SizedBox(height: 30),

            _buildLogoutButton(context, borderRadius),
          ],
        ),
      ),
    );
  }

  // ================== UI HELPERS ==================

  Widget _buildProfileCard(
      BuildContext context,
      User? user,
      double borderRadius,
      Color onSurfaceColor,
      ) {
    final String name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Anonymous User';
    final String email = user?.email ?? 'No email available';

    String initials = '';
    if (name.isNotEmpty && name != 'Anonymous User') {
      final parts = name.split(' ');
      if (parts.length == 1) {
        initials = parts.first.characters.first.toUpperCase();
      } else {
        initials =
            (parts.first.characters.first + parts.last.characters.first)
                .toUpperCase();
      }
    } else if (email.isNotEmpty) {
      initials = email.characters.first.toUpperCase();
    } else {
      initials = 'U';
    }

    final bool hasPhoto = user?.photoURL != null && user!.photoURL!.isNotEmpty;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: user == null
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditProfileScreen(),
            ),
          );
        },
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: hasPhoto
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: hasPhoto
                    ? null
                    : Text(
                  initials,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurfaceColor.withOpacity(0.7),
                      ),
                    ),
                    if (user == null)
                      Text(
                        'You are in guest mode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    if (user != null)
                      const SizedBox(height: 4),
                    if (user != null)
                      Text(
                        'Tap to edit profile details',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurfaceColor.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              if (user != null)
                Icon(Icons.edit,
                    size: 18,
                    color: onSurfaceColor.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color onSurfaceColor) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 5.0, top: 10.0, left: 5.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    required double borderRadius,
    required Color onSurfaceColor,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: onSurfaceColor,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(Icons.arrow_forward_ios,
                    color: onSurfaceColor.withOpacity(0.5), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, double borderRadius) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: _logout,
      child: const Text(
        'Log Out',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
