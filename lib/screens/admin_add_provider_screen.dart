import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'map_picker.dart';
import '../services/api_service.dart';

class AdminAddProviderScreen extends StatefulWidget {
  const AdminAddProviderScreen({super.key});

  @override
  State<AdminAddProviderScreen> createState() => _AdminAddProviderScreenState();
}

class _AdminAddProviderScreenState extends State<AdminAddProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedService = 'Maid';
  String _selectedGender = 'Female';
  lat.LatLng? _pickedLocation;
  bool _isSubmitting = false;

  final List<String> _serviceTypes = [
    'Maid', 'Plumber', 'Painter', 'Electrician', 'Carpenter', 'Cleaner', 'Gardener', 'Pest Control', 'AC Repair'
  ];

  void _pickLocation() async {
    final result = await Navigator.of(context).push<lat.LatLng>(
      MaterialPageRoute(builder: (_) => MapPicker(initialPosition: _pickedLocation)),
    );
    if (result != null) {
      setState(() => _pickedLocation = result);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a location')));
        return;
      }

      setState(() => _isSubmitting = true);

      final provider = {
        'name': _nameController.text,
        'serviceType': _selectedService,
        'gender': _selectedGender,
        'price': _priceController.text,
        'phone': _phoneController.text,
        'rating': 5.0, // Default rating for new provider
        'lat': _pickedLocation!.latitude,
        'lng': _pickedLocation!.longitude,
        'image': 'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}', // Random avatar
      };

      final success = await ApiService.createProvider(provider);

      setState(() => _isSubmitting = false);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provider Added Successfully!')));
        _nameController.clear();
        _priceController.clear();
        _phoneController.clear();
        setState(() => _pickedLocation = null);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add provider')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Provider')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Provider Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: const InputDecoration(labelText: 'Service Type', border: OutlineInputBorder()),
                items: _serviceTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedService = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: ['Male', 'Female', 'Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (e.g. ₹300/hr)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: Text(_pickedLocation == null ? 'Pick Service Location' : 'Location Selected'),
                subtitle: _pickedLocation != null ? Text('${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}') : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickLocation,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting ? const CircularProgressIndicator() : const Text('Add Provider'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
