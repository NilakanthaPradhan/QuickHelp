import 'package:flutter/material.dart';

class RentalFinderScreen extends StatelessWidget {
  const RentalFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sample = List.generate(6, (i) => 'Rental Room ${i + 1} - Available');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search area or pin code',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: sample.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.home_work),
                    title: Text(sample[index]),
                    subtitle: const Text('Approx 0.8 km away'),
                    trailing: ElevatedButton(onPressed: () {}, child: const Text('Contact')),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
