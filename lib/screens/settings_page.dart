import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Color> _colors = [
    Colors.deepPurple,
    Colors.teal,
    Colors.indigo,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.blueGrey,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
  ];

  ThemeMode get _mode => ThemeService.instance.themeMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              ChoiceChip(
                label: const Text('Light'),
                selected: _mode == ThemeMode.light,
                onSelected: (_) => ThemeService.instance.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Dark'),
                selected: _mode == ThemeMode.dark,
                onSelected: (_) => ThemeService.instance.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('System'),
                selected: _mode == ThemeMode.system,
                onSelected: (_) => ThemeService.instance.setThemeMode(ThemeMode.system),
              ),
            ]),
            const SizedBox(height: 16),
            // Live preview so users can see the theme and accent color effect
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Color.fromRGBO((Theme.of(context).shadowColor.r * 255.0).round().clamp(0, 255), (Theme.of(context).shadowColor.g * 255.0).round().clamp(0, 255), (Theme.of(context).shadowColor.b * 255.0).round().clamp(0, 255), 0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 34, decoration: BoxDecoration(color: ThemeService.instance.seedColor, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [ThemeService.instance.seedColor, Color.fromRGBO((ThemeService.instance.seedColor.r * 255.0).round().clamp(0, 255), (ThemeService.instance.seedColor.g * 255.0).round().clamp(0, 255), (ThemeService.instance.seedColor.b * 255.0).round().clamp(0, 255), 0.8)]))),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Service title', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Small description', style: Theme.of(context).textTheme.bodySmall),
                        ])
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Accent color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _colors
                    .map((c) => GestureDetector(
                          onTap: () => ThemeService.instance.setSeedColor(c),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c,
                              border: ThemeService.instance.seedColor == c ? Border.all(color: Colors.white, width: 3) : null,
                              boxShadow: [BoxShadow(color: Color.fromRGBO((c.r * 255.0).round().clamp(0, 255), (c.g * 255.0).round().clamp(0, 255), (c.b * 255.0).round().clamp(0, 255), 0.25), blurRadius: 6, offset: const Offset(0, 3))],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('Selected: ', style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
