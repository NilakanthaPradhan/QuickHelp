import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
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
                    fm.TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
                  ],
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
