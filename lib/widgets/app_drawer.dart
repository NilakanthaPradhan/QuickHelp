import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../services/theme_service.dart';
import '../screens/join_services_screen.dart';
import '../screens/admin_login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_page.dart';
import '../screens/admin_chat_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ValueListenableBuilder<User?>(
        valueListenable: ApiService.userNotifier,
        builder: (context, user, child) {
          final bool isGuest = user == null || user.id == -1;
          final bool isAdmin = user != null && user.role == 'ADMIN';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400]),
                ),
                accountName: Text(user?.fullName ?? 'Guest'),
                accountEmail: Text(user?.email ?? user?.phone ?? ''),
                currentAccountPicture: InkWell(
                  onTap: () {
                     Navigator.of(context).pop();
                     Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: (user?.photoData != null) 
                      ? MemoryImage(base64Decode(user!.photoData!)) 
                      : null,
                    child: (user?.photoData == null) 
                      ? const Icon(Icons.person, size: 40, color: Colors.grey) 
                      : null,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  if (ModalRoute.of(context)?.settings.name != '/main') {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    Navigator.pop(context); // Just close drawer
                  }
                },
              ),
              if (!isGuest) ...[
                 ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('My Bookings'),
                  onTap: () => Navigator.pushNamed(context, '/bookings'),
                ),
                 ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                 ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Chats'),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.pushNamed(context, '/chat_search');
                  },
                ),
                 ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('Support'),
                  onTap: () => Navigator.pushNamed(context, '/support'),
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
                 ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Provider Requests'),
                  onTap: () => Navigator.pushNamed(context, '/admin/requests'),
                ),
                 ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('All Chats (Support)'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
                  },
                ),
              ],

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Theme Color', style: Theme.of(context).textTheme.bodySmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  children: [
                    Colors.deepPurple,
                    Colors.blue,
                    Colors.orange,
                    Colors.teal,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => ThemeService.instance.setSeedColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ThemeService.instance.seedColor == color ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),

              if (!isGuest)
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('Join as Provider'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinServicesScreen()));
                  },
                ),

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
                  onTap: () async {
                    await ApiService.logout();
                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
