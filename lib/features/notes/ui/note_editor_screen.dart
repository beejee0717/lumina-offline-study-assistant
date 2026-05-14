import 'package:flutter/material.dart';

class NoteEditorScreen extends StatefulWidget {
  final String initialText;

  const NoteEditorScreen({super.key, required this.initialText});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Scan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () {
              Navigator.pop(context, _contentController.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Scanned content will appear here...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
