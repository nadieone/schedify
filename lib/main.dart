import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: OCRScreen());
  }
}

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  String _extractedText = "";
  bool _isProcessing = false;

  Future<String> _extractTextWithAPI(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.ocr.space/parse/image')
      );
      
      // Free API key from OCR.space
      request.fields['apikey'] = 'K89956196688957';
      request.fields['language'] = 'eng';
      request.fields['OCREngine'] = '2'; // Better engine
      
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imagePath
      ));

      var response = await request.send();
      var result = await response.stream.bytesToString();
      var jsonResult = json.decode(result);
      
      if (jsonResult['ParsedResults'] != null && 
          jsonResult['ParsedResults'].length > 0) {
        return jsonResult['ParsedResults'][0]['ParsedText'] ?? "No text found";
      } else {
        return "OCR failed: ${jsonResult['ErrorMessage'] ?? 'Unknown error'}";
      }
    } catch (e) {
      return "API Error: $e";
    }
  }

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

      final text = await _extractTextWithAPI(filePath);

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