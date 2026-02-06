import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../widgets/app_drawer.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await ApiService.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Users')),
      drawer: const AppDrawer(), // Access drawer from here too
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoData != null 
                           ? MemoryImage(base64Decode(user.photoData!))
                           : null,
                        child: user.photoData == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user.fullName.isNotEmpty ? user.fullName : user.username),
                      subtitle: Text('${user.email}\n${user.phone}'),
                      trailing: Text(user.role),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}
