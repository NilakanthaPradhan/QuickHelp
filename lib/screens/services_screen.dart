import 'package:flutter/material.dart';
import '../widgets/service_tile.dart';
import 'service_booking_page.dart';

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
    final bottom = MediaQuery.of(context).padding.bottom + 12;
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Services', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.98,
                children: _services.map((s) {
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
      ),
    );
  }


}
