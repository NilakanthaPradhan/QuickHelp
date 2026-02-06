import 'package:flutter/material.dart';
import '../widgets/service_tile.dart';
import '../services/api_service.dart';
import 'service_booking_page.dart';

class ServicesScreen extends StatefulWidget {
  final bool showAppBar;
  const ServicesScreen({super.key, this.showAppBar = false});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allServices = [];
  List<dynamic> _filteredServices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchServices() async {
    final services = await ApiService.getServices();
    if (mounted) {
      setState(() {
        _allServices = services;
        _filteredServices = services;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredServices = _allServices.where((s) => (s['name'] as String).toLowerCase().contains(query)).toList();
    });
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'ac_unit': return Icons.ac_unit;
      case 'cleaning_services': return Icons.cleaning_services; // Used for Cleaner and Maid
      case 'plumbing': return Icons.plumbing; // Used for Plumber
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
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Services')),
        body: _buildContent(context),
      );
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServices.isEmpty
                    ? const Center(child: Text('No services found'))
                    : GridView.count(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                        children: _filteredServices.map((s) {
                          return ServiceTile(
                            title: s['name'] as String,
                            icon: _getIcon(s['icon'] as String),
                            color: Colors.blue, // Default color for now as DB doesn't have it
                            providerCount: (s['providerCount'] ?? 0) as int,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceBookingPage(serviceTitle: s['name'] as String))),
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
