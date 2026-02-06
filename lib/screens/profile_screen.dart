import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isEditing = false;
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = ApiService.currentUser;
    if (_user != null) {
      _nameController.text = _user!.fullName;
      _phoneController.text = _user!.phone;
      _emailController.text = _user!.email;
      _addressController.text = _user!.address;
    }
  }

  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    
    final updatedUser = User(
      id: _user!.id,
      username: _user!.username,
      email: _emailController.text,
      phone: _phoneController.text,
      role: _user!.role,
      fullName: _nameController.text,
      address: _addressController.text,
    );

    final success = await ApiService.updateProfile(updatedUser, _imageFile);
    if (mounted) {
      if (success) {
        setState(() {
          _user = ApiService.currentUser;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
      }
    }
  }
  
  void _logout() {
    ApiService.currentUser = null;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text("No User Logged In")));
    
    // Guest View
    if (_user!.id == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.account_circle, size: 100, color: Colors.grey),
               const SizedBox(height: 24),
               const Text('You are observing as a Guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               const Text('Join now to save your profile and bookings.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
               const SizedBox(height: 32),
               ElevatedButton(
                 onPressed: _logout,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blueAccent, 
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
                 ),
                 child: const Text('Login / Register'), // Logout goes back to login screen
               )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _imageFile != null 
                    ? FileImage(_imageFile!) 
                    : (_user!.photoData != null 
                        ? MemoryImage(base64Decode(_user!.photoData!)) 
                        : null),
                child: (_imageFile == null && _user!.photoData == null) 
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            if (_isEditing)
               const Padding(padding: EdgeInsets.only(top: 8), child: Text("Tap to change photo", style: TextStyle(color: Colors.grey))),

            const SizedBox(height: 16),
            Text(_user!.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 24),
            
            _buildTextField("Full Name", _nameController, Icons.badge),
            const SizedBox(height: 16),
            _buildTextField("Phone", _phoneController, Icons.phone),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController, Icons.email),
            const SizedBox(height: 16),
            _buildTextField("Address", _addressController, Icons.home),
            
            const SizedBox(height: 32),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !_isEditing,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
