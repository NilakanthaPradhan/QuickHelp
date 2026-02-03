import 'package:flutter/material.dart';
import 'package:quickhelp/services/theme_service.dart';

class DrawerThemeControls extends StatelessWidget {
  const DrawerThemeControls({super.key});

  @override
  Widget build(BuildContext context) {
    final swatches = [Colors.deepPurple, Colors.teal, Colors.indigo, Colors.orange];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette),
              const SizedBox(width: 12),
              const Expanded(child: Text('Theme', style: TextStyle(fontWeight: FontWeight.w600))),
              GestureDetector(
                onTap: () {
                  final nav = Navigator.of(context);
                  nav.pop();
                  Future.delayed(const Duration(milliseconds: 180), () {
                    nav.pushNamed('/settings');
                  });
                },
                child: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final c in swatches)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () async {
                      await ThemeService.instance.setSeedColor(c);
                    },
                    child: AnimatedBuilder(
                      animation: ThemeService.instance,
                      builder: (context, _) => CircleAvatar(
                        radius: 16,
                        backgroundColor: c,
                        child: ThemeService.instance.seedColor == c ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              AnimatedBuilder(
                animation: ThemeService.instance,
                builder: (context, _) => Switch(
                  value: ThemeService.instance.themeMode == ThemeMode.dark,
                  onChanged: (_) => ThemeService.instance.toggleDarkLight(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}
