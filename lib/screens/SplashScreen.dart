// lib/screens/SplashScreen.dart
// ─────────────────────────────────────────────────────────────
//  VANI  —  Minimal Production Splash Screen  (light)
//
//  PHILOSOPHY
//  White canvas. Three precise beats. No particles.
//  Logo → name → tagline → fade out.
//  Every transition is crisp, purposeful, silent.
//
//  TIMELINE  (total ≈ 2600 ms)
//  180 ms   Beat 1 — Logo circle scales in (spring), arc draws.
//                     Hand fades inside ring.
//  780 ms   Beat 2 — "VANI" slides up + fades in.
//  1050 ms  Beat 3 — Tagline fades in.
//  2100 ms  Beat 4 — Whole screen fades to white.
//  2580 ms  Navigate to HomeScreen (zero transition).
// ─────────────────────────────────────────────────────────────
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'HomeScreen.dart';
import '../components/SOSFloatingButton.dart';
import '../services/EmergencyService.dart';

// ─────────────────────────────────────────────
//  PALETTE  — light only
// ─────────────────────────────────────────────
const _kBg          = Color(0xFFFFFFFF);
const _kViolet      = Color(0xFF7C3AED);
const _kVioletLight = Color(0xFFA78BFA);
const _kVioletDeep  = Color(0xFF5B21B6);
const _kTextSub     = Color(0xFFAAAAAA);

