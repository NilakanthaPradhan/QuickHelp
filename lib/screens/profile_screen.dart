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
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Guest View
    if (_user!.id == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.account_circle, size: 100, color: theme.colorScheme.onSurface.withOpacity(0.3)),
               const SizedBox(height: 24),
               Text('You are observing as a Guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
               const SizedBox(height: 16),
               Text('Join now to save your profile and bookings.', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
               const SizedBox(height: 32),
               ElevatedButton(
                 onPressed: _logout,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: theme.colorScheme.primary, 
                   foregroundColor: theme.colorScheme.onPrimary,
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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
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
                backgroundColor: isDark ? theme.colorScheme.surfaceVariant : Colors.grey[200],
                backgroundImage: _imageFile != null 
                    ? FileImage(_imageFile!) 
                    : (_user!.photoData != null 
                        ? MemoryImage(base64Decode(_user!.photoData!)) 
                        : null),
                child: (_imageFile == null && _user!.photoData == null) 
                    ? Icon(Icons.person, size: 50, color: theme.colorScheme.onSurface.withOpacity(0.3))
                    : null,
              ),
            ),
            if (_isEditing)
               Padding(padding: const EdgeInsets.only(top: 8), child: Text("Tap to change photo", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)))),

            const SizedBox(height: 16),
            Text(_user!.username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 24),
            
            _buildTextField("Full Name", _nameController, Icons.badge, theme, isDark),
            const SizedBox(height: 16),
            _buildTextField("Phone", _phoneController, Icons.phone, theme, isDark),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController, Icons.email, theme, isDark),
            const SizedBox(height: 16),
            _buildTextField("Address", _addressController, Icons.home, theme, isDark),
            
            const SizedBox(height: 32),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer, 
                    foregroundColor: theme.colorScheme.onPrimaryContainer, 
                    padding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, ThemeData theme, bool isDark) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !_isEditing,
        fillColor: isDark ? theme.colorScheme.surfaceVariant : Colors.grey[100],
      ),
    );
  }
}
