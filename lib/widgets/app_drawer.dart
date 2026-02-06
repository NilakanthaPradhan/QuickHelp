import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = ApiService.currentUser;
    final bool isGuest = user == null || user.id == -1;
    final bool isAdmin = user != null && user.role == 'ADMIN';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            accountName: Text(user?.fullName ?? 'Guest'),
            accountEmail: Text(user?.phone ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (user?.photoData != null) 
                ? MemoryImage(base64Decode(user!.photoData!)) 
                : null,
              child: (user?.photoData == null) 
                ? const Icon(Icons.person, size: 40, color: Colors.grey) 
                : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          if (!isGuest) ...[
             ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('My Bookings'),
              onTap: () => Navigator.pushNamed(context, '/my_bookings'),
            ),
             ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
          
          if (isAdmin) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text('Admin Panel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
             ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () => Navigator.pushNamed(context, '/admin/users'),
            ),
            // Could add 'Provider Requests' here too if relevant
          ],

          const Divider(),
          if (isGuest)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login / Register'),
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                ApiService.currentUser = null;
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              },
            ),
        ],
      ),
    );
  }
}
