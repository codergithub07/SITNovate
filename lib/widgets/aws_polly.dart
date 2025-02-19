// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:aws_signature_v4/aws_signature_v4.dart';

// class AmazonPollyTTS {
//   final String accessKey = "YOUR_AWS_ACCESS_KEY"; // Replace with actual AWS Access Key
//   final String secretKey = "YOUR_AWS_SECRET_KEY"; // Replace with actual AWS Secret Key
//   final String region = "us-east-1"; // Change to your AWS region

//   Future<void> speakText(String text, String voice, String emotion) async {
//     final String endpoint = "https://polly.$region.amazonaws.com/v1/speech";
//     final Uri uri = Uri.parse(endpoint);

//     // SSML format for expressive speech
//     String ssmlText = '''
//       <speak>
//         <amazon:emotion name="$emotion" intensity="medium">$text</amazon:emotion>
//       </speak>
//     ''';

//     final Map<String, String> headers = {
//       "Content-Type": "application/json",
//       "Host": uri.host,
//       "X-Amz-Target": "com.amazonaws.polly.v1.SynthesizeSpeech",
//     };

//     final Map<String, dynamic> body = {
//       "Text": ssmlText,
//       "OutputFormat": "mp3",
//       "VoiceId": voice,
//       "TextType": "ssml",
//     };

//     final signer = AWSSigV4Signer(
//       credentialsProvider: AWSCredentialsProvider.static(
//         accessKey: accessKey,
//         secretKey: secretKey,
//       ),
//       serviceConfiguration: AWSCredentialScope(
//         service: "polly",
//         region: region,
//       ),
//     );

//     final signedRequest = signer.sign(
//       AWSHttpRequest(
//         method: "POST",
//         uri: uri,
//         headers: headers,
//         body: jsonEncode(body),
//         service: "polly",
//         region: region,
//       ),
//     );

//     final response = await http.post(
//       uri,
//       headers: signedRequest.headers,
//       body: signedRequest.body,
//     );

//     if (response.statusCode == 200) {
//       print("✅ Polly audio generated successfully!");
//       final Uint8List audioBytes = Uint8List.fromList(response.bodyBytes);
//       _playAudio(audioBytes);
//     } else {
//       print("❌ Error: ${response.body}");
//     }
//   }

//   void _playAudio(Uint8List audioBytes) async {
//     final player = AudioPlayer();
//     await player.play(BytesSource(audioBytes));
//   }
// }
