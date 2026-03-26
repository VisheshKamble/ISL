// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'l10n/AppLocalizations.dart';
import 'models/EmergencyContact.dart';
import 'services/EmergencyService.dart';
import 'screens/HomeScreen.dart';
import 'screens/SplashScreen.dart';
import 'components/SOSFloatingButton.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    statusBarBrightness:       Brightness.dark,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(EmergencyContactAdapter());
  await Hive.openBox<EmergencyContact>('emergency_contacts');

  runApp(const VaniApp());
}

class VaniApp extends StatefulWidget {
  const VaniApp({super.key});
  @override
  State<VaniApp> createState() => _VaniAppState();
}

class _VaniAppState extends State<VaniApp> {
  ThemeMode _themeMode = ThemeMode.light;   // ← app starts in light mode
  Locale _locale = const Locale('en');

  void toggleTheme() => setState(() =>
  _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  void setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    const violet      = Color(0xFF7C3AED);
    const violetLight = Color(0xFFA78BFA);
    const dBg         = Color(0xFF040408);
    const dSurface    = Color(0xFF0C0C16);
    const lBg         = Color(0xFFF5F6FE);
    const lSurface    = Color(0xFFFFFFFF);

    // Bundled Google Sans font family from assets/fonts for exact cross-platform rendering.
    const appFontFamily = 'Google Sans';

    return MaterialApp(
      onGenerateTitle:            (context) => AppLocalizations.of(context).t('app_title'),
      debugShowCheckedModeBanner: false,
      themeMode:                  _themeMode,
      locale:                     _locale,
      supportedLocales:           AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Dark theme ──────────────────────────
      darkTheme: ThemeData(
        brightness:              Brightness.dark,
        useMaterial3:            true,
        fontFamily:              appFontFamily,
        primaryColor:            violet,
        scaffoldBackgroundColor: dBg,
        cardColor:               dSurface,
        canvasColor:             dBg,
        dividerColor:            Colors.white.withOpacity(0.05),
        textTheme:               ThemeData.dark().textTheme,
        colorScheme: ColorScheme.dark(
          primary:   violet,
          secondary: violetLight,
          surface:   dSurface,
          onSurface: const Color(0xFFF0EEFF),
          outline:   Colors.white.withOpacity(0.08),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux:   FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
        }),
      ),

      // ── Light theme ─────────────────────────
      theme: ThemeData(
        brightness:              Brightness.light,
        useMaterial3:            true,
        fontFamily:              appFontFamily,
        primaryColor:            violet,
        scaffoldBackgroundColor: lBg,
        cardColor:               lSurface,
        textTheme:               ThemeData.light().textTheme,
        colorScheme: const ColorScheme.light(
          primary:   violet,
          secondary: violetLight,
          surface:   lSurface,
          onSurface: Color(0xFF0A0A20),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux:   FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
        }),
      ),

      home: SplashScreen(toggleTheme: toggleTheme, setLocale: setLocale),
    );
  }
}

// ─────────────────────────────────────────────
//  ROOT SHELL
// ─────────────────────────────────────────────
class _RootShell extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const _RootShell({required this.toggleTheme, required this.setLocale});
  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EmergencyService.instance.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomeScreen(
        toggleTheme: widget.toggleTheme,
        setLocale:   widget.setLocale,
      ),
      floatingActionButton: SOSFloatingButton(
        toggleTheme: widget.toggleTheme,
        setLocale:   widget.setLocale,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}