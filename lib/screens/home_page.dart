import 'package:flutter/material.dart';
import 'package:voice_assistant/screens/main_page.dart';
import 'package:voice_assistant/widgets/openai_service.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<bool> isDarkThemeNotifier;
  final Function(bool) toggleTheme;

  const HomePage({
    super.key,
    required this.isDarkThemeNotifier,
    required this.toggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String inputText = '';
  bool isDarkTheme = false;
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<bool> _isDarkThemeNotifier = ValueNotifier(false);
  final OpenaiService openaiService = OpenaiService();

  @override
  void initState() {
    super.initState();
    widget.isDarkThemeNotifier.addListener(_updateTheme);
  }

  @override
  void dispose() {
    widget.isDarkThemeNotifier.removeListener(_updateTheme);
    super.dispose();
  }

  void toggleTheme(bool isDarkTheme) {
    _themeMode.value = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    _isDarkThemeNotifier.value = isDarkTheme;
    widget.toggleTheme(isDarkTheme);
  }

  void _updateTheme() {
    setState(() {
      isDarkTheme = widget.isDarkThemeNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey<bool>(isDarkTheme),
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        centerTitle: true,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter your character type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    inputText = value; // Update inputText on text change
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Set the desired width
                height: 50, // Set the desired height
                child: ElevatedButton(
                  onPressed: () async {
                    openaiService.setInputText(inputText); // Pass inputText to OpenaiService
                    // Navigate to the next screen and pass the inputText
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          isDarkThemeNotifier: _isDarkThemeNotifier,
                          toggleTheme: toggleTheme,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        inputText = result; // Update inputText with the returned value
                      });
                    }
                  },
                  child: const Text('Go to Next Screen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
