import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../services/theme_service.dart';
import '../screens/join_services_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: ValueListenableBuilder<User?>(
        valueListenable: ApiService.userNotifier,
        builder: (context, user, child) {
          final bool isGuest = user == null || user.id == -1;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
                accountName: Text(
                  user?.fullName ?? 'Welcome, Guest',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: Text(
                  user?.email ?? user?.phone ?? 'Sign in to access more features',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                currentAccountPicture: InkWell(
                  onTap: () {
                    if(!isGuest) {
                       Navigator.of(context).pop();
                       Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4)
                        )
                      ]
                    ),
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: (user?.photoData != null) 
                        ? MemoryImage(base64Decode(user!.photoData!)) 
                        : null,
                      child: (user?.photoData == null) 
                        ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary) 
                        : null,
                    ),
                  ),
                ),
              ),
              
              _buildDrawerItem(
                context, 
                icon: Icons.home_rounded, 
                title: 'Home', 
                onTap: () {
                  if (ModalRoute.of(context)?.settings.name != '/main') {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    Navigator.pop(context); // Just close drawer
                  }
                }
              ),
              
              if (!isGuest) ...[
                 _buildDrawerItem(
                  context,
                  icon: Icons.event_available_rounded,
                  title: 'My Bookings',
                  onTap: () => Navigator.pushNamed(context, '/bookings'),
                ),
                 _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                 _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Chats',
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.pushNamed(context, '/chat_search');
                  },
                ),
                 _buildDrawerItem(
                  context,
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  onTap: () => Navigator.pushNamed(context, '/support'),
                ),
              ],
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Appearance', style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                )),
              ),
              
              // Dark Mode Toggle inside Drawer
              AnimatedBuilder(
                animation: ThemeService.instance,
                builder: (context, _) => SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: const Text('Dark Mode'),
                  secondary: Icon(ThemeService.instance.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  value: ThemeService.instance.themeMode == ThemeMode.dark,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (bool value) => ThemeService.instance.toggleDarkLight(),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Wrap(
                  spacing: 16,
                  children: [
                    Colors.deepPurple,
                    Colors.blue,
                    Colors.deepOrange,
                    Colors.teal,
                  ].map((color) {
                    final isSelected = ThemeService.instance.seedColor == color;
                    return GestureDetector(
                      onTap: () => ThemeService.instance.setSeedColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: isSelected ? [
                            BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                          ] : null,
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
              
              _buildDrawerItem(
                context,
                icon: Icons.settings_rounded,
                title: 'Settings',
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),

              if (!isGuest)
                _buildDrawerItem(
                  context,
                  icon: Icons.business_center_outlined,
                  title: 'Join as Provider',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinServicesScreen()));
                  },
                ),

              if (isGuest)
                _buildDrawerItem(
                  context,
                  icon: Icons.login_rounded,
                  title: 'Login / Register',
                  onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
                )
              else
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  onTap: () async {
                    await ApiService.logout();
                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  },
                ),
                
              const SizedBox(height: 24), // Bottom padding
            ],
          );
        },
      ),
    );
  }

  // Helper method for styling drawer items beautifully
  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        onTap: onTap,
        hoverColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      ),
    );
  }
}

