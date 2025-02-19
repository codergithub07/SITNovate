import 'dart:convert';
import 'dart:typed_data'; // Import this for Uint8List
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:voice_assistant/utils/secrets.dart';

class OpenAITTS {
  final String apiKey = Secrets.openAiApiKey;

  Future<void> speakText(String text) async {
    final Uri url = Uri.parse("https://api.openai.com/v1/audio/speech");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "model": "tts-1",
        "input": text,
        "voice": "alloy", // You can try "echo", "fable", etc.
      }),
    );

    if (response.statusCode == 200) {
      final Uint8List audioBytes = Uint8List.fromList(response.bodyBytes);
      _playAudio(audioBytes);
    } else {
      print("Error: ${response.body}");
    }
  }

  void _playAudio(Uint8List audioBytes) async {
    final player = AudioPlayer();
    await player.play(BytesSource(audioBytes));
  }
}
