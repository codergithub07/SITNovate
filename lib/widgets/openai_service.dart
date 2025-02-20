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

  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "act like you are a character. Generate responses under 50 words unless asked for elaboration."
    },
  ];

  final List<Map<String, String>> tempList = [
    {
      "role": "user",
      "content": "",
    },
  ];

  void setInputText(String text) {
    inputText = text;
    messages[0]["content"] = "act like you are $inputText. Generate responses only according to your given character, under 50 words unless it's asked for elaboration. Avoid using special characters unless necessary. Use proper punctuation to emphasize your character. ";
    print("Character set to: $inputText");
  }

  Future<String> isHindi(String text) async {
    tempList.add({
      "role": "user",
      "content": "$text. What language is this? Return only 'hindi' if it's Hindi, 'marathi' if Marathi, else 'english'.",
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
          "messages": tempList,
        }),
      );

      if (res.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
        return decodedResponse['choices'][0]['message']['content'].trim();
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    final isHindiResult = await isHindi(prompt);
    final targetLang = isHindiResult.trim();
    print("Language detected: $targetLang");

    messages.add({
      "role": "user",
      "content": "$prompt. Respond strictly in $targetLang. strictly use Devanagari for Hindi/Marathi and reply in english for English user input",

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
        print(content);

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
