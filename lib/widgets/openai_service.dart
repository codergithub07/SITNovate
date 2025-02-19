import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/utils/secret.dart';

class OpenaiService {
  String correctText = '';
  final String apiKey = Secrets.openAiApiKey;
  String targetLang = 'en';

  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "You are a helpful assistant developed by AI_Visionaries (mention in introduction), you can generate text in same language as user spoke (unless asked for different language) to provide information. Generate responses under 50 words unless it's asked for elaboration."
    },
  ];

  Future<String> isHindi(String text) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(
        {
          "model": "gpt-4o-mini",
          "messages": "$messages. Is this language Hindi/Marathi? Only return hindi for hindi language or marathi for marathi language, return english for other languages.",
          // "max_completion_tokens": 100,
        },
      ),
    );
    if (res.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
      print(decodedResponse['choices'][0]['message']['content']);
      return decodedResponse['choices'][0]['message']['content'];
    }
    return 'An internal error occured';
  }

  Future<String> chatGPTAPI(String prompt) async {
    final isHindiResult = await isHindi(prompt);
    final targetLang = isHindiResult.trim();
    messages.add({
      "role": "user",
      "content": "$prompt. Respond in $targetLang language and use font according to the language",
    });
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
        return content;
      }
      print(res.body);
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }
}
