import 'package:flutter/material.dart';

class ServiceTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ServiceTile({super.key, required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.cardColor;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: surface,
            boxShadow: [BoxShadow(color: Color.fromRGBO((theme.shadowColor.r * 255.0).round().clamp(0, 255), (theme.shadowColor.g * 255.0).round().clamp(0, 255), (theme.shadowColor.b * 255.0).round().clamp(0, 255), 0.04), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Color.fromRGBO((color.r * 255.0).round().clamp(0, 255), (color.g * 255.0).round().clamp(0, 255), (color.b * 255.0).round().clamp(0, 255), 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Find trusted $title in your area', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
