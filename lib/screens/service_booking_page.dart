import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'map_picker.dart';
import 'package:geocoding/geocoding.dart';
import '../services/booking_store.dart';

class ServiceBookingPage extends StatefulWidget {
  final String serviceTitle;
  const ServiceBookingPage({super.key, required this.serviceTitle});

  @override
  State<ServiceBookingPage> createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  final List<Map<String, dynamic>> providers = [
    {'name': 'Asha', 'price': '₹300/hr', 'phone': '+91 90000 00001', 'image': 'https://i.pravatar.cc/150?img=1', 'rating': 4.5},
    {'name': 'Sunita', 'price': '₹350/hr', 'phone': '+91 90000 00002', 'image': 'https://i.pravatar.cc/150?img=2', 'rating': 4.7},
    {'name': 'Deepak', 'price': '₹250/hr', 'phone': '+91 90000 00003', 'image': 'https://i.pravatar.cc/150?img=3', 'rating': 4.1},
    {'name': 'Rohit', 'price': '₹400/hr', 'phone': '+91 90000 00004', 'image': 'https://i.pravatar.cc/150?img=4', 'rating': 4.8},
    {'name': 'Kavita', 'price': '₹320/hr', 'phone': '+91 90000 00005', 'image': 'https://i.pravatar.cc/150?img=5', 'rating': 4.3},
    {'name': 'Manish', 'price': '₹280/hr', 'phone': '+91 90000 00006', 'image': 'https://i.pravatar.cc/150?img=6', 'rating': 4.0},
  ];

  int? _selectedProviderIndex;
  DateTime? _selectedDate;
  lat.LatLng? _pickedLocation;
  String? _pickedAddress;
  int _visibleProviders = 3;

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() => _selectedDate = picked);
    }
  }

  Future<List<Placemark>> _reverseGeocode(double latV, double lngV) async {
    // moved geocoding import to top when adding dependency
    return await placemarkFromCoordinates(latV, lngV);
  }

  void _openMapPicker() async {
    final result = await Navigator.of(context).push<lat.LatLng>(MaterialPageRoute(builder: (_) => MapPicker(initialPosition: _pickedLocation)));
    if (result != null) {
      if (!mounted) return;
      setState(() => _pickedLocation = result);
      // reverse geocode
      try {
        final placemarks = await _reverseGeocode(result.latitude, result.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          if (!mounted) return;
          setState(() => _pickedAddress = '${p.name ?? ''} ${p.locality ?? ''} ${p.subLocality ?? ''} ${p.postalCode ?? ''}'.trim());
        }
      } catch (_) {
        // ignore
      }
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedProviderIndex == null || _selectedDate == null || _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select provider, date and location')));
      return;
    }

    final p = providers[_selectedProviderIndex!];
    final booking = {
      'service': widget.serviceTitle,
      'provider': p['name'],
      'date': _selectedDate!.toLocal().toString().split(' ')[0],
      'lat': _pickedLocation!.latitude,
      'lng': _pickedLocation!.longitude,
      'address': _pickedAddress ?? '',
    };

    await BookingStore.saveBooking(booking);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booked ${widget.serviceTitle} with ${p['name']} on ${_selectedDate!.toLocal().toString().split(' ')[0]}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.serviceTitle}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Providers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: (_visibleProviders < providers.length) ? _visibleProviders + 1 : providers.length,
                separatorBuilder: (context, index) => const Divider(height: 12),
                itemBuilder: (context, i) {
                  if (i < _visibleProviders && i < providers.length) {
                    final p = providers[i];
                    final selected = _selectedProviderIndex == i;
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(p['image'] as String)),
                      title: Text(p['name'] as String),
                      subtitle: Row(
                        children: [
                          Text(p['price'] as String),
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text((p['rating'] as double).toString()),
                        ],
                      ),
                      trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : ElevatedButton(
                        onPressed: () => setState(() => _selectedProviderIndex = i),
                        child: const Text('Select'),
                      ),
                      onTap: () => setState(() => _selectedProviderIndex = i),
                    );
                  }

                  // load more tile
                  return TextButton(
                    onPressed: () => setState(() => _visibleProviders = (_visibleProviders + 3).clamp(0, providers.length)),
                    child: const Text('Load more providers'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(_selectedDate == null ? 'No date selected' : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}')),
                TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(_pickedLocation == null ? 'No location selected' : (_pickedAddress == null || _pickedAddress!.isEmpty) ? 'Location: ${_pickedLocation!.latitude.toStringAsFixed(4)}, ${_pickedLocation!.longitude.toStringAsFixed(4)}' : _pickedAddress!)),
                TextButton(onPressed: _openMapPicker, child: const Text('Pick on Map')),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _confirmBooking, child: const Text('Confirm Booking')),
            ),
          ],
        ),
      ),
    );
  }
}
