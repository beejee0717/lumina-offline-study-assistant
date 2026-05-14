import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../utils/debug.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> processImage(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    
    try {
      dPrint("OCR: Starting text recognition...");
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // 1. Get the original formatted text
      String rawText = recognizedText.text;

      // 2. Create a "Single Line" version for debugging
      // This replaces all newlines (\n or \r) with a space
      String singleLineText = rawText.replaceAll(RegExp(r'[\r\n]+'), ' ');
      
      // 3. Remove multiple spaces 
      singleLineText = singleLineText.replaceAll(RegExp(r'\s+'), ' ').trim();

      dPrint("OCR: Success. Extracted ${rawText.length} characters.");
      
      // 4. Output the single string
      dPrint("--- RAW OUTPUT STRING ---");
      dPrint(singleLineText.isEmpty ? "EMPTY_RESULT" : singleLineText);
      dPrint("-------------------------");

      return rawText; 
    } catch (e) {
      dPrint("OCR Error: $e");
      return "";
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}