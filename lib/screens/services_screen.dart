import 'package:flutter/material.dart';
import '../widgets/service_tile.dart';
import 'service_booking_page.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  static const List<Map<String, dynamic>> _allServices = [
    {'title': 'Maid', 'icon': Icons.cleaning_services, 'color': Colors.pink},
    {'title': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.blue},
    {'title': 'Painter', 'icon': Icons.format_paint, 'color': Colors.orange},
    {'title': 'Electrician', 'icon': Icons.electrical_services, 'color': Colors.amber},
    {'title': 'Carpenter', 'icon': Icons.handyman, 'color': Colors.brown},
    {'title': 'Cleaner', 'icon': Icons.clean_hands, 'color': Colors.green},
    {'title': 'Gardener', 'icon': Icons.grass, 'color': Colors.lightGreen},
    {'title': 'Pest Control', 'icon': Icons.bug_report, 'color': Colors.red},
  ];

  List<Map<String, dynamic>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = List.from(_allServices);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredServices = _allServices.where((s) => (s['title'] as String).toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 12;
    return SafeArea(
      bottom: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Services', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a service...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredServices.isEmpty
                ? const Center(child: Text('No services found'))
                : GridView.count(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: _filteredServices.map((s) {
                      return ServiceTile(
                        title: s['title'] as String,
                        icon: s['icon'] as IconData,
                        color: s['color'] as Color,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceBookingPage(serviceTitle: s['title'] as String))),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
