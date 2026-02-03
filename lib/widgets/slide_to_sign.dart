import 'package:flutter/material.dart';

class SlideToSignWidget extends StatefulWidget {
  final VoidCallback onConfirm;
  final double height;
  final String label;
  const SlideToSignWidget({super.key, required this.onConfirm, this.height = 56, this.label = 'Slide to sign in'});

  @override
  State<SlideToSignWidget> createState() => _SlideToSignWidgetState();
}

class _SlideToSignWidgetState extends State<SlideToSignWidget> with SingleTickerProviderStateMixin {
  double _drag = 0.0;
  bool _confirmed = false;
  late double _maxDrag;
  late AnimationController _animController;
  late Animation<double> _anim;

  static const double _thumbSize = 48.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          _drag = _anim.value;
        });
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateTo(double to) {
    _animController.stop();
    _anim = Tween<double>(begin: _drag, end: to).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController
      ..value = 0
      ..forward();
  }

  void _onPanStart(DragStartDetails details) {
    if (_confirmed) return;
    _animController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_confirmed) return;
    setState(() {
      _drag = (_drag + details.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_confirmed) return;
    final threshold = _maxDrag * 0.65;
    if (_drag >= threshold) {
      setState(() {
        _drag = _maxDrag;
        _confirmed = true;
      });
      Future.delayed(const Duration(milliseconds: 180), () {
        widget.onConfirm();
      });
    } else {
      _animateTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _maxDrag = (constraints.maxWidth - _thumbSize - 8).clamp(0.0, double.infinity);
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Center(
              child: Text(
                _confirmed ? 'Signed in' : widget.label,
                style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.9), fontWeight: FontWeight.w600),
              ),
            ),
            Positioned(
              left: _drag,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: _confirmed ? Colors.greenAccent : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 6, offset: const Offset(0, 4)), 
                    ],
                  ),
                  child: Icon(
                    _confirmed ? Icons.check : Icons.arrow_forward,
                    color: _confirmed ? Colors.black87 : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
