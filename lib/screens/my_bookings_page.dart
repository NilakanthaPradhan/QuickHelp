import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/booking_store.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ApiService.currentUser == null || ApiService.currentUser!.id == -1) {
        // Show empty or redirect. For now, let's just show a message in body or redirect.
        // Actually best to redirect or show placeholder.
      } else {
        _load();
      }
    });
  }

  Future<void> _load() async {
    final bRaw = await ApiService.getBookings();
    final List<Map<String, dynamic>> b = List<Map<String, dynamic>>.from(bRaw);
    setState(() {
      _bookings = b;
      _loading = false;
    });
  }

  Future<void> _removeAt(int i) async {
    // Backend delete not implemented yet
    // await BookingStore.removeBookingAt(i);
    // await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: (ApiService.currentUser == null || ApiService.currentUser!.id == -1)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text('Login to view bookings'),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                     child: const Text('Login Now')
                   )
                ],
              ),
            )
              : _loading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No bookings found', style: TextStyle(color: Colors.grey, fontSize: 18)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/rentals'), 
                            icon: const Icon(Icons.search),
                            label: const Text('Find Services')
                          )
                        ],
                      ),
                    )
                  : ListView.separated(
                  itemCount: _bookings.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final b = _bookings[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.confirmation_number, color: Theme.of(context).primaryColor),
                        ),
                        title: Text('${b['serviceName'] ?? b['service'] ?? 'Service'} with ${b['providerName'] ?? b['provider'] ?? 'Provider'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${b['date']} at ${b['time']}'),
                            ]),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(b['address'] ?? 'Location not set', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ]),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    );
                  },
                ),
    );
  }
}
