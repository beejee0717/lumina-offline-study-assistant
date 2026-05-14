import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lumina/core/theme/app_colors.dart';
import 'package:lumina/core/widgets/buttons.dart';
import 'package:lumina/features/notes/ui/note_page.dart';

class NoteController {
  static final Box _box = Hive.box('notes');

  static void showNameDialog(
    BuildContext context, {
    required bool isFolder,
    dynamic parentId,
  }) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFolder ? "New Folder" : "New Note",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isFolder ? "Enter folder name" : "Enter note title",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    isFolder
                        ? Icons.folder_open_rounded
                        : Icons.edit_note_rounded,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  
                  
                  Expanded(
                    child: BigButton(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context),
                      color: Colors.transparent,
                      textColor: Colors.grey[600],
                      hasShadow: false,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ), 
                  Expanded(
                    child: BigButton(
                      textColor: Colors.white,
                      label: 'Create',
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          _createEntry(
                            context,
                            controller.text,
                            isFolder,
                            parentId,
                          );
                        }
                      },
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  static void _createEntry(
    BuildContext context,
    String name,
    bool isFolder,
    dynamic parentId,
  ) async {
    final newEntry = {
      'name': name,
      'isFolder': isFolder,
      'content': '',
      'parentId': parentId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final int key = await _box.add(newEntry);

    if (context.mounted) {
      Navigator.pop(context);
      if (!isFolder) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotePage(noteKey: key)),
        );
      }
    }
  }
}
