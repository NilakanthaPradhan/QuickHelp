import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/theme_service.dart';
import 'services_screen.dart';
import 'home_dashboard_screen.dart';
import 'rental_finder_screen.dart';
import 'chat_search_screen.dart';
import 'profile_screen.dart';
import 'settings_page.dart';
import 'rentals_page.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const HomeDashboardScreen(),
    const RentalsPage(),
    const ChatSearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _selectedIndex == 1 ? null : AppBar(
        title: const Text('QuickHelp'),
        actions: [

          AnimatedBuilder(
            animation: ThemeService.instance,
            builder: (context, _) => IconButton(
              icon: Icon(ThemeService.instance.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => ThemeService.instance.toggleDarkLight(),
              tooltip: 'Toggle theme',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.of(context).pushNamed('/chat_search'),
            tooltip: 'Chat',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black87),
              ),
              tooltip: 'Profile',
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: List.generate(3, (i) {
          final icons = [Icons.home, Icons.room_service, Icons.chat];
          final labels = ['Home', 'Rentals', 'Chats'];
          return BottomNavigationBarItem(
            icon: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 1.0,
                end: _selectedIndex == i ? 1.2 : 1.0,
              ),
              duration: const Duration(milliseconds: 250),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Icon(icons[i]),
            ),
            label: labels[i],
          );
        }),
      ),
    );
  }
}
