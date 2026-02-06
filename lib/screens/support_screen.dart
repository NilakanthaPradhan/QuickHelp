import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool _loading = true;
  User? _adminUser;

  @override
  void initState() {
    super.initState();
    _findAdmin();
  }

  void _findAdmin() async {
    // Strategy: Fetch all users and find one with role 'ADMIN'
    // Or search for 'admin' username.
    // Ideally backend should have an endpoint for this.
    // For now, let's try fetching all users and filtering (inefficient but works for MVP)
    // or searching for 'admin'.
    
    try {
      // Try searching for 'admin' first
      final users = await ApiService.searchUsers('admin');
      if (users.isNotEmpty) {
        // Pick the first one that is actually an admin if you can verify role, 
        // but search result doesn't guarantee role check unless User model has it (it does).
         final admin = users.firstWhere((u) => u.role == 'ADMIN', orElse: () => users.first);
         setState(() {
           _adminUser = admin;
           _loading = false;
         });
      } else {
         // Fallback: Get all users
         final all = await ApiService.getAllUsers();
         final admin = all.firstWhere((u) => u.role == 'ADMIN', orElse: () => User.guest()); // Handle no admin found
         if (admin.id != -1) {
            setState(() {
              _adminUser = admin;
              _loading = false;
            });
         } else {
           setState(() {
             _loading = false; // No admin found
           });
         }
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_adminUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Support')),
        body: const Center(child: Text('Support is currently unavailable.')),
      );
    }

    return ChatScreen(receiver: _adminUser!);
  }
}
