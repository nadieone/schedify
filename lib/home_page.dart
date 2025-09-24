import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'ocr_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _extractedText = "";
  bool _isProcessing = false;

  Future<void> _pickAndExtractText() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        setState(() {
          _extractedText = "❌ No file selected.";
        });
        return;
      }

      setState(() {
        _isProcessing = true;
        _extractedText = "⏳ Processing image...";
      });

      final filePath = result.files.first.path!;
      debugPrint("📂 Selected file: $filePath");

      final text = await OCRService.extractTextWithAPI(filePath);

      debugPrint("📜 OCR result length: ${text.length}");

      setState(() {
        _isProcessing = false;
        _extractedText = text;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _extractedText = "❌ Error: $e";
      });
      debugPrint("💥 Error details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedify OCR Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isProcessing ? null : _pickAndExtractText,
              child: _isProcessing 
                  ? const CircularProgressIndicator()
                  : const Text("📷 Pick Schedule Image"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _extractedText.isEmpty ? "Extracted text will appear here..." : _extractedText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}