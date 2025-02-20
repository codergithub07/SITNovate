import 'package:flutter/material.dart';
import 'package:voice_assistant/screens/main_page.dart';
import 'package:voice_assistant/widgets/openai_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String inputText = '';
  final openaiService = OpenaiService();
  bool _isImageLoaded = false;

  late AnimationController _controller;
  late Animation<Color?> _bgColorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bgColorAnimation = ColorTween(
      begin: Colors.deepPurple.shade800,
      end: Colors.indigo.shade900,
    ).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/background.jpg'), context).then((_) {
      if (mounted) {
        setState(() {
          _isImageLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgColorAnimation,
      builder: (context, child) {
        return _isImageLoaded
            ? Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text('Voice Assistant', style: TextStyle(color: Colors.amber, fontSize: 28),),
                  centerTitle: true,
                ),
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(seconds: 2),
                      child: AnimatedScale(
                        scale: 1.1,
                        duration: const Duration(seconds: 5),
                        curve: Curves.easeInOut,
                        child: Image.asset(
                          'assets/images/background.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'E.g. Rude Banker, Helper Bot',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.5),
                              ),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  inputText = value;
                                });
                              },
                            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.3, end: 0.0, curve: Curves.easeOut),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  openaiService.setInputText(inputText);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  shadowColor: Colors.pinkAccent,
                                  elevation: 10,
                                ),
                                child: const Text(
                                  'Go to Next Screen',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ).animate().scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0), curve: Curves.easeInOut).fadeIn(duration: 700.ms),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))
            : Container();
      },
    );
  }
}
