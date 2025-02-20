import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:voice_assistant/utils/secret.dart';

class OpenAITTS {
  final String apiKey = Secrets.openAiApiKey;

  // Use a Singleton AudioPlayer instance
  static final AudioPlayer _player = AudioPlayer();

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
        "voice": "onyx",
      }),
    );

    if (response.statusCode == 200) {
      final Uint8List audioBytes = Uint8List.fromList(response.bodyBytes);
      await _player.play(BytesSource(audioBytes));
    } else {
      print("Error: ${response.body}");
    }
  }

  /// **Stop TTS playback manually from another file**
  void stopTTS() {
    _player.stop();
  }

  /// **Dispose of the audio player when done**
  void dispose() {
    _player.dispose();
  }
}
