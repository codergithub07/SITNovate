import 'package:flutter/material.dart';
import 'package:voice_assistant/screens/home_page.dart';
import 'package:voice_assistant/utils/pallete.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<bool> _isDarkThemeNotifier = ValueNotifier(false);

  void toggleTheme(bool isDarkTheme) {
    _themeMode.value = isDarkTheme ? ThemeMode.dark : ThemeMode.light;


    _isDarkThemeNotifier.value = isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData.light(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: Pallete.whiteColor,
            appBarTheme: const AppBarTheme(backgroundColor: Pallete.whiteColor),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: HomePage(
            isDarkThemeNotifier: _isDarkThemeNotifier,
            toggleTheme: toggleTheme,
          ),
        );
      },
    );
  }
}

void temp() {}
