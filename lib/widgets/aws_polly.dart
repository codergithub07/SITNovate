import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_common/aws_common.dart';
import 'package:voice_assistant/utils/secrets.dart';

class AmazonPollyService {
  final String accessKey = Secrets.awsAccessKey;
  final String secretKey = Secrets.awsSecretKey;
  final String region = 'ap-south-1';
  final AWSCredentials credentials;

  AmazonPollyService()
      : credentials = AWSCredentials(
          Secrets.awsAccessKey,
          Secrets.awsSecretKey,
        );

  Future<String?> getPollyAudio(String text) async {
    final endpoint = Uri.https('polly.$region.amazonaws.com', '/v1/speech');
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: endpoint,
      headers: {
        'Content-Type': 'application/json',
        'X-Amz-Target': 'com.amazonaws.polly.v1.Polly.SynthesizeSpeech',
      },
      body: utf8.encode(jsonEncode({
        'Text': text,
        'OutputFormat': 'mp3',
        'VoiceId': 'Aditi',
        'LanguageCode': 'hi-IN',
      })),
    );

    final signedRequest = await signer.sign(request, credentialScope: AWSCredentialScope(region: region, service: AWSService.polly));

    final response = await http.post(
      signedRequest.uri,
      headers: signedRequest.headers,
      body: signedRequest.body,
    );

    if (response.statusCode == 200) {
      return _saveAndPlayAudio(response.bodyBytes);
    } else {
      print('Error: ${response.body}');
      return null;
    }
  }

  Future<String?> _saveAndPlayAudio(List<int> audioBytes) async {
    final player = AudioPlayer();
    final String tempPath = '/tmp/audio.mp3'; // Adjust for your platform
    final file = File(tempPath);
    await file.writeAsBytes(audioBytes);
    await player.play(DeviceFileSource(file.path));
    return file.path;
  }
}
