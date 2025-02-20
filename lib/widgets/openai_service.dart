import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/utils/secret.dart';

class OpenaiService {
  static final OpenaiService _instance = OpenaiService._internal();

  factory OpenaiService() {
    return _instance;
  }

  OpenaiService._internal(); // Private constructor

  final String apiKey = Secrets.openAiApiKey;
  String targetLang = '';
  String inputText = '';
  String voice = 'default'; // Default voice

  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "act like you are a character. Generate responses under 50 words unless asked for elaboration."
    },
  ];

  void setInputText(String text) async {
    inputText = text;
    messages[0]["content"] = "act like you are $inputText. Generate responses only according to your given character, under 50 words unless it's asked for elaboration. Avoid using special characters unless necessary.";
    print("Character set to: $inputText");

    voice = await getCharacterVoice(inputText);
    print("Voice set to: $voice");
  }

  Future<String> getCharacterVoice(String character) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content": "Describe the voice characteristics of $character in 3 words."
            }
          ],
        }),
      );

      if (res.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
        return decodedResponse['choices'][0]['message']['content'].trim();
      }
      return 'default';
    } catch (e) {
      return 'default';
    }
  }

  Future<String> isHindi(String text) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": "$text. What language is this? Return only 'hindi' if it's Hindi, 'marathi' if Marathi, else 'english'."
            }
          ],
        }),
      );

      if (res.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
        return decodedResponse['choices'][0]['message']['content'].trim();
      }
      return 'english';
    } catch (e) {
      return 'english';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    final isHindiResult = await isHindi(prompt);
    final targetLang = isHindiResult.trim();

    messages.add({
      "role": "user",
      "content": "$prompt. Respond in $targetLang language and use the correct font for the language.",
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
        String content = decodedResponse['choices'][0]['message']['content'].trim();

        messages.add({
          "role": "system",
          "content": content,
        });

        print(content);
        return content;
      }

      print(res.body);
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
