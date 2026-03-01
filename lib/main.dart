//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/AppLocalizations.dart';
import 'screens/HomeScreen.dart';
import 'screens/TranslateScreen.dart';

void main() => runApp(const VaniApp());

class VaniApp extends StatefulWidget {
  const VaniApp({super.key});

  @override
  State<VaniApp> createState() => _VaniAppState();
}

class _VaniAppState extends State<VaniApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    const accentIndigo = Color(0xFF6C63FF);
    const deepBg = Color(0xFF06060F);
    const surfaceCard = Color(0xFF0D0D1F);

    return MaterialApp(
      title: 'Vani — Sign Language AI',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // --- LIGHT THEME ---
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: accentIndigo,
        scaffoldBackgroundColor: const Color(0xFFF4F6FD),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: accentIndigo,
          secondary: Color(0xFF4F46E5),
          surface: Colors.white,
          onSurface: Color(0xFF0F0E2A),
        ),
        useMaterial3: true,
      ),

      // --- DARK THEME ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: accentIndigo,
        scaffoldBackgroundColor: deepBg,
        cardColor: surfaceCard,
        canvasColor: deepBg,
        dividerColor: Colors.white.withOpacity(0.04),
        colorScheme: const ColorScheme.dark(
          primary: accentIndigo,
          secondary: Color(0xFF9D8FFF),
          surface: surfaceCard,
          onSurface: Color(0xFFEAE8FF),
        ),
        useMaterial3: true,
      ),

      home: HomeScreen(toggleTheme: toggleTheme, setLocale: setLocale),
    );
  }
}