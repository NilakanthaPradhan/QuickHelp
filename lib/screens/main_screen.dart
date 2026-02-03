import 'package:flutter/material.dart';
import '../components/app_drawer.dart';
import '../services/theme_service.dart';
import 'services_screen.dart';
import 'rental_finder_screen.dart';
import 'profile_screen.dart';
import 'settings_page.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ServicesScreen(),
    const RentalFinderScreen(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Debug helper: auto-open drawer once on startup so we can verify drawer contents.
    // This only runs in debug builds and will not affect production behavior.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // small delay to allow scaffold to settle
      Future.delayed(const Duration(milliseconds: 600), () {
        // Use scheduleMicrotask to avoid exceptions when not mounted
        if (mounted) {
          // Only open drawer in debug mode
          assert(() {
            _scaffoldKey.currentState?.openDrawer();
            return true;
          }());
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
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
            onPressed: () => Navigator.of(context).pushNamed('/chat'),
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
          final icons = [Icons.home, Icons.room_service, Icons.settings];
          final labels = ['Home', 'Rentals', 'Settings'];
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
