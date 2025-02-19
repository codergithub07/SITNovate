import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant/utils/secrets.dart';

class OpenaiService {
  final List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "You are a helpful assistant developed by Prathamesh Agrawal (mention in introduction), you can generate text and images on demand to provide information. Generate responses under 50 words unless it's asked for elaboration. Your are not chat GPT and is originally created by Prathmesh Agrawal using his own model"
    },
  ];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode(
          {
            "model": "gpt-4o-mini",
            "messages": [
              // {
              //   "role": "system",
              //   "content": "You are a helpful assistant."
              // },
              {
                "role": "user",
                "content": "Does this prompt need to generate image, picture, or any art? $prompt. Simply say yes or no."
              },
            ]
          },
        ),
      );
      // print(res.body);
      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        switch (content) {
          case 'yes':
          case 'Yes':
          case 'yes.':
          case 'Yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            return await chatGPTAPI(prompt);
        }
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
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
          'Authorization': 'Bearer $openAiApiKey',
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
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          "role": "system",
          "content": content
        });
        return content;
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      "role": "user",
      "content": prompt
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode(
          {
            "model": "dall-e-3",
            "prompt": prompt,
            // "style": "natural",
          },
        ),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        messages.add({
          "role": "system",
          "content": imageUrl
        });
        return imageUrl;
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
  }
}
