import 'package:flutter/material.dart';

class ServiceTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int providerCount;

  const ServiceTile({
    super.key, 
    required this.title, 
    required this.icon, 
    required this.color, 
    required this.onTap, 
    this.providerCount = 0
  });

  @override
  State<ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<ServiceTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // In light mode, we want the tile to be white, with a soft colored border and icon
    // In dark mode, we want a slightly elevated surface color
    final bgColor = isDark ? theme.colorScheme.surfaceVariant : Colors.white;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark) 
              BoxShadow(
                color: widget.color.withOpacity(0.08),
                blurRadius: _isPressed ? 5 : 15,
                offset: Offset(0, _isPressed ? 2 : 8),
                spreadRadius: 1,
              ),
          ],
          border: Border.all(
            color: isDark ? Colors.white12 : widget.color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle background gradient accent in the corner
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withOpacity(isDark ? 0.3 : 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.2, 1.0],
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and Title
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(isDark ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.icon, color: widget.color, size: 30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    // Bottom Row: Providers and Book Now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Provider Count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.providerCount > 0 
                                ? theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1) 
                                : Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.group_rounded, 
                                size: 10, 
                                color: widget.providerCount > 0 ? theme.colorScheme.primary : Colors.grey
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.providerCount}',
                                style: TextStyle(
                                  color: widget.providerCount > 0 ? theme.colorScheme.primary : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Book Now
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Book',
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.arrow_forward_rounded, color: widget.color, size: 12),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
