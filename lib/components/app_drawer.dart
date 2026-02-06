import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../services/theme_service.dart';
import '../screens/join_services_screen.dart';
import '../screens/admin_requests_screen.dart';
import '../screens/admin_login_screen.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Demo User'),
            accountEmail: const Text('demo@quickhelp.app'),
            currentAccountPicture: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: Hero(
                tag: 'quickhelp-logo',
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.person),
                    ),
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400]),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/main');
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Rentals'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/rentals');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build_circle),
            title: const Text('Services'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/bookings');
            },
          ),
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
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/chat');
            },
          ),
          const Divider(),
          // New options
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Join as Provider'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JoinServicesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Panel'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
