import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';
import 'auth_choice_screen.dart';

class WelcomeSliderScreen extends StatefulWidget {
  const WelcomeSliderScreen({super.key});

  @override
  State<WelcomeSliderScreen> createState() => _WelcomeSliderScreenState();
}

class _WelcomeSliderScreenState extends State<WelcomeSliderScreen> {
  Future<void> _onSlideComplete(ActionSliderController controller) async {
    controller.success(); // Show success immediately
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo or Image can go here
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_work_rounded, size: 64, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              Text(
                'QuickHelp',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Home Services Expert',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const Spacer(),
              ActionSlider.standard(
                sliderBehavior: SliderBehavior.stretch,
                // rolling: true, // Removed for cleaner/faster feel
                width: double.infinity,
                backgroundColor: Colors.white,
                toggleColor: Colors.deepPurple,
                iconAlignment: Alignment.centerRight,
                loadingIcon: const SizedBox(
                  width: 50,
                  child: Center(
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                    ),
                  ),
                ),
                successIcon: const SizedBox(
                  width: 50,
                  child: Center(child: Icon(Icons.check_rounded, color: Colors.white)),
                ),
                icon: const SizedBox(
                  width: 50,
                  child: Center(child: Icon(Icons.arrow_forward_rounded, color: Colors.white)),
                ),
                action: _onSlideComplete,
                child: const Text('Slide to Open', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
