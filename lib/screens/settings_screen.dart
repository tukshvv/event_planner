import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_planner/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListTile(
        title: const Text('Dark Mode'),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => themeProvider.toggleTheme(),
        ),
      ),
    );
  }
}
