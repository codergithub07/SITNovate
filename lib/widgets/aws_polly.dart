import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_common/aws_common.dart';
import 'package:voice_assistant/utils/secrets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AmazonPollyService {
  final String accessKey = Secrets.awsAccessKey;
  final String secretKey = Secrets.awsSecretKey;
  final String region = 'us-east-1';
  final AWSCredentials credentials;

  AmazonPollyService()
      : credentials = AWSCredentials(
          Secrets.awsAccessKey,
          Secrets.awsSecretKey,
        );

  Future<String?> getPollyAudio(String text, {String tone = 'neutral'}) async {
    final endpoint = Uri.https('polly.$region.amazonaws.com', '/v1/speech');
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    // Convert text to SSML based on the selected tone
    String ssmlText = _convertTextToSSML(text, tone);

    // Check if the voice supports Neural TTS
    bool isNeuralSupported = [
      'Joanna',
      'Matthew',
      'Ivy'
    ].contains('Aditi'); // Add supported voices here

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: endpoint,
      headers: {
        'Content-Type': 'application/json',
        'X-Amz-Target': 'com.amazonaws.polly.v1.Polly.SynthesizeSpeech',
      },
      body: utf8.encode(jsonEncode({
        'TextType': 'ssml', // Tell Polly we are sending SSML
        'Text': ssmlText,
        'OutputFormat': 'mp3',
        // 'VoiceId': 'Aditi', // Use supported voice
        'VoiceId': 'Raveena',
        if (isNeuralSupported) 'Engine': 'neural' // Only add Neural if supported
        
        // 'Engine': 'neural',
      })),
    );

    final signedRequest = await signer.sign(
      request,
      credentialScope: AWSCredentialScope(region: region, service: AWSService.polly),
    );

    final response = await http.post(
      signedRequest.uri,
      headers: signedRequest.headers,
      body: await signedRequest.bodyBytes,
    );

    if (response.statusCode == 200) {
      return _saveAndPlayAudio(response.bodyBytes);
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }

  String _convertTextToSSML(String text, String tone) {
    switch (tone.toLowerCase()) {
      case 'rude':
        return '''
      <speak>
        <amazon:emotion name="disappointed" intensity="high">
          $text
        </amazon:emotion>
      </speak>
      ''';
      case 'manly':
        return '''
      <speak>
        <prosody pitch="-10%" rate="90%">
          $text
        </prosody>
      </speak>
      ''';
      case 'soft':
        return '''
      <speak>
        <prosody volume="soft" rate="85%">
          $text
        </prosody>
      </speak>
      ''';
      case 'shy':
        return '''
      <speak>
        <prosody pitch="+10%" volume="x-soft" rate="80%">
          $text
        </prosody>
      </speak>
      ''';
      default: // Neutral tone
        return '''
      <speak>
        $text
      </speak>
      ''';
    }
  }

  // Future<String?> _saveAndPlayAudio(List<int> audioBytes) async {
  //   final player = AudioPlayer();
  //   final String tempPath = '/tmp/audio.mp3'; // Adjust for your platform
  //   final file = File(tempPath);
  //   await file.writeAsBytes(audioBytes);
  //   await player.play(DeviceFileSource(file.path));
  //   return file.path;
  // }
  Future<String?> _saveAndPlayAudio(List<int> audioBytes) async {
    final player = AudioPlayer();

    // Get a valid temp directory
    final directory = await getTemporaryDirectory();
    final String tempPath = path.join(directory.path, 'audio.mp3');

    final file = File(tempPath);
    await file.writeAsBytes(audioBytes);

    await player.play(DeviceFileSource(file.path));
    return file.path;
  }
}
