import 'package:flutter/material.dart';
import '../components/app_drawer.dart';
import 'services_screen.dart';
import 'rental_finder_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ServicesScreen(),
    const RentalFinderScreen(),
    const Center(child: Text('Settings', style: TextStyle(fontSize: 24))),
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
      appBar: AppBar(
        title: const Text('QuickHelp'),
        actions: [
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
          )
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
