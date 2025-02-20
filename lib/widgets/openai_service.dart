import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/utils/secret.dart';

class OpenaiService {
  String correctText = '';
  final String apiKey = Secrets.openAiApiKey;
  String targetLang = '';
  String inputText = '';

  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "act like you are a character. Generate responses under 50 words unless it's asked for elaboration."
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
    print(inputText);
  }

  Future<String> isHindi(String text) async {
    tempList.add(
      {
        "role": "user",
        "content": "$text. what language is this? return only hindi if hindi (even if only one word is of hindi), marathi if marathi (even if only one word is of marathi), else english",
      },
    );
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(
          {
            "model": "gpt-4o-mini",
            "messages": tempList,
            // "max_completion_tokens": 100,
          },
        ),
      );
      if (res.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
        // print(decodedResponse['choices'][0]['message']['content']);
        return decodedResponse['choices'][0]['message']['content'];
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages[0]["content"] = "act like you are $inputText. Generate responses only according to your given character only, under 50 words unless it's asked for elaboration. Avoid using special characters unless it's necessary.";
    final isHindiResult = await isHindi(prompt);
    final targetLang = isHindiResult.trim();
    messages.add({
      "role": "user",
      "content": "$prompt. Respond in $targetLang language and use font according to the language.",
    });
    print(targetLang);
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(
          {
            "model": "gpt-4o-mini",
            "messages": messages,
            // "max_completion_tokens": 100,
          },
        ),
      );
      // print(res.body);
      if (res.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
        String content = decodedResponse['choices'][0]['message']['content'];
        // String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          "role": "system",
          "content": content
        });
        print(content);
        print(messages[0]["content"]);
        return content;
      }
      print(res.body);
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }
}
