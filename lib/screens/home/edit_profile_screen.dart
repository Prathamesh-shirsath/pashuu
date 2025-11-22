// lib/screens/home/edit_profile_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _farmSizeController = TextEditingController();

  File? _profileImage;
  bool _loading = true;

  User? get _user => FirebaseAuth.instance.currentUser;

  String? _currentPhotoURL;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        _nameController.text = data['displayName'] ?? _user!.displayName ?? "";
        _phoneController.text = data['phone'] ?? "";
        _addressController.text = data['address'] ?? "";
        _villageController.text = data['village'] ?? "";
        _districtController.text = data['district'] ?? "";
        _stateController.text = data['state'] ?? "";
        _pincodeController.text = data['pincode'] ?? "";
        _farmSizeController.text = data['farmSize']?.toString() ?? "";
        _currentPhotoURL = data['photoURL'] ?? _user!.photoURL;
      }
    } catch (e) {
      print('Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data.')),
      );
    }

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image slightly
    );

    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadProfilePhoto() async {
    if (_profileImage == null || _user == null) return _currentPhotoURL;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_photos")
          .child("${_user!.uid}.jpg");

      await ref.putFile(_profileImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Photo upload error: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() => _loading = true);

    try {
      String? uploadedURL = await _uploadProfilePhoto();
      final name = _nameController.text.trim();

      // Update Firebase Auth profile
      if (name.isNotEmpty && name != _user!.displayName) {
        await _user!.updateDisplayName(name);
      }
      if (uploadedURL != null && uploadedURL != _user!.photoURL) {
        await _user!.updatePhotoURL(uploadedURL);
      }

      // Update Firestore document
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'displayName': name,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'village': _villageController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'farmSize': _farmSizeController.text.trim(),
        'photoURL': uploadedURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving profile"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ---
    // --- THIS IS THE FIX ---
    // ---
    // 1. A dedicated, type-safe variable is created to hold the image.
    ImageProvider<Object>? imageProvider;

    // 2. A simple if/else block cleanly decides which image to show.
    if (_profileImage != null) {
      // Use the new local file image
      imageProvider = FileImage(_profileImage!);
    } else if (_currentPhotoURL != null && _currentPhotoURL!.isNotEmpty) {
      // Use the existing image from the network
      imageProvider = NetworkImage(_currentPhotoURL!);
    }
    // If both are null, imageProvider remains null.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---------- PROFILE PHOTO ----------
              Center(
                child: Stack(
                  children: [
                    // 3. The CircleAvatar now uses the clean, pre-prepared variable.
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imageProvider,
                      // Conditionally show the icon ONLY if there is no image.
                      child: imageProvider == null
                          ? const Icon(Icons.person,
                          size: 55, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---------- EMAIL READ ONLY ----------
              TextFormField(
                initialValue: _user?.email ?? 'No Email',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email (not editable)',
                  prefixIcon: Icon(Icons.email_outlined),
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              _buildField(_nameController, "Full Name", Icons.person_outline,
                  validator: (v) =>
                  v!.trim().isEmpty ? "Enter a valid name" : null),
              const SizedBox(height: 16),

              _buildField(_phoneController, "Mobile Number", Icons.phone_outlined,
                  keyboard: TextInputType.phone),
              const SizedBox(height: 16),

              _buildField(
                  _addressController, "Address", Icons.home_work_outlined,
                  maxLines: 2),
              const SizedBox(height: 16),

              _buildField(_villageController, "Village / City",
                  Icons.location_city_outlined),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                      child: _buildField(
                          _districtController, "District", Icons.map_outlined)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildField(
                          _stateController, "State", Icons.flag_outlined)),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                      child: _buildField(_pincodeController, "Pincode",
                          Icons.local_post_office_outlined,
                          keyboard: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildField(_farmSizeController,
                          "Farm Size (optional)", Icons.agriculture_outlined)),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text("Save Profile"),
                  onPressed: _loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController c, String label, IconData icon,
      {String? Function(String?)? validator,
        TextInputType keyboard = TextInputType.text,
        int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}