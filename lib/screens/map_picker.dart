import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'package:geolocator/geolocator.dart';

class MapPicker extends StatefulWidget {
  final lat.LatLng? initialPosition;
  const MapPicker({super.key, this.initialPosition});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final fm.MapController _controller = fm.MapController();
  lat.LatLng _center = lat.LatLng(20.5937, 78.9629); // default to India center
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _search() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    try {
      final locs = await locationFromAddress(q);
      if (locs.isNotEmpty) {
        final loc = locs.first;
        final target = lat.LatLng(loc.latitude, loc.longitude);
        setState(() => _center = target);
        _controller.move(target, 15.0);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not found')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search error')));
    }
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      if (widget.initialPosition != null) {
        _center = widget.initialPosition!;
      } else {
        final hasPermission = await Geolocator.checkPermission();
        if (hasPermission == LocationPermission.denied) await Geolocator.requestPermission();
        final pos = await Geolocator.getCurrentPosition();
        _center = lat.LatLng(pos.latitude, pos.longitude);
      }
    } catch (_) {
      // ignore and keep default
    } finally {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _controller.move(_center, 15.0);
        } catch (_) {}
      });
    }
  }

  void _confirm() {
    Navigator.of(context).pop(_center);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick location')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                fm.FlutterMap(
                  mapController: _controller,
                  options: fm.MapOptions(
                    onPositionChanged: (pos, _) {
                      // pos.center is non-nullable in this flutter_map version
                      _center = pos.center;
                    },
                  ),
                  children: [
                      fm.TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.quickhelp.app',
                      ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                        suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                ),
                Center(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Icon(Icons.location_on, size: 44, color: Color.fromRGBO(255, 0, 0, 0.9)),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 18,
                  child: ElevatedButton(onPressed: _confirm, child: const Text('Select this location')),
                ),
              ],
            ),
    );
  }
}
