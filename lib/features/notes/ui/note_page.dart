import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'camera_screen.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class NotePage extends StatefulWidget {
  final int noteKey;
  const NotePage({super.key, required this.noteKey});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _box = Hive.box('notes');
  late TextEditingController _mainController;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  int _wordCount = 0;
  bool _isReadOnly = true; 

  @override
  void initState() {
    super.initState();
    final data = _box.get(widget.noteKey);
    _mainController = TextEditingController(text: data['content']);
    _updateWordCount(_mainController.text);
  }

  void _updateWordCount(String text) {
    setState(() {
      _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  void _saveWithDebounce() {
    _updateWordCount(_mainController.text);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final data = _box.get(widget.noteKey);
      data['content'] = _mainController.text;
      _box.put(widget.noteKey, data);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mainController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteData = _box.get(widget.noteKey);
    final DateTime timestamp = DateTime.parse(noteData['timestamp']);
    final String formattedDate = DateFormat('MMMM d, y').format(timestamp);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(noteData['name'],
                style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(formattedDate, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        actions: [
          
          IconButton(
            icon: Icon(_isReadOnly ? Icons.edit_outlined : Icons.chrome_reader_mode_outlined,
                color: AppColors.primaryPurple),
            onPressed: () => setState(() => _isReadOnly = !_isReadOnly),
          ),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true, 
                  thickness: 6,
                  radius: const Radius.circular(10),
                  child: TextField(
                    controller: _mainController,
                    scrollController: _scrollController,
                    readOnly: _isReadOnly, 
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => _saveWithDebounce(),
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: _isReadOnly ? Colors.black87 : Colors.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(24),
                      border: InputBorder.none,
                      hintText: _isReadOnly ? "" : "Start typing...",
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Text("$_wordCount words",
                    style: const TextStyle(color: AppColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!_isReadOnly) ...[
                  Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.green[400]),
                  const SizedBox(width: 6),
                  Text("Auto-saved", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ] else
                  Text("Reading Mode", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      
      floatingActionButton: _isReadOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final String? scannedResult = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );

                if (scannedResult != null && scannedResult.isNotEmpty) {
                  setState(() {
                    _mainController.text = "${_mainController.text}\n\n$scannedResult".trim();
                    _saveWithDebounce();
                  });
                }
              },
              backgroundColor: AppColors.primaryPurple,
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              label: const Text("Scan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }
}