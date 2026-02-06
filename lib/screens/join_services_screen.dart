import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as lat;
import 'map_picker.dart';
import '../services/api_service.dart';
import '../widgets/aesthetic_widgets.dart';

class JoinServicesScreen extends StatefulWidget {
  const JoinServicesScreen({super.key});

  @override
  State<JoinServicesScreen> createState() => _JoinServicesScreenState();
}

class _JoinServicesScreenState extends State<JoinServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _selectedServiceType;
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _serviceTypes = [
    'Maid', 'Plumber', 'Electrician', 'Carpenter', 'Painter', 'Gardener', 'Pest Control', 'AC Repair', 'Cleaner'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ApiService.currentUser == null || ApiService.currentUser!.id == -1) {
        _showLoginDialog();
      }
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to join as a provider.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back
            }, 
            child: const Text('Cancel')
          ),
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
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a photo')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final fields = {
        'name': _nameController.text,
        'serviceType': _selectedServiceType!,
        'description': _descController.text,
        'location': _locationController.text,
        'phoneNumber': _phoneController.text,
      };
      
      if (_selectedLat != null) fields['lat'] = _selectedLat.toString();
      if (_selectedLng != null) fields['lng'] = _selectedLng.toString();

      final success = await ApiService.submitProviderRequest(fields, _imageFile);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (!mounted) return;
        showAestheticSnackbar(context, 'Request submitted successfully! Admin will review it.');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit request. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join as Provider')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: const InputDecoration(labelText: 'Service Type', border: OutlineInputBorder()),
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedServiceType = value),
                validator: (value) => value == null ? 'Please select a service' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description / Experience', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location / City', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter location' : null,
                    ),
                   ),
                   const SizedBox(width: 8),
                   IconButton(
                    onPressed: _pickLocationOnMap,
                    icon: const Icon(Icons.map, color: Colors.deepPurple),
                    tooltip: 'Pick on Map',
                   )
                ],
              ),
              if (_selectedLat != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '📍 Coordinates: ${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 20),
              const Text('Profile Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text('Tap to upload photo'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _selectedLat;
  double? _selectedLng;

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPicker()),
    );

    if (result != null && result is lat.LatLng) {
      setState(() {
        _selectedLat = result.latitude;
        _selectedLng = result.longitude;
        // Optionally update text field if empty
        if (_locationController.text.isEmpty) {
          _locationController.text = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
        }
      });
    }
  }
}
