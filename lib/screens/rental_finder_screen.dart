import 'package:flutter/material.dart';

class RentalFinderScreen extends StatelessWidget {
  const RentalFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Dummy Data
    final rentals = [
      {
        'title': 'Luxury Penthouse with View',
        'price': '₹25,000/mo',
        'rating': 4.9,
        'image': 'https://picsum.photos/600/400?image=10',
        'type': 'Entire Apartment',
        'location': 'Indiranagar, Bangalore'
      },
      {
        'title': 'Cozy Garden Studio',
        'price': '₹12,000/mo',
        'rating': 4.7,
        'image': 'https://picsum.photos/600/400?image=11',
        'type': 'Studio',
        'location': 'Koramangala, Bangalore'
      },
      {
        'title': 'Modern 2BHK Near Tech Park',
        'price': '₹30,000/mo',
        'rating': 4.5,
        'image': 'https://picsum.photos/600/400?image=12',
        'type': 'Apartment',
        'location': 'Whitefield, Bangalore'
      },
       {
        'title': 'Shared Room for Students',
        'price': '₹6,000/mo',
        'rating': 4.2,
        'image': 'https://picsum.photos/600/400?image=13',
        'type': 'Shared Room',
        'location': 'BTM Layout, Bangalore'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // REMOVED Redundant Search Bar
          
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true, // CRITICAL FIX: Allows this list to live inside another ScrollView
            physics: const NeverScrollableScrollPhysics(), // Scroll is handled by parent
            itemCount: rentals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final r = rentals[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          Image.network(
                            r['image'] as String,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[200]),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    r['rating'].toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Details Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r['type'] as String,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5
                                ),
                              ),
                              Text(
                                r['price'] as String,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                r['location'] as String,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12)
                              ),
                              onPressed: () {
                                // Add navigation or contact logic here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Contacting owner... 📞'))
                                );
                              },
                              child: const Text('View Details', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
