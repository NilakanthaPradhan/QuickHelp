import 'package:flutter/material.dart';
import 'services_screen.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: const ServicesScreen(),
    );
  }
}