// ═════════════════════════════════════════════
//  SPLASH SCREEN
// ═════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  final VoidCallback     toggleTheme;
  final Function(Locale) setLocale;

  const SplashScreen({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Controllers
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _exitCtrl;

  // Logo
  late final Animation<double> _ringScale;
  late final Animation<double> _ringFade;
  late final Animation<double> _arcProgress;
  late final Animation<double> _handFade;
  late final Animation<double> _handScale;

  // Text
  late final Animation<double> _nameFade;
  late final Animation<Offset>  _nameSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset>  _taglineSlide;

  // Exit
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 820));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 920));
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));

    // Logo ring
    _ringScale = Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.68, curve: Curves.easeOutBack)));

    _ringFade = CurvedAnimation(parent: _logoCtrl,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOut));

    _arcProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.08, 0.88, curve: Curves.easeOutCubic)));

    // Hand
    _handFade = CurvedAnimation(parent: _logoCtrl,
        curve: const Interval(0.32, 0.82, curve: Curves.easeOut));
    _handScale = Tween<double>(begin: 0.40, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.32, 0.88, curve: Curves.easeOutBack)));

    // Wordmark
    _nameFade = CurvedAnimation(parent: _textCtrl,
        curve: const Interval(0.0, 0.52, curve: Curves.easeOut));
    _nameSlide = Tween<Offset>(
        begin: const Offset(0, 0.28), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl,
            curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic)));

    // Tagline
    _taglineFade = CurvedAnimation(parent: _textCtrl,
        curve: const Interval(0.42, 0.88, curve: Curves.easeOut));
    _taglineSlide = Tween<Offset>(
        begin: const Offset(0, 0.22), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl,
            curve: const Interval(0.42, 0.88, curve: Curves.easeOutCubic)));

    // Exit
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut));

    _schedule();
  }

  void _schedule() {
    // Beat 1 — logo
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _logoCtrl.forward();
      HapticFeedback.lightImpact();
    });

    // Beat 2 — text
    Future.delayed(const Duration(milliseconds: 780), () {
      if (!mounted) return;
      _textCtrl.forward();
    });

    // Beat 3 — exit fade
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      _exitCtrl.forward().then((_) {
        if (mounted) _navigate();
      });
    });
  }

  void _navigate() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => _AppShell(
        toggleTheme: widget.toggleTheme,
        setLocale:   widget.setLocale,
      ),
    ));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:     Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoCtrl, _textCtrl, _exitCtrl]),
        builder: (_, __) => FadeTransition(
          opacity: _exitOpacity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ─── Logo ────────────────────────────
                ScaleTransition(
                  scale: _ringScale,
                  child: FadeTransition(
                    opacity: _ringFade,
                    child: SizedBox(
                      width: 96, height: 96,
                      child: CustomPaint(
                        painter: _LogoPainter(
                          arcProgress: _arcProgress.value,
                          handOpacity: _handFade.value,
                          handScale:   _handScale.value,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ─── Wordmark ─────────────────────────
                SlideTransition(
                  position: _nameSlide,
                  child: FadeTransition(
                    opacity: _nameFade,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) => const LinearGradient(
                        colors: [_kVioletDeep, _kViolet, _kVioletLight],
                        stops:  [0.0, 0.5, 1.0],
                      ).createShader(b),
                      child: const Text(
                        'VANI',
                        style: TextStyle(
                          fontSize:      48,
                          fontWeight:    FontWeight.w900,
                          letterSpacing: 11,
                          color:         Colors.white, // masked
                          height:        1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ─── Tagline ──────────────────────────
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: const Text(
                      'Indian Sign Language · AI',
                      style: TextStyle(
                        color:         _kTextSub,
                        fontSize:      12.5,
                        fontWeight:    FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
//  LOGO PAINTER
//  96×96 white circle · violet arc · hand inside
// ═════════════════════════════════════════════
class _LogoPainter extends CustomPainter {
  final double arcProgress;
  final double handOpacity;
  final double handScale;

  const _LogoPainter({
    required this.arcProgress,
    required this.handOpacity,
    required this.handScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2 - 1;

    // ── Soft drop shadow ────────────────────
    canvas.drawCircle(
      Offset(cx, cy + 2),
      r - 1,
      Paint()
        ..color = _kViolet.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // ── Circle fill — very light violet tint ─
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFFF4F0FF),
    );

    // ── Hairline border ───────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = _kViolet.withOpacity(0.10)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // ── Arc ring ──────────────────────────────
    if (arcProgress > 0) {
      final arcR   = r - 6;
      final sweep  = 2 * math.pi * arcProgress;

      // Glow behind arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = _kViolet.withOpacity(0.16)
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Gradient arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: -math.pi / 2,
            endAngle:   -math.pi / 2 + sweep,
            colors:     [_kVioletDeep, _kViolet, _kVioletLight],
            stops: const [0.0, 0.50, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: arcR))
          ..strokeWidth = 2.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Bright leading dot
      if (arcProgress > 0.03) {
        final tipA = -math.pi / 2 + sweep;
        final tx   = cx + arcR * math.cos(tipA);
        final ty   = cy + arcR * math.sin(tipA);

        canvas.drawCircle(Offset(tx, ty), 3.5,
            Paint()
              ..color = _kVioletLight
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        canvas.drawCircle(Offset(tx, ty), 2.0,
            Paint()..color = _kViolet);
      }
    }

    // ── Hand silhouette ──────────────────────
    if (handOpacity > 0) {
      canvas.save();

      // Scale around centre
      canvas.translate(cx, cy);
      canvas.scale(handScale * 0.55);
      canvas.translate(-cx, -cy);

      // Palm
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy + 6), width: 26, height: 16),
            const Radius.circular(5)),
        Paint()
          ..color = _kViolet.withOpacity(handOpacity * 0.92)
          ..style = PaintingStyle.fill,
      );

      // Fingers — staggered by opacity threshold
      final fingers = [
        (-10.5, 21.0, 0.0),
        ( -3.5, 24.5, 0.18),
        (  3.5, 24.5, 0.34),
        ( 10.5, 19.0, 0.50),
      ];
      for (final f in fingers) {
        final fp = ((handOpacity - f.$3) / 0.36).clamp(0.0, 1.0);
        if (fp <= 0) continue;
        final fH = f.$2 * fp;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx + f.$1 - 3.2, cy - fH - 1, 6.4, fH + 1),
              const Radius.circular(3)),
          Paint()
            ..color = _kViolet.withOpacity(handOpacity * fp * 0.92)
            ..style = PaintingStyle.fill,
        );
      }

      // Thumb
      final tp = ((handOpacity - 0.58) / 0.42).clamp(0.0, 1.0);
      if (tp > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - 18, cy - 1, 7, 13 * tp),
              const Radius.circular(3.5)),
          Paint()
            ..color = _kViolet.withOpacity(handOpacity * 0.92)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.arcProgress != arcProgress ||
          old.handOpacity != handOpacity  ||
          old.handScale   != handScale;
}

// ═════════════════════════════════════════════
//  APP SHELL  (post-splash)
// ═════════════════════════════════════════════
class _AppShell extends StatefulWidget {
  final VoidCallback     toggleTheme;
  final Function(Locale) setLocale;
  const _AppShell({required this.toggleTheme, required this.setLocale});
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EmergencyService.instance.init(context);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: HomeScreen(
        toggleTheme: widget.toggleTheme,
        setLocale:   widget.setLocale),
    floatingActionButton: SOSFloatingButton(
        toggleTheme: widget.toggleTheme,
        setLocale:   widget.setLocale),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}