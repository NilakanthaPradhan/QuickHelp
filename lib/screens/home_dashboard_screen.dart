import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'services_screen.dart';
import 'service_booking_page.dart';
import '../widgets/service_tile.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<dynamic> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final services = await ApiService.getServices();
    if (mounted) {
      setState(() {
        _services = services;
        _loading = false;
      });
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'ac_unit': return Icons.ac_unit;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'plumbing': return Icons.plumbing;
      case 'electrical_services': return Icons.electrical_services;
      case 'format_paint': return Icons.format_paint;
      case 'handyman': return Icons.handyman;
      case 'clean_hands': return Icons.clean_hands;
      case 'grass': return Icons.grass;
      case 'bug_report': return Icons.bug_report;
      default: return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show max 4 items
    final displayServices = _services.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner or Greeting could go here
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.deepPurple.shade300]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Home!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('What do you need help with today?', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Services Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Our Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServicesScreen(showAppBar: true)));
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Services Grid (Limited)
          _loading
              ? const Center(child: CircularProgressIndicator())
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: displayServices.map((s) {
                    return ServiceTile(
                      title: s['name'] as String,
                      icon: _getIcon(s['icon'] as String),
                      color: Colors.blue, 
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceBookingPage(serviceTitle: s['name'] as String))),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
