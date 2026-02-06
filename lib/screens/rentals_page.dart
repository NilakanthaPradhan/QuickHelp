import 'dart:async';
import 'package:flutter/material.dart';
import 'rental_finder_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'service_booking_page.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/aesthetic_widgets.dart';

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
                          showAestheticSnackbar(context, 'Contact initiated successfully! 📞');
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (context.mounted) Navigator.of(context).pop();
                          });
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
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Find Your Home 🏠', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.0)],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Map (Full Screen effect behind content, or top half)
          Positioned.fill(
             child: Column(
               children: [
                 Expanded(
                   flex: 5,
                   child: fm.FlutterMap(
                      mapController: _mapController,
                      options: fm.MapOptions(
                        initialCenter: lat.LatLng(_dummyRentals.first['lat'] as double, _dummyRentals.first['lng'] as double),
                        initialZoom: 14.0,
                      ),
                      children: [
                        fm.TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                  width: 60,
                                  height: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.blue, width: 2),
                                    ),
                                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                                  ),
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
                 Expanded(flex: 4, child: Container(color: Colors.white)), // Placeholder for list
               ],
             ),
          ),
          
          // Floating Search Bar
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search "Bangalore"...',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      suffixIcon: _isSearching
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                          : IconButton(
                              icon: const Icon(Icons.my_location, color: Colors.blue),
                              onPressed: _getLocation,
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final loc = _suggestions[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                          title: Text('${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}'),
                          onTap: () => _selectLocation(loc),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Draggable Bottom Sheet for Rentals
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.40,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(width: 40, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10))))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text('Nearby Places', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      
                      // Horizontal Highlight List
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _dummyRentals.length,
                          itemBuilder: (context, i) {
                            final r = _dummyRentals[i];
                            return Container(
                              width: 260,
                              margin: const EdgeInsets.only(right: 16, bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                   final target = lat.LatLng(r['lat'] as double, r['lng'] as double);
                                    try {
                                      _mapController.move(target, 15.0);
                                    } catch (_) {}
                                    _openRentalDetails(r);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Image.network(
                                        r['images'][0],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, __) => Container(height: 150, color: Colors.grey[200]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(r['price'], style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                                              Row(children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                                Text(' ${r['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ]),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(r['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          const Row(
                                            children: [
                                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                              Text(' 2.5 km away', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text('All Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const RentalFinderScreen(), // Embed the grid/list finder here
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
