import 'dart:async';
import 'package:flutter/material.dart';
import 'rental_finder_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'service_booking_page.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});

  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  Position? _currentPosition;
  bool _loadingLocation = false;
  final fm.MapController _mapController = fm.MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Location> _suggestions = [];
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      try {
        final locs = await locationFromAddress(query);
        if (mounted) setState(() => _suggestions = locs);
      } catch (_) {
        if (mounted) setState(() => _suggestions = []);
      }
    });
  }

  void _selectLocation(Location loc) {
    final target = lat.LatLng(loc.latitude, loc.longitude);
    _mapController.move(target, 14.0);
    setState(() {
      _suggestions = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> _searchLocation() async {
    // legacy direct search
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        _selectLocation(locations.first);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search error: $e')));
    } finally {
      setState(() => _isSearching = false);
    }
  }


  // Dummy rentals to display even before user location is available
  final List<Map<String, dynamic>> _dummyRentals = [
    {
      'title': 'Cozy Room Near Lake',
      'price': '₹8000',
      'lat': 12.9716,
      'lng': 77.5946,
      'rating': 4.6,
      'images': ['https://picsum.photos/600/300?image=101', 'https://picsum.photos/600/300?image=102'],
      'description': 'A calm cozy room near the lake with free Wi-Fi and breakfast.'
    },
    {
      'title': 'Downtown Studio',
      'price': '₹10000',
      'lat': 12.9725,
      'lng': 77.5890,
      'rating': 4.4,
      'images': ['https://picsum.photos/600/300?image=103'],
      'description': 'Modern studio apartment in the heart of town.'
    },
    {
      'title': 'Budget Room with Window',
      'price': '₹6000',
      'lat': 12.9680,
      'lng': 77.5965,
      'rating': 4.1,
      'images': ['https://picsum.photos/600/300?image=104'],
      'description': 'Affordable and clean room, close to public transport.'
    },
  ];

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        // permissions are denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        }
        setState(() => _loadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
      });

      // defer moving the map until after a frame to avoid calling the MapController
      // before the FlutterMap has been rendered (prevents "must be rendered at least once" exception)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(lat.LatLng(pos.latitude, pos.longitude), 15.0);
        } catch (_) {
          // ignore if the controller isn't ready yet
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  List<fm.Marker> _rentalMarkers() {
    if (_currentPosition == null) return [];
    final lat.LatLng center = lat.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    // create sample nearby rentals
    final sample = [
      {'title': 'Cozy Room A', 'price': '₹8000', 'lat': center.latitude + 0.002, 'lng': center.longitude + 0.002},
      {'title': 'Comfort Stay B', 'price': '₹10000', 'lat': center.latitude - 0.0025, 'lng': center.longitude + 0.0015},
      {'title': 'Budget Room C', 'price': '₹6000', 'lat': center.latitude + 0.0015, 'lng': center.longitude - 0.002},
    ];

    return sample.map((r) => fm.Marker(
          point: lat.LatLng(r['lat'] as double, r['lng'] as double),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _openRentalDetails(r),
            child: const Icon(Icons.house, color: Colors.deepPurple, size: 36),
          ),
        )).toList();
  }

  @override
  void initState() {
    super.initState();
    // try to get location quickly
    WidgetsBinding.instance.addPostFrameCallback((_) => _getLocation());
  }

  void _openRentalDetails(Map rental) {
    final images = rental['images'] as List<String>? ?? [
      'https://picsum.photos/800/400?random=1',
      'https://picsum.photos/800/400?random=2',
      'https://picsum.photos/800/400?random=3',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (context, sc) => SingleChildScrollView(
          controller: sc,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rental['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stack) => Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(((rental['rating'] as num?)?.toDouble() ?? 4.2).toStringAsFixed(1)),
                    const Spacer(),
                    Text('Price: ${rental['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(rental['description'] as String? ?? 'A comfortable place to stay. Clean rooms, friendly host, and good location.'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.book_online),
                        label: const Text('Book'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceBookingPage(serviceTitle: rental['title'] as String)));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact initiated')));
                        },
                        icon: const Icon(Icons.call),
                        label: const Text('Contact'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rentals')),
      body: Column(
        children: [
          Container(
            height: 260,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fm.FlutterMap(
                    mapController: _mapController,
                    options: fm.MapOptions(
                      initialCenter: lat.LatLng(_dummyRentals.first['lat'] as double, _dummyRentals.first['lng'] as double),
                      initialZoom: 13.0,
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.quickhelp.app',
                      ),
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 50,
                          size: const Size(42, 42),
                          markers: [
                            ..._rentalMarkers(),
                            if (_currentPosition != null)
                              fm.Marker(
                                point: lat.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                width: 80,
                                height: 80,
                                child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                              ),
                          ],
                          builder: (context, markers) {
                            return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                              child: Text('${markers.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search area...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: _isSearching
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.search),
                          onPressed: _searchLocation,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Positioned(
                    top: 70,
                    left: 20,
                    right: 20,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final loc = _suggestions[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            title: Text('${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}'),
                            subtitle: const Text('Tap to move map'),
                            onTap: () => _selectLocation(loc),
                          );
                        },
                      ),
                    ),
                  ),
                if (_loadingLocation)
                  const Positioned(
                    bottom: 12,
                    right: 12,
                    child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
          ),
          // horizontal cards for quick browsing
          const SizedBox(height: 12),
          SizedBox(
            height: 128,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _dummyRentals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final r = _dummyRentals[i];
                return GestureDetector(
                  onTap: () {
                    final target = lat.LatLng(r['lat'] as double, r['lng'] as double);
                    try {
                      _mapController.move(target, 15.0);
                    } catch (_) {}
                    _openRentalDetails(r);
                  },
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            r['images'][0] as String,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(width: 100, height: 100, color: Colors.grey[100], child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Text('${r['price']}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(((r['rating'] as num?)?.toDouble() ?? 4.0).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(child: RentalFinderScreen()),
        ],
      ),
    );
  }
}
