import 'package:flutter/material.dart';
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
    _load();
  }

  Future<void> _load() async {
    final b = await BookingStore.getBookings();
    setState(() {
      _bookings = b;
      _loading = false;
    });
  }

  Future<void> _removeAt(int i) async {
    await BookingStore.removeBookingAt(i);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings yet'))
              : ListView.separated(
                  itemCount: _bookings.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final b = _bookings[i];
                    return ListTile(
                      title: Text('${b['service']} with ${b['provider']}'),
                      subtitle: Text('${b['date']}\n${b['address'] ?? '${b['lat']}, ${b['lng']}'}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeAt(i),
                      ),
                    );
                  },
                ),
    );
  }
}
