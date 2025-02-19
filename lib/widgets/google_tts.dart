import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class GoogleTTS {
  final String apiKey = "YOUR_GOOGLE_API_KEY"; // Replace with your API Key

  Future<void> speakHindi(String text) async {
    final url = Uri.parse(
      'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "input": {
          "text": text
        },
        "voice": {
          "languageCode": "hi-IN",
          "name": "hi-IN-Wavenet-B"
        },
        "audioConfig": {
          "audioEncoding": "MP3"
        },
      }),
    );

    if (response.statusCode == 200) {
      final audioContent = jsonDecode(response.body)['audioContent'];
      await _saveAndPlayAudio(audioContent);
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<void> _saveAndPlayAudio(String base64Audio) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/audio.mp3';
    final file = File(filePath);
    await file.writeAsBytes(base64Decode(base64Audio));

    final player = AudioPlayer();
    await player.play(DeviceFileSource(filePath));
  }
}
