import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lumina/core/services/ocr_service.dart';
import 'package:lumina/core/theme/app_colors.dart';
import 'package:lumina/core/utils/debug.dart';
import 'package:lumina/features/notes/ui/note_editor_screen.dart';
import 'package:lumina/features/notes/widgets/crop_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final OCRService _ocrService = OCRService();
  FlashMode _currentFlashMode = FlashMode.off;
  bool _shouldEdit = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize().then((_) async {
      await _controller.setFocusMode(FocusMode.auto);
      await _controller.setExposureMode(ExposureMode.auto);
      _controller.setFlashMode(FlashMode.off);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shouldEdit = prefs.getBool('should_edit') ?? true;
    });
  }

  Future<void> _updateEditPreference(bool value) async {
    setState(() => _shouldEdit = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('should_edit', value);
    dPrint("Preference saved: should_edit = $value");
  }

  Future<void> _toggleFlash() async {
    FlashMode nextMode;
    switch (_currentFlashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.torch;
        break;
      default:
        nextMode = FlashMode.off;
        break;
    }

    try {
      await _controller.setFlashMode(nextMode);
      setState(() {
        _currentFlashMode = nextMode;
      });
      dPrint("Flash mode changed to: $nextMode");
    } catch (e) {
      dPrint("Error setting flash mode: $e");
    }
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.torch:
        return Icons.flashlight_on_rounded;
      default:
        return Icons.flash_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller)),
                _buildScannerOverlay(),

                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(_getFlashIcon(), color: Colors.white),
                        onPressed: _toggleFlash,
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 100),
                      GestureDetector(
                        onTap: _takePicture,
                        child: _buildCaptureButton(),
                      ),
                      SizedBox(
                        width: 100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Edit Mode",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _shouldEdit,
                                onChanged: _updateEditPreference,
                                activeTrackColor: AppColors.primaryPurple
                                    .withValues(alpha: 0.5),
                                activeThumbColor: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 150),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _controller.takePicture();

      String? finalPath;

      if (_shouldEdit) {
        if (!mounted) {
          return;
        }
        final Uint8List? croppedBytes = await Navigator.push<Uint8List>(
          context,
          MaterialPageRoute(
            builder: (context) => CropScreen(imageFile: File(image.path)),
          ),
        );

        if (croppedBytes == null) return;

        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/cropped_image.png');
        await tempFile.writeAsBytes(croppedBytes);
        finalPath = tempFile.path;
      } else {
        finalPath = image.path;
      }
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String scannedText = await _ocrService.processImage(finalPath);

      if (mounted) {
        Navigator.pop(context);

        final String? reviewedText = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditorScreen(initialText: scannedText),
          ),
        );

        if (mounted && reviewedText != null) {
          Navigator.pop(context, reviewedText);
        }
      }
    } catch (e) {
      dPrint("Capture/Edit Error: $e");
    }
  }
}
