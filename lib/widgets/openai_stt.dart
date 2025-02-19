import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/widgets/openai_tts.dart';

class OpenAISpeechToText {
  final String apiKey = "YOUR_OPENAI_API_KEY";

  Future<String?> transcribeAudio(File audioFile) async {
    final Uri url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['model'] = 'whisper-1'
      ..fields['language'] = 'hi' // Change to 'en' for English
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['text'];
    } else {
      print("Error: ${response.reasonPhrase}");
      return null;
    }
  }
}

void playTTS() {
  OpenAITTS tts = OpenAITTS();
  tts.speakText("नमस्ते दुनिया");
}
