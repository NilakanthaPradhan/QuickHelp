import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/slide_to_sign.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _textOffset;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.05)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_controller);

    _textOffset = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_controller);

    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSignInPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade400,
                  Colors.indigo.shade400,
                ],
              ),
            ),
          ),
          Positioned(
            top: -size.width * 0.15,
            left: -size.width * 0.15,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: _logoScale,
                    child: Hero(
                      tag: 'quickhelp-logo',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: SizedBox(
                            width: 92,
                            height: 92,
                            child: SvgPicture.asset(
                              'assets/logo.svg',
                              fit: BoxFit.cover,
                              placeholderBuilder: (ctx) => Center(
                                child: Icon(
                                  Icons.volunteer_activism,
                                  size: 56,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _textOffset,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Column(
                        children: const [
                          Text(
                            'Welcome to QuickHelp',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fast. Friendly. Reliable assistance.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _fade,
                    child: SizedBox(
                      width: double.infinity,
                      child: SlideToSignWidget(
                        onConfirm: _onSignInPressed,
                        height: 56,
                        label: 'Slide to sign in',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
