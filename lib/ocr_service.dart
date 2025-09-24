import 'dart:convert';
import 'package:http/http.dart' as http;

class OCRService {
  static Future<String> extractTextWithAPI(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.ocr.space/parse/image')
      );
      
      request.fields['apikey'] = 'K89956196688957';
      request.fields['language'] = 'eng';
      request.fields['OCREngine'] = '2';
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

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
}