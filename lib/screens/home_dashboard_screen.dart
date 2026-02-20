import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'services_screen.dart';
import 'service_booking_page.dart';
import '../widgets/service_tile.dart';
import '../widgets/app_drawer.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<dynamic> _services = [];
  bool _loading = true;

  // A palette of vibrant, premium colors for tiles
  final List<Color> _tileColors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.teal,
    Colors.pinkAccent,
    Colors.indigoAccent,
    Colors.green,
  ];

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
      case 'ac_unit': return Icons.ac_unit_rounded;
      case 'cleaning_services': return Icons.cleaning_services_rounded;
      case 'plumbing': return Icons.plumbing_rounded;
      case 'electrical_services': return Icons.electrical_services_rounded;
      case 'format_paint': return Icons.format_paint_rounded;
      case 'handyman': return Icons.handyman_rounded;
      case 'clean_hands': return Icons.clean_hands_rounded;
      case 'grass': return Icons.grass_rounded;
      case 'bug_report': return Icons.bug_report_rounded;
      default: return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show max 4 items
    final displayServices = _services.take(4).toList();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Hero Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ]
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, \n${ApiService.currentUser?.fullName ?? (ApiService.currentUser?.username ?? 'Guest')} 👋', 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 28, 
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  )
                ),
                const SizedBox(height: 12),
                if (ApiService.currentUser?.id == -1) // Guest
                 GestureDetector(
                   onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false), // Go to login
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2), 
                       borderRadius: BorderRadius.circular(30),
                       border: Border.all(color: Colors.white.withOpacity(0.5))
                     ),
                     child: const Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text('Join QuickHelp Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                         SizedBox(width: 8),
                         Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18)
                       ],
                     ),
                   ),
                 )
                else
                 Text(
                   'Available AC Repair & Services', 
                   style: TextStyle(
                     color: Colors.white.withOpacity(0.85), 
                     fontSize: 16,
                     fontWeight: FontWeight.w500,
                     letterSpacing: 0.3,
                   )
                 ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Services Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Our Services', 
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                )
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServicesScreen(showAppBar: true))),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'See All', 
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    )
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Services Grid
          _loading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: theme.colorScheme.primary),
                  )
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: displayServices.length,
                  itemBuilder: (context, index) {
                    final s = displayServices[index];
                    final color = _tileColors[index % _tileColors.length];
                    
                    return ServiceTile(
                      title: s['name'] as String,
                      icon: _getIcon(s['icon'] as String),
                      color: color, 
                      providerCount: (s['providerCount'] ?? 0) as int,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceBookingPage(serviceTitle: s['name'] as String))),
                    );
                  },
                ),
                
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
