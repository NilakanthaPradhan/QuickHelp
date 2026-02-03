import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/services_page.dart';
import 'screens/rentals_page.dart';
import 'screens/my_bookings_page.dart';

import 'services/theme_service.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
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
          initialRoute: '/',
          routes: {
            '/': (_) => const WelcomeScreen(),
            '/main': (_) => const MainScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/services': (_) => const ServicesPage(),
            '/rentals': (_) => const RentalsPage(),
            '/bookings': (_) => const MyBookingsPage(),
            '/chat': (_) => const ChatScreen(),
            '/settings': (_) => const SettingsPage(),
          },
        );
      },
    );
  }
}
