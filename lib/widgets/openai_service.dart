import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_assistant/utils/secrets.dart';

class OpenaiService {
  String correctText = '';

  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "You are a helpful assistant developed by AI_Visionaries (mention in introduction), you can generate text in same language as user spoke (unless asked for different language) and return the font according to the language to provide information. Generate responses under 50 words unless it's asked for elaboration. Your are not chat GPT and is originally created by AI_Visionaries using his own model"
    },
  ];

  Future<String> isHindi(String text) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Secrets.openAiApiKey}',
      },
      body: jsonEncode(
        {
          "model": "gpt-4o-mini",
          "messages": "$messages. Is this language Hindi/Marathi? Only return yes or no.",
          // "max_completion_tokens": 100,
        },
      ),
    );
    if (res.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(res.bodyBytes));
      return decodedResponse['choices'][0]['message']['content'];
    }
    print(res);
    return 'An internal error occured';
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      "role": "user",
      "content": prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Secrets.openAiApiKey}',
        },
        body: jsonEncode(
          {
            "model": "gpt-4o-mini",
            "target-language": isHindi(prompt) == 'yes' ? "hi" : "en",
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
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }
}
