import 'package:flutter/material.dart';
import '../widgets/service_tile.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<Map<String, dynamic>> _services = [
    {'title': 'Maid', 'icon': Icons.cleaning_services, 'color': Colors.pink},
    {'title': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.blue},
    {'title': 'Painter', 'icon': Icons.brush, 'color': Colors.orange},
    {'title': 'Electrician', 'icon': Icons.electrical_services, 'color': Colors.amber},
    {'title': 'Carpenter', 'icon': Icons.handyman, 'color': Colors.brown},
    {'title': 'Cleaner', 'icon': Icons.clean_hands, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: _services.map((s) {
          return ServiceTile(
            title: s['title'] as String,
            icon: s['icon'] as IconData,
            color: s['color'] as Color,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search for ${s['title']} in your area')),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
