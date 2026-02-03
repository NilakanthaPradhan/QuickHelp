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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: surface,
            boxShadow: [BoxShadow(color: Color.fromRGBO((theme.shadowColor.r * 255.0).round().clamp(0, 255), (theme.shadowColor.g * 255.0).round().clamp(0, 255), (theme.shadowColor.b * 255.0).round().clamp(0, 255), 0.04), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, Color.fromRGBO((color.r * 255.0).round().clamp(0, 255), (color.g * 255.0).round().clamp(0, 255), (color.b * 255.0).round().clamp(0, 255), 0.8)]),
                  boxShadow: [BoxShadow(color: Color.fromRGBO((color.r * 255.0).round().clamp(0, 255), (color.g * 255.0).round().clamp(0, 255), (color.b * 255.0).round().clamp(0, 255), 0.18), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Icon(icon, color: theme.colorScheme.onPrimary, size: 26),
              ),
              const SizedBox(height: 10),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Find trusted $title in your area', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
