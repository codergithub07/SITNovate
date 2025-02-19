import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import 'package:voice_assistant/utils/secrets.dart';

class ElevenLabsTTS {
  final String apiKey = Secrets.eleApiKey;
  final String voiceId = "n6BcoS0QyLMPmFXWu1Bm"; // Replace with a real Voice ID

  Future<void> getAudio(String text, {double style = 1.0}) async {
    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'xi-api-key': apiKey,
      },
      body: jsonEncode({
        'text': text,
        'voice_settings': {
          'stability': 0.4,
          'similarity_boost': 0.5,
          'style': style, // Adjust from 0.0 (calm) to 1.0 (angry)
        }
      }),
    );

    if (response.statusCode == 200) {
      await _saveAndPlayAudio(response.bodyBytes);
    } else {
      print('Error: ${response.body}');
    }
  }

  Future<void> _saveAndPlayAudio(List<int> audioBytes) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/audio.mp3';
    final file = File(filePath);
    await file.writeAsBytes(audioBytes);

    print("Audio saved at $filePath");

    // **✅ Play the audio after saving**
    final player = AudioPlayer();
    await player.play(DeviceFileSource(filePath));
  }
}
