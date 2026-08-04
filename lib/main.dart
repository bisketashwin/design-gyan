import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/presentation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    // ProviderScope MUST be the root-level widget in runApp
    const ProviderScope(
      child: GameDeckApp(),
    ),
  );
}

class GameDeckApp extends StatelessWidget {
  const GameDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Dev Onboarding Deck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB800),
          secondary: Color(0xFF00F0FF),
          surface: Color(0xFF121620),
        ),
      ),
      home: const PresentationScreen(),
    );
  }
}