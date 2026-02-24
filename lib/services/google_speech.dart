import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PiperTtsService {
  static const String baseUrl = 'http://185.188.249.63:8000';

  /// Generate Arabic speech and return the generated audio file path.
  Future<String> generateArabic(String text) async {
    if (text.trim().isEmpty) return "";

    final url = Uri.parse('$baseUrl/synthesize/');

    final payload = {"text": text, "voice_id": "ar-male", "add_tashkeel": true};

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('TTS failed: ${response.statusCode} ${response.body}');
    }

    // Response is WAV audio bytes
    final bytes = response.bodyBytes;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/piper_tts_ar.wav');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  /// Generate English speech and return the generated audio file path.
  Future<String> generateEnglish(String text) async {
    if (text.trim().isEmpty) return "";

    final url = Uri.parse('$baseUrl/synthesize/');

    final payload = {
      "text": text,
      "voice_id": "en-female",
      "add_tashkeel": false,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('TTS failed: ${response.statusCode} ${response.body}');
    }

    // Response is WAV audio bytes
    final bytes = response.bodyBytes;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/piper_tts_en.wav');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
