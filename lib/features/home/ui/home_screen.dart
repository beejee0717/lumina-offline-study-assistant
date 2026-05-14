import 'package:flutter/material.dart';
import 'package:lumina/features/home/widgets/home_drawer.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lumina',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'sort') {
                // TODO: Implement sort logic
              } else if (value == 'view') {
                // TODO: Toggle Grid/List
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'view',
                child: ListTile(
                  leading: Icon(Icons.grid_view_rounded),
                  title: Text("Switch to Grid"),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  leading: Icon(Icons.sort_by_alpha_rounded),
                  title: Text("Sort by Name"),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 100,
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              "No notes yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Scan your study materials to begin.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open Camera for OCR
        },
        backgroundColor: AppColors.primaryPurple,
        label: const Text("Scan Note", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
      ),
    );
  }
}
