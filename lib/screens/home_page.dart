// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/utils/pallete.dart';
import 'package:voice_assistant/widgets/aws_polly.dart';
import 'package:voice_assistant/widgets/el_labs.dart';
import 'package:voice_assistant/widgets/openai_service.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<bool> isDarkThemeNotifier;
  final Function(bool) toggleTheme;

  const HomePage({super.key, required this.isDarkThemeNotifier, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? generatedContent;
  FlutterTts flutterTts = FlutterTts();
  SpeechToText speechToText = SpeechToText();
  String? generatedImage;
  final OpenaiService openaiService = OpenaiService();
  final ThemeData theme = ThemeData();
  bool isDarkTheme = false;
  // String responseLang = 'en';

  // Debugging
  // void getAvailableLanguages() async {
  //   if (await speechToText.initialize()) {
  //     List<LocaleName> locales = await speechToText.locales();
  //     for (var locale in locales) {
  //       print('${locale.localeId} - ${locale.name}');
  //     }
  //   }
  // }

  // void getTtsLanguages() async {
  //   List<dynamic> languages = await flutterTts.getLanguages;
  //   for (var language in languages) {
  //       print(language);
  //     }
  // }

  String lastWords = '';
  List<String> recentCommands = [];
  List<String> allSuggestions = [
    "Explain Quantum Computing",
    "Tell me a joke",
    "Explain Plagiarism?",
    "Meaning of Exaggeration",
    "Create python code for Linked List",
    "Which is world's spiciest chilli",
    "Tell me a poem"
  ];
  List<String> suggestions = [];

  @override
  void initState() {
    // ElevenLabsTTS().getAudio('hello chacha kaise ho');
    // AmazonPollyService().getPollyAudio('नन्हा बच्चा पार्क में खुश होकर गेंद से खेल रहा था।', tone: 'shy');
    // getAvailableLanguages();
    // getTtsLanguages();
    super.initState();
    initstt();
    generateRandomSuggestions();
    widget.isDarkThemeNotifier.addListener(_updateTheme);
  }

  Future<void> initstt() async {
    // playTTS();

    await speechToText.initialize(onStatus: onSpeechStatus);
    await flutterTts.setLanguage('hi_IN');
    flutterTts.setPitch(0.5);
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> action() async {
    if (lastWords.isNotEmpty) {
      recentCommands.add(lastWords);
      final speech = await openaiService.isArtPromptAPI(lastWords);
      if (speech.contains('https://')) {
        generatedImage = speech;
        generatedContent = null;
      } else {
        generatedContent = speech;
        systemSpeak(speech);
        generatedImage = null;
      }
      setState(() {});
      lastWords = '';
    }
  }

  Future<void> onSpeechStatus(String status) async {
    if (status == "done") {
      action();
    }
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  void generateRandomSuggestions() {
    final random = Random();
    final Set<String> uniqueSuggestions = {};
    while (uniqueSuggestions.length < 3) {
      uniqueSuggestions.add(allSuggestions[random.nextInt(allSuggestions.length)]);
    }

    suggestions = uniqueSuggestions.toList();
  }

  @override
  void dispose() {
    widget.isDarkThemeNotifier.removeListener(_updateTheme);
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  void _updateTheme() {
    setState(() {
      isDarkTheme = widget.isDarkThemeNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        key: ValueKey<bool>(isDarkTheme),
        appBar: AppBar(
          title: const Text('Voice Assistant'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                generatedContent = null;
                generatedImage = null;
                flutterTts.stop();
                recentCommands.clear();
                generateRandomSuggestions();
              });
            },
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.settings),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.isDarkThemeNotifier,
                    builder: (context, isDarkTheme, child) {
                      return SwitchListTile(
                        title: const Text('Dark Theme'),
                        value: isDarkTheme,
                        onChanged: (value) {
                          widget.isDarkThemeNotifier.value = value;
                          widget.toggleTheme(value);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/virtualAssistant.png'),
                        ),
                      ),
                    )
                  ],
                ),
                if (generatedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Image.network(generatedImage!),
                  ),
                Visibility(
                  visible: generatedImage == null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Pallete.borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      generatedContent ?? 'Hello, How can I help you?',
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                        fontFamily: 'NotoSansDevanagari',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Voice Command History
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Commands',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: recentCommands.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(recentCommands[index]),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Suggestions
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: suggestions.map((suggestion) {
                    return Chip(
                      label: Text(suggestion),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                // Status Indicator
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Status: ${speechToText.isListening ? "Listening" : "Idle"}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await speechToText.hasPermission) {
              flutterTts.stop();
              if (speechToText.isListening) {
                stopListening();

                if (lastWords.isNotEmpty) {
                  action();
                }
                return;
              } else {
                startListening();
              }
            } else {
              initstt();
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Icon((speechToText.isListening ? Icons.stop : Icons.mic)),
        ),
      ),
    );
  }
}
