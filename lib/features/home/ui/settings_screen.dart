import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader("Appearance"),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              return ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: currentMode == ThemeMode.dark,
                  activeThumbColor: AppColors.primaryPurple,
                  onChanged: (bool value) async {
                    themeNotifier.value = value
                        ? ThemeMode.dark
                        : ThemeMode.light;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'theme_mode',
                      value ? 'dark' : 'light',
                    );
                  },
                ),
              );
            },
          ),

          const Divider(),
          _buildSectionHeader("Study Preferences"),
          _buildPlaceholderTile(
            Icons.quiz_outlined,
            "Default Quiz Length",
            "10 Questions",
          ),
          _buildPlaceholderTile(Icons.timer_outlined, "Quiz Timer", "Enabled"),

          const Divider(),
          _buildSectionHeader("Data & Privacy"),
          _buildPlaceholderTile(
            Icons.storage_outlined,
            "Storage Usage",
            "24 MB",
          ),
          _buildPlaceholderTile(
            Icons.download_outlined,
            "Export Data",
            "JSON / PDF",
          ),

          const Divider(),
          _buildSectionHeader("About"),
          _buildPlaceholderTile(
            Icons.info_outline,
            "Lumina Version",
            "1.0.0+1",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPlaceholderTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {},
    );
  }
}
