import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/services_page.dart';
import 'screens/rentals_page.dart';
import 'screens/my_bookings_page.dart';

import 'services/theme_service.dart';
import 'screens/settings_page.dart';
import 'screens/chat_search_screen.dart';
import 'screens/support_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
  // We no longer await loadUserFromPrefs here; the SplashScreen will handle it gracefully 
  // with an animation instead of a blank black/white freezing screen.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
        final seed = ThemeService.instance.seedColor;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuickHelp',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: ThemeService.instance.themeMode,
          // Start with the beautiful splash screen that checks login state
          home: const SplashScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/main': (_) => const MainScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/services': (_) => const ServicesPage(),
            '/rentals': (_) => const RentalsPage(),
            '/bookings': (_) => const MyBookingsPage(),
            '/settings': (_) => const SettingsPage(),
            '/chat_search': (_) => const ChatSearchScreen(),
            '/support': (_) => const SupportScreen(),
          },
        );
      },
    );
  }
}
