import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import 'drawer_theme_controls.dart';

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
            leading: const Icon(Icons.book),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/bookings');
            },
          ),
          const DrawerThemeControls(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings');
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
