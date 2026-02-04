import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../components/app_drawer.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final bookings = await ApiService.getBookings();
    if (mounted) {
      setState(() {
        _bookings = bookings.reversed.toList(); // Show newest first
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No bookings yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                        child: const Text('Book a Service'),
                      )
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(booking['serviceName'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                child: Text('Confirmed', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Provider: ${booking['providerName'] ?? 'provider'}', style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('${booking['date']} at ${booking['time']}', style: TextStyle(color: Colors.grey[800])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(child: Text(booking['address'] ?? 'No address', style: TextStyle(color: Colors.grey[800]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
