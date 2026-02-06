import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart' as lat;
import 'map_picker.dart';
import 'package:geocoding/geocoding.dart';
import '../services/booking_store.dart';
import '../services/api_service.dart';

class ServiceBookingPage extends StatefulWidget {
  final String serviceTitle;
  const ServiceBookingPage({super.key, required this.serviceTitle});

  @override
  State<ServiceBookingPage> createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  List<dynamic> providers = [];
  bool _isLoadingProviders = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final fetched = await ApiService.getProviders(widget.serviceTitle);
    if (mounted) {
      setState(() {
        providers = fetched;
        _isLoadingProviders = false;
        // Auto-select first if available? Or keep null.
      });
    }
  }

  int? _selectedProviderIndex;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
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

  void _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() => _selectedTime = picked);
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
    if (_selectedProviderIndex == null || _selectedDate == null || _selectedTime == null || _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select provider, date, time and location')));
      return;
    }

    if (ApiService.currentUser == null || ApiService.currentUser!.id == -1) {
       showDialog(
         context: context, 
         builder: (ctx) => AlertDialog(
           title: const Text('Login Required'),
           content: const Text('You need to be logged in to book a service.'),
           actions: [
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
             ElevatedButton(
               onPressed: () {
                 Navigator.pop(ctx);
                 Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
               }, 
               child: const Text('Login')
             )
           ],
         )
       );
       return;
    }

    final p = providers[_selectedProviderIndex!];
    final dateStr = _selectedDate!.toLocal().toString().split(' ')[0];
    final timeStr = _selectedTime!.format(context);
    
    final booking = {
      'service': widget.serviceTitle,
      'provider': p['name'],
      'date': dateStr,
      'time': timeStr,
      'lat': _pickedLocation!.latitude,
      'lng': _pickedLocation!.longitude,
      'address': _pickedAddress ?? '',
    };

    // await BookingStore.saveBooking(booking); // Deprecated local store
    final success = await ApiService.createBooking(booking);

    if (!mounted) return;
    
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booked ${widget.serviceTitle} with ${p['name']} successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to book. Server error.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text('Book ${widget.serviceTitle}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSelectionCard(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: _selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0],
                    onTap: _pickDate,
                    isActive: _selectedDate != null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectionCard(
                    icon: Icons.access_time,
                    title: 'Time',
                    value: _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                    onTap: _pickTime,
                    isActive: _selectedTime != null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _openMapPicker,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _pickedLocation != null ? Theme.of(context).primaryColor : Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                      child: const Icon(Icons.location_on, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_pickedLocation == null ? 'Select Service Location' : 'Location Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            _pickedAddress?.isNotEmpty == true ? _pickedAddress! : (_pickedLocation != null ? '${_pickedLocation!.latitude.toStringAsFixed(4)}, ${_pickedLocation!.longitude.toStringAsFixed(4)}' : 'Tap to choose on map'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _isLoadingProviders 
                ? const Center(child: CircularProgressIndicator())
                : providers.isEmpty 
                    ? const Padding(padding: EdgeInsets.all(16), child: Text('No providers available for this service.'))
                    : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (_visibleProviders < providers.length) ? _visibleProviders + 1 : providers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i < _visibleProviders && i < providers.length) {
                  final p = providers[i];
                  final selected = _selectedProviderIndex == i;
                  return InkWell(
                    onTap: () => setState(() => _selectedProviderIndex = i),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: selected ? Theme.of(context).primaryColor : Colors.transparent, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28, 
                            backgroundImage: (p['photoData'] != null && (p['photoData'] as String).isNotEmpty)
                                ? MemoryImage(base64Decode(p['photoData'] as String))
                                : (p['image'] != null && (p['image'] as String).isNotEmpty
                                    ? NetworkImage(p['image'] as String)
                                    : null) as ImageProvider?,
                            child: (p['photoData'] == null && p['image'] == null) 
                                ? const Icon(Icons.person) 
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['name']?.toString() ?? 'Provider', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                    const SizedBox(width: 4),
                                    Text((p['rating'] ?? 0.0).toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 10),
                                    Text(p['price']?.toString() ?? '', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text('• ${p['gender'] ?? 'Unknown'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${(p['lat'] ?? 0.0).toStringAsFixed(2)}, ${(p['lng'] ?? 0.0).toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (selected) Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 28),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: TextButton(
                    onPressed: () => setState(() => _visibleProviders = (_visibleProviders + 3).clamp(0, providers.length)),
                    child: const Text('View more providers'),
                  ),
                );
              },
            ),
            const SizedBox(height: 100), // space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({required IconData icon, required String title, required String value, required VoidCallback onTap, required bool isActive}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? Theme.of(context).primaryColor : Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isActive ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
