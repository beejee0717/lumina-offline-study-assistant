import 'package:flutter/material.dart';
import 'package:lumina/features/home/ui/settings_screen.dart';
import '../../../../core/theme/app_colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20),
            decoration: const BoxDecoration(color: AppColors.primaryPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  "Lumina",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "Offline Study Buddy",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_rounded,
            label: "All Notes",
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.bookmark_rounded,
            label: "Saved",
            onTap: () {
              // TODO: Navigate to Archive
            },
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart_rounded,
            label: "Statistics",
            onTap: () {
              // TODO: Show quiz progress
            },
          ),

          const Spacer(),

          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings_rounded,
            label: "Settings",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
