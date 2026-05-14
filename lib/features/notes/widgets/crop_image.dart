import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart' as img;

class CropScreen extends StatefulWidget {
  final File imageFile;
  const CropScreen({super.key, required this.imageFile});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();

  void _rotate(bool right) {
    if (right) {
      _editorKey.currentState?.rotate();
    } else {
      _editorKey.currentState?.rotate();
      _editorKey.currentState?.rotate();
      _editorKey.currentState?.rotate();
    }
  }

  Future<void> _onSave() async {
    final state = _editorKey.currentState;
    if (state == null) return;

    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final Rect? cropRect = state.getCropRect();
    final Uint8List rawData = state.rawImageData;
    final EditActionDetails editAction = state.editAction!;

    final Uint8List? result = await compute(_processImage, {
      'data': rawData,
      'rect': cropRect,
      'editAction': editAction,
    });

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Image', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _onSave,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ExtendedImage.file(
              widget.imageFile,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.editor,
              extendedImageEditorKey: _editorKey,

              cacheRawData: true,
              initEditorConfigHandler: (state) {
                return EditorConfig(
                  maxScale: 8.0,
                  cropRectPadding: const EdgeInsets.all(20.0),
                  hitTestSize: 20.0,

                  editorMaskColorHandler: (context, pointerDown) {
                    return Colors.black.withValues(
                      alpha: pointerDown ? 0.4 : 0.7,
                    );
                  },
                  lineColor: Colors.white,
                  cornerColor: Colors.white,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.rotate_left, color: Colors.white),
                  onPressed: () => _rotate(false),
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.rotate_right, color: Colors.white),
                  onPressed: () => _rotate(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Uint8List _processImage(Map<String, dynamic> params) {
  final Uint8List data = params['data'];
  final Rect rect = params['rect'];
  final EditActionDetails action = params['editAction'];

  img.Image? image = img.decodeImage(data);
  if (image == null) return data;

  if (action.hasRotateDegrees) {
    image = img.copyRotate(image, angle: action.rotateDegrees);
  }

  if (action.flipY) {
    image = img.flip(image, direction: img.FlipDirection.horizontal);
  }

  image = img.copyCrop(
    image,
    x: rect.left.toInt(),
    y: rect.top.toInt(),
    width: rect.width.toInt(),
    height: rect.height.toInt(),
  );

  return Uint8List.fromList(img.encodeJpg(image));
}
