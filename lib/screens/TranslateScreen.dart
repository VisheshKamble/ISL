import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../components/GlobalNavbar.dart';
import '../l10n/AppLocalizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

// ─────────────────────────────────────────────
//  WEBSOCKET CONFIG
// ─────────────────────────────────────────────
const _kDefaultWsPort = 8000;
const _kWsPath = '/ws';
const _kFrameIntervalMs = 100;

String _getWebSocketUrl() {
  if (kIsWeb) {
    final scheme = Uri.base.scheme == 'https' ? 'wss' : 'ws';
    final host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
    return '$scheme://$host:$_kDefaultWsPort$_kWsPath';
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'ws://10.0.2.2:$_kDefaultWsPort$_kWsPath';
  }
  return 'ws://127.0.0.1:$_kDefaultWsPort$_kWsPath';
}

// ─────────────────────────────────────────────
//  DESIGN SYSTEM
// ─────────────────────────────────────────────
class _C {
  static const lBg      = Color(0xFFF6F8FF);
  static const lSurface = Color(0xFFFFFFFF);
  static const lSurface2= Color(0xFFF0F3FB);
  static const lBorder  = Color(0xFFE2E7F4);
  static const lBorder2 = Color(0xFFCDD4EC);
  static const lText    = Color(0xFF0C1230);
  static const lTextSub = Color(0xFF4D5A7C);
  static const lTextMuted = Color(0xFF9AA5C2);

  static const dBg      = Color(0xFF070B17);
  static const dSurface = Color(0xFF0C1020);
  static const dSurface2= Color(0xFF121828);
  static const dBorder  = Color(0xFF1A2236);
  static const dBorder2 = Color(0xFF222E46);
  static const dText    = Color(0xFFECF0FF);
  static const dTextSub = Color(0xFF8494B8);
  static const dTextMuted = Color(0xFF48556E);

  static const accent    = Color(0xFF4F6EF7);
  static const accentDeep= Color(0xFF3451D1);
  static const green     = Color(0xFF22C55E);
  static const amber     = Color(0xFFF59E0B);
  static const red       = Color(0xFFEF4444);
  static const purple    = Color(0xFFA78BFA);

  static Color bg(bool d)       => d ? dBg : lBg;
  static Color surface(bool d)  => d ? dSurface : lSurface;
  static Color surface2(bool d) => d ? dSurface2 : lSurface2;
  static Color border(bool d)   => d ? dBorder : lBorder;
  static Color border2(bool d)  => d ? dBorder2 : lBorder2;
  static Color text(bool d)     => d ? dText : lText;
  static Color textSub(bool d)  => d ? dTextSub : lTextSub;
  static Color textMuted(bool d)=> d ? dTextMuted : lTextMuted;
}

// ─────────────────────────────────────────────
//  YOUR 25 MODEL WORDS — exact labels your model outputs
// ─────────────────────────────────────────────
// These are the ONLY words the model can detect. Every piece
// of sentence logic is built exclusively around these.
const Set<String> _kModelWords = {
  'hello', 'how are you', 'i', 'please', 'today', 'time',
  'what', 'name', 'quiet', 'yes', 'thankyou', 'namaste',
  'bandaid', 'help', 'strong', 'mother', 'food', 'father',
  'brother', 'love', 'good', 'bad', 'sorry', 'sleeping', 'water',
};

// ─────────────────────────────────────────────
//  SENTENCE BUILDER
//  Produces natural English sentences from sequences
//  of your 25 model words. Covers all real combinations
//  a deaf/mute person would actually sign in a conversation.
// ─────────────────────────────────────────────
class SentenceBuilder {

  // ── Standalone sentence for every single word ───────────
  // Called when the user adds only ONE sign. These are
  // tuned to the most natural thing that sign communicates.
  static const Map<String, String> _solo = {
    'hello':       'Hello!',
    'how are you': 'How are you?',
    'i':           'I...',                  // user probably wants to say more
    'please':      'Please.',
    'today':       'Today.',
    'time':        'What is the time?',
    'what':        'What?',
    'name':        'What is your name?',
    'quiet':       'Please be quiet.',
    'yes':         'Yes.',
    'thankyou':    'Thank you.',
    'namaste':     'Namaste.',
    'bandaid':     'I need medical help.',
    'help':        'I need help!',
    'strong':      'I am strong.',
    'mother':      'My mother.',
    'food':        'I need food.',
    'father':      'My father.',
    'brother':     'My brother.',
    'love':        'I love you.',
    'good':        'That is good.',
    'bad':         'That is bad.',
    'sorry':       'I am sorry.',
    'sleeping':    'I am sleeping.',
    'water':       'I need water.',
  };

  // ── Two-word patterns ─────────────────────────────────
  // Map of [word1, word2] → natural sentence.
  static const Map<String, String> _pairs = {
    // Greetings & social
    'hello|how are you':  'Hello! How are you?',
    'how are you|good':   'How are you? I am good.',
    'how are you|bad':    'How are you? I am not good.',
    'namaste|hello':      'Namaste! Hello!',
    'hello|namaste':      'Hello! Namaste!',

    // Identity
    'i|name':             'My name is...',
    'what|name':          'What is your name?',
    'i|good':             'I am doing well.',
    'i|bad':              'I am not feeling well.',
    'i|sorry':            'I am sorry.',
    'i|strong':           'I am strong.',
    'i|sleeping':         'I am sleeping.',
    'i|love':             'I love you.',
    'i|help':             'I need help!',
    'i|food':             'I need food.',
    'i|water':            'I need water.',
    'i|bandaid':          'I need medical help.',
    'i|mother':           'I want my mother.',
    'i|father':           'I want my father.',
    'i|brother':          'I want my brother.',

    // Please + request
    'please|help':        'Please help me!',
    'please|food':        'Please give me food.',
    'please|water':       'Please give me water.',
    'please|quiet':       'Please be quiet.',
    'please|bandaid':     'Please get me medical help.',
    'please|time':        'Please tell me the time.',
    'please|good':        'Please be good.',
    'please|yes':         'Please say yes.',
    'please|sorry':       'Please forgive me.',

    // Time expressions
    'today|good':         'Today is a good day.',
    'today|bad':          'Today is a bad day.',
    'today|what':         'What is happening today?',
    'time|what':          'What is the time?',
    'time|today':         'What time is it today?',
    'what|time':          'What is the time?',
    'what|today':         'What is happening today?',

    // Feelings and states
    'good|today':         'I am having a good day today.',
    'bad|today':          'I am having a bad day today.',
    'sorry|help':         'I am sorry, I need help.',
    'quiet|please':       'Quiet, please.',

    // Family
    'mother|help':        'My mother needs help.',
    'father|help':        'My father needs help.',
    'brother|help':       'My brother needs help.',
    'mother|food':        'My mother needs food.',
    'father|food':        'My father needs food.',
    'brother|food':       'My brother needs food.',
    'mother|water':       'My mother needs water.',
    'father|water':       'My father needs water.',
    'brother|water':      'My brother needs water.',
    'mother|bandaid':     'My mother needs medical help.',
    'father|bandaid':     'My father needs medical help.',
    'brother|bandaid':    'My brother needs medical help.',
    'mother|sleeping':    'My mother is sleeping.',
    'father|sleeping':    'My father is sleeping.',
    'brother|sleeping':   'My brother is sleeping.',
    'mother|good':        'My mother is good.',
    'father|good':        'My father is good.',
    'brother|good':       'My brother is good.',
    'love|mother':        'I love my mother.',
    'love|father':        'I love my father.',
    'love|brother':       'I love my brother.',

    // Gratitude & social
    'thankyou|help':      'Thank you for your help.',
    'thankyou|good':      'Thank you, that is good.',
    'yes|good':           'Yes, that is good.',
    'yes|thankyou':       'Yes, thank you.',
    'yes|please':         'Yes please.',
    'yes|sorry':          'Yes, I am sorry.',
    'no|sorry':           'No, I am sorry.',     // "no" inferred from bad context
    'bad|sorry':          'I feel bad. I am sorry.',

    // Help & emergency
    'help|bandaid':       'Help! I need medical help!',
    'bandaid|help':       'Medical emergency! Please help!',
    'help|water':         'I need water urgently.',
    'help|food':          'I need food urgently.',
    'help|mother':        'Help! I need my mother.',
    'help|father':        'Help! I need my father.',
  };

  // ── Three-word patterns ───────────────────────────────
  static const Map<String, String> _triples = {
    'i|love|mother':          'I love my mother.',
    'i|love|father':          'I love my father.',
    'i|love|brother':         'I love my brother.',
    'please|help|i':          'Please help me!',
    'i|need|help':            'I need help.',      // "need" won't occur but safe
    'hello|how are you|good': 'Hello! How are you? I am good.',
    'hello|how are you|bad':  'Hello! How are you? I am not feeling well.',
    'i|good|today':           'I am doing well today.',
    'i|bad|today':            'I am not feeling well today.',
    'today|good|yes':         'Yes, today is a good day.',
    'today|bad|sorry':        'Today is bad. I am sorry.',
    'please|help|bandaid':    'Please help! I need medical attention.',
    'bandaid|help|please':    'Medical emergency! Please help me!',
    'i|sorry|bad':            'I am sorry, I feel bad.',
    'sorry|bad|today':        'I am sorry. It has been a bad day.',
    'i|sleeping|quiet':       'I am sleeping. Please be quiet.',
    'quiet|i|sleeping':       'Please be quiet. I am sleeping.',
    'what|time|today':        'What time is it today?',
    'i|food|water':           'I need food and water.',
    'food|water|please':      'Please give me food and water.',
    'help|food|please':       'Please help me. I need food.',
    'help|water|please':      'Please help me. I need water.',
    'mother|help|please':     'Please help my mother.',
    'father|help|please':     'Please help my father.',
    'brother|help|please':    'Please help my brother.',
    'i|thankyou|good':        'I am thankful. Everything is good.',
    'namaste|how are you|good': 'Namaste! How are you? Good.',
  };

  /// Main entry point. Accepts a list of normalized (lowercase) labels.
  static String build(List<String> words) {
    if (words.isEmpty) return '';

    // 1. Try exact triple match
    if (words.length >= 3) {
      final key = words.sublist(0, 3).join('|');
      if (_triples.containsKey(key)) return _triples[key]!;
    }

    // 2. Try exact pair match
    if (words.length >= 2) {
      final key = '${words[0]}|${words[1]}';
      if (_pairs.containsKey(key)) return _pairs[key]!;
    }

    // 3. Solo
    if (words.length == 1) {
      return _solo[words[0]] ?? _capitalise('${words[0]}.');
    }

    // 4. Longer sequences — build intelligently from pairs
    // Walk through the sequence and stitch natural sub-sentences
    return _buildLong(words);
  }

  /// For 4+ word sequences not in the table: try to stitch
  /// from pairs/solo and produce coherent output.
  static String _buildLong(List<String> words) {
    final parts = <String>[];
    int i = 0;
    while (i < words.length) {
      // Try triple first
      if (i + 2 < words.length) {
        final tk = '${words[i]}|${words[i+1]}|${words[i+2]}';
        if (_triples.containsKey(tk)) {
          parts.add(_triples[tk]!);
          i += 3;
          continue;
        }
      }
      // Try pair
      if (i + 1 < words.length) {
        final pk = '${words[i]}|${words[i+1]}';
        if (_pairs.containsKey(pk)) {
          parts.add(_pairs[pk]!);
          i += 2;
          continue;
        }
      }
      // Fall back to solo
      parts.add(_solo[words[i]] ?? _capitalise('${words[i]}.'));
      i++;
    }

    // Merge: remove duplicate terminal punctuation and join
    final merged = parts.map((p) => p.trimRight()).join(' ');
    return merged;
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────
//  AUTO-ADD ENGINE
//  Real-world approach:
//  - No hard confidence threshold for visibility
//  - A sign is "locked" when the model outputs the
//    SAME label for a sustained minimum duration
//    (stability window), regardless of exact % score
//  - After locking, a cooldown prevents re-locking
//    the same word immediately
//  - Confidence bar shows quality, but does NOT block
// ─────────────────────────────────────────────
class _AutoAddEngine {
  /// How long the same label must be stable before it locks in (ms)
  static const int _stabilityMs = 800;

  /// After adding a word, ignore the same word for this long (ms)
  static const int _sameWordCooldownMs = 3000;

  /// After adding ANY word, minimum gap before next word (ms)
  static const int _anyWordCooldownMs = 600;

  String _stableLabel      = '';
  DateTime _stableStart    = DateTime(0);
  String _lastAdded        = '';
  DateTime _lastAddedAt    = DateTime(0);
  DateTime _lastAnyAdded   = DateTime(0);

  /// Call every time a new prediction arrives.
  /// Returns the word to add, or null if nothing should be added yet.
  String? update(String label, double conf) {
    // Normalise
    final lbl = label.toLowerCase().trim();

    // Ignore non-words and very low confidence (below 20% = sensor noise)
    if (lbl.isEmpty || lbl == '—' || lbl == 'no sign') return null;
    if (conf < 0.20) return null;
    if (!_kModelWords.contains(lbl)) return null;

    final now = DateTime.now();

    // ── Stability tracking ────────────────────
    if (lbl == _stableLabel) {
      // Same label — check if held long enough
      final held = now.difference(_stableStart).inMilliseconds;
      if (held >= _stabilityMs) {
        // ── Cooldown checks ───────────────────
        final sinceAny  = now.difference(_lastAnyAdded).inMilliseconds;
        final sinceSame = now.difference(_lastAddedAt).inMilliseconds;

        if (sinceAny < _anyWordCooldownMs) return null;
        if (lbl == _lastAdded && sinceSame < _sameWordCooldownMs) return null;

        // ── Lock and add ──────────────────────
        _lastAdded    = lbl;
        _lastAddedAt  = now;
        _lastAnyAdded = now;

        // Reset stability so the same sign doesn't fire again immediately
        _stableStart = now.add(const Duration(milliseconds: _sameWordCooldownMs));
        return lbl;
      }
    } else {
      // Label changed — reset stability window
      _stableLabel = lbl;
      _stableStart = now;
    }
    return null;
  }

  void reset() {
    _stableLabel   = '';
    _stableStart   = DateTime(0);
    _lastAdded     = '';
    _lastAddedAt   = DateTime(0);
    _lastAnyAdded  = DateTime(0);
  }

  /// Progress 0→1 of how close the current sign is to locking in.
  double stabilityProgress(String currentLabel) {
    if (currentLabel != _stableLabel) return 0.0;
    final held = DateTime.now().difference(_stableStart).inMilliseconds;
    return (held / _stabilityMs).clamp(0.0, 1.0);
  }
}

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
enum _SessionState { idle, connecting, running, stopping, error }

class _GestureToken {
  final String label;
  final double confidence;
  _GestureToken({required this.label, required this.confidence});
}

// ─────────────────────────────────────────────
//  ONBOARDING FLOW  (3s loader → 5-step guide)
// ─────────────────────────────────────────────
class _OnboardingFlow extends StatefulWidget {
  final bool isDark;
  final VoidCallback onComplete;
  const _OnboardingFlow({required this.isDark, required this.onComplete});
  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow>
    with TickerProviderStateMixin {
  int _phase = 0;
  int _stepIndex = 0;
  Timer? _loaderTimer;

  late AnimationController _loaderCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _dialogCtrl;
  late Animation<double> _loaderAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _dialogScale;
  late Animation<double> _dialogFade;

  static const _steps = [
    (icon: Icons.center_focus_strong_rounded, color: Color(0xFF4F6EF7),
     titleKey: 'translate_onboard_title_1', bodyKey: 'translate_onboard_body_1'),
    (icon: Icons.back_hand_rounded, color: Color(0xFF22C55E),
     titleKey: 'translate_onboard_title_2', bodyKey: 'translate_onboard_body_2'),
    (icon: Icons.wb_sunny_rounded, color: Color(0xFFF59E0B),
     titleKey: 'translate_onboard_title_3', bodyKey: 'translate_onboard_body_3'),
    (icon: Icons.auto_fix_high_rounded, color: Color(0xFFA78BFA),
     titleKey: 'translate_onboard_title_4', bodyKey: 'translate_onboard_body_4'),
    (icon: Icons.translate_rounded, color: Color(0xFFEF4444),
     titleKey: 'translate_onboard_title_5', bodyKey: 'translate_onboard_body_5'),
  ];

  @override
  void initState() {
    super.initState();
    _loaderCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _loaderAnim = CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeInOut);
    _fadeCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim   = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _dialogCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _dialogScale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOutBack));
    _dialogFade = CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOut);

    _loaderCtrl.forward();
    _fadeCtrl.forward();

    _loaderTimer = Timer(const Duration(milliseconds: 3250), () {
      if (!mounted) return;
      _fadeCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() => _phase = 1);
        _fadeCtrl.forward();
        _dialogCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    _loaderCtrl.dispose();
    _fadeCtrl.dispose();
    _dialogCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_stepIndex < _steps.length - 1) setState(() => _stepIndex++);
    else widget.onComplete();
  }

  void _prev() { if (_stepIndex > 0) setState(() => _stepIndex--); }

  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    return Material(
      color: _C.bg(d),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: _phase == 0 ? _loader(d) : _stepsDialog(d),
      ),
    );
  }

  Widget _loader(bool d) => Stack(children: [
    Positioned.fill(child: _GridBg(isDark: d)),
    Positioned(top: -150, left: -100, child: _Glow(color: _C.accent.withOpacity(d ? 0.09 : 0.06), size: 540)),
    Positioned(bottom: -100, right: -80, child: _Glow(color: _C.purple.withOpacity(d ? 0.06 : 0.04), size: 400)),
    Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 100, height: 100,
          child: AnimatedBuilder(
            animation: _loaderAnim,
            builder: (_, __) => CustomPaint(
              painter: _RingPainter(progress: _loaderAnim.value, isDark: d)),
          ),
        ),
        const SizedBox(height: 32),
        Text('VANI', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
            letterSpacing: 12, color: _C.text(d))),
        const SizedBox(height: 6),
        Text('Sign Language Translator', style: TextStyle(
            fontSize: 12, color: _C.textSub(d), letterSpacing: 3, fontWeight: FontWeight.w500)),
        const SizedBox(height: 52),
        SizedBox(
          width: 210,
          child: Column(children: [
            AnimatedBuilder(
              animation: _loaderAnim,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _loaderAnim.value, minHeight: 3,
                  backgroundColor: _C.border(d),
                  valueColor: const AlwaysStoppedAnimation(_C.accent)),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _loaderAnim,
              builder: (_, __) => Text(_loaderLabel(_loaderAnim.value),
                  style: TextStyle(fontSize: 11, color: _C.textMuted(d), letterSpacing: 0.4)),
            ),
          ]),
        ),
      ]),
    ),
  ]);

  String _loaderLabel(double v) {
    if (v < 0.35) return 'Loading camera modules…';
    if (v < 0.70) return 'Initialising AI engine…';
    return 'Calibrating gesture model…';
  }

  Widget _stepsDialog(bool d) {
    final l = AppLocalizations.of(context);
    final step = _steps[_stepIndex];
    final isLast = _stepIndex == _steps.length - 1;
    return Stack(children: [
      Positioned.fill(child: _GridBg(isDark: d)),
      Positioned(top: -150, left: -100,
          child: _Glow(color: _C.accent.withOpacity(d ? 0.07 : 0.05), size: 520)),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ScaleTransition(
            scale: _dialogScale,
            child: FadeTransition(
              opacity: _dialogFade,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                decoration: BoxDecoration(
                  color: _C.surface(d),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _C.border(d), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(d ? 0.55 : 0.14),
                      blurRadius: 56, offset: const Offset(0, 18))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [step.color, _C.accent]),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                    child: Column(children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _C.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(l.t('translate_how_to_use'),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                                  color: _C.accent, letterSpacing: 2)),
                        ),
                        const Spacer(),
                        Text('${_stepIndex + 1} / ${_steps.length}',
                            style: TextStyle(fontSize: 11, color: _C.textMuted(d),
                                fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: Container(
                          key: ValueKey(_stepIndex),
                          width: 74, height: 74,
                          decoration: BoxDecoration(
                            color: step.color.withOpacity(0.1), shape: BoxShape.circle,
                            border: Border.all(color: step.color.withOpacity(0.28), width: 2)),
                          child: Icon(step.icon, color: step.color, size: 32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(l.t(step.titleKey), key: ValueKey('t$_stepIndex'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                                color: _C.text(d), letterSpacing: -0.3)),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(l.t(step.bodyKey), key: ValueKey('b$_stepIndex'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: _C.textSub(d), height: 1.65)),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps.length, (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _stepIndex ? 22 : 6, height: 6,
                          decoration: BoxDecoration(
                            color: i == _stepIndex ? _C.accent : _C.border2(d),
                            borderRadius: BorderRadius.circular(3)),
                        )),
                      ),
                      const SizedBox(height: 26),
                      Row(children: [
                        if (_stepIndex > 0) ...[
                          Expanded(child: _OBtn(label: l.t('translate_back'),
                              icon: Icons.arrow_back_rounded, isDark: d, onTap: _prev)),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: _PBtn(
                            label: isLast ? l.t('translate_lets_begin') : l.t('translate_next'),
                            icon: isLast ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                            isDark: d, onTap: _next),
                        ),
                      ]),
                      if (!isLast) ...[
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: widget.onComplete,
                          child: Text(l.t('translate_skip_tutorial'),
                              style: TextStyle(fontSize: 12, color: _C.textMuted(d),
                                  decoration: TextDecoration.underline,
                                  decorationColor: _C.textMuted(d))),
                        ),
                      ],
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _PBtn extends StatelessWidget {
  final String label; final IconData icon; final bool isDark; final VoidCallback onTap;
  const _PBtn({required this.label, required this.icon, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _C.accent, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _C.accent.withOpacity(0.38), blurRadius: 22, offset: const Offset(0, 7))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(width: 6),
        Icon(icon, size: 16, color: Colors.white),
      ]),
    ),
  );
}

class _OBtn extends StatelessWidget {
  final String label; final IconData icon; final bool isDark; final VoidCallback onTap;
  const _OBtn({required this.label, required this.icon, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border2(isDark), width: 1.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: _C.textSub(isDark)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.textSub(isDark))),
      ]),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress; final bool isDark;
  _RingPainter({required this.progress, required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    canvas.drawCircle(c, r, Paint()..color = _C.accent.withOpacity(0.08));
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), -math.pi / 2,
      2 * math.pi * progress, false,
      Paint()..color = _C.accent..strokeWidth = 3
        ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    if (progress > 0.05)
      canvas.drawCircle(c, r - 12, Paint()..color = _C.accent.withOpacity(0.08 * progress));
    final p = Paint()..color = _C.accent.withOpacity(0.3 + 0.65 * progress)..style = PaintingStyle.fill;
    final cx = c.dx; final cy = c.dy;
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 9), width: 28, height: 18),
        const Radius.circular(6)), p);
    for (int i = 0; i < 4; i++)
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 15 + i * 10.0, cy - 12, 7, 20),
          const Radius.circular(4)), p);
  }
  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────
//  TRANSLATE SCREEN
// ─────────────────────────────────────────────
class TranslateScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const TranslateScreen({super.key, required this.toggleTheme, required this.setLocale});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  bool _onboardingDone = false;

  // Camera
  CameraController? _camCtrl;
  List<CameraDescription>? _cameras;
  int _camIndex = 0;
  bool _isCameraReady = false;

  // WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  bool _wsConnected = false;

  // Session
  _SessionState _state = _SessionState.idle;
  String? _sessionError;

  // Inference
  String _label = '—';
  double _conf  = 0.0;
  int _frameCount = 0;

  // Translation output
  String _selectedLang = 'Hindi';
  String _regionalLabel = '';
  final Map<String, String> _langCodes = {
    'Hindi': 'hi', 'Marathi': 'mr', 'Gujarati': 'gu',
    'Tamil': 'ta', 'Telugu': 'te', 'Kannada': 'kn', 'Bengali': 'bn',
  };

  // Sentence builder
  final List<_GestureToken> _tokens = [];
  String _sentence       = '';
  String _sentenceRegional = '';
  final _AutoAddEngine _autoEngine = _AutoAddEngine();

  // Stability ring — updated on every tick for the UI ring
  double _stabilityProgress = 0.0;
  Timer? _stabilityUiTimer;   // 60fps UI refresh for the ring

  // Frame timer
  Timer? _frameTimer;
  bool _isCapturing = false;

  // Transcript
  final TextEditingController _transcriptCtrl = TextEditingController();

  // Reconnect
  int _reconnects = 0;
  static const _kMaxReconnect = 5;
  Timer? _reconnectTimer;

  // TTS
  final FlutterTts _tts = FlutterTts();
  bool _ttsSpeaking    = false;
  String _ttsSpeakingLang = '';

  // Pulse
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCameras();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if ((s == AppLifecycleState.inactive || s == AppLifecycleState.paused) &&
        _state == _SessionState.running)
      _stopSession();
  }

  Future<String> _translate(String text, String code) async {
    try {
      final url = 'https://translate.googleapis.com/translate_a/single'
          '?client=gtx&sl=en&tl=$code&dt=t&q=${Uri.encodeComponent(text)}';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) return jsonDecode(res.body)[0][0][0] as String;
    } catch (_) {}
    return text;
  }

  Future<void> _setupCameras() async {
    try { _cameras = await availableCameras(); } catch (_) {}
  }

  Future<bool> _initCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return false;
    try {
      _camCtrl = CameraController(
        _cameras![_camIndex], ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: kIsWeb ? null : ImageFormatGroup.jpeg);
      await _camCtrl!.initialize();
      if (!mounted) return false;
      setState(() => _isCameraReady = true);
      return true;
    } catch (_) { return false; }
  }

  Future<void> _disposeCamera() async {
    _isCameraReady = false;
    final c = _camCtrl; _camCtrl = null;
    try {
      if (!kIsWeb && c != null && c.value.isInitialized &&
          c.value.isStreamingImages) await c.stopImageStream();
      await c?.dispose();
    } catch (_) {}
  }

  Future<bool> _connectWs() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_getWebSocketUrl()));
      await _channel!.ready.timeout(const Duration(seconds: 3));
      _wsConnected = true;
      _reconnects  = 0;
      _wsSub = _channel!.stream.listen(_onMsg, onError: _onErr, onDone: _onDone, cancelOnError: false);
      return true;
    } catch (_) { _wsConnected = false; return false; }
  }

  void _onMsg(dynamic raw) {
    if (!mounted) return;
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String? ?? 'prediction';

      if (type == 'ping') { _channel?.sink.add('__PING__'); return; }

      if (type == 'error') {
        setState(() { _state = _SessionState.error; _sessionError = data['message'] as String? ?? 'Error'; });
        return;
      }

      if (type == 'prediction') {
        final lbl  = (data['label'] ?? '—').toString();
        final conf = (data['confidence'] ?? 0.0).toDouble();

        setState(() {
          _label      = lbl;
          _conf       = conf;
          _frameCount = data['frame'] ?? _frameCount;
        });

        // ── Auto-add via stability engine ──────
        final toAdd = _autoEngine.update(lbl, conf);
        if (toAdd != null) _addToken(toAdd, conf, fromAuto: true);

        // ── Regional translation of current label ──
        _translate(lbl, _langCodes[_selectedLang]!)
            .then((t) { if (mounted) setState(() => _regionalLabel = t); });
      }
    } catch (_) {}
  }

  void _onErr(Object _) { _wsConnected = false; if (_state == _SessionState.running) _tryReconnect(); }
  void _onDone()         { _wsConnected = false; if (_state == _SessionState.running) _tryReconnect(); }

  void _tryReconnect() {
    if (_reconnects >= _kMaxReconnect) {
      if (mounted) setState(() { _state = _SessionState.error; _sessionError = 'Connection lost. Please restart.'; });
      return;
    }
    _reconnects++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnects * 2), () async {
      if (!mounted || _state != _SessionState.running) return;
      if (!await _connectWs()) _tryReconnect();
    });
  }

  Future<void> _closeWs() async {
    _reconnectTimer?.cancel();
    await _wsSub?.cancel(); _wsSub = null;
    try {
      _channel?.sink.add('__STOP__');
      await Future.delayed(const Duration(milliseconds: 150));
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null; _wsConnected = false;
  }

  void _startFrameTimer() {
    _frameTimer?.cancel(); _isCapturing = false;
    _frameTimer = Timer.periodic(Duration(milliseconds: _kFrameIntervalMs), (_) => _captureAndSend());
  }

  Future<void> _captureAndSend() async {
    if (_isCapturing || !_wsConnected) return;
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    _isCapturing = true;
    try {
      final f = await _camCtrl!.takePicture();
      _channel!.sink.add(base64Encode(await f.readAsBytes()));
    } catch (_) {} finally { _isCapturing = false; }
  }

  void _stopFrameTimer() { _frameTimer?.cancel(); _frameTimer = null; _isCapturing = false; }

  // ── Stability ring UI refresh (runs at ~60fps during session) ──
  void _startStabilityTimer() {
    _stabilityUiTimer?.cancel();
    _stabilityUiTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _stabilityProgress = _autoEngine.stabilityProgress(_label.toLowerCase().trim());
      });
    });
  }
  void _stopStabilityTimer() {
    _stabilityUiTimer?.cancel();
    _stabilityUiTimer = null;
    _stabilityProgress = 0.0;
  }

  Future<void> _startSession() async {
    if (_state != _SessionState.idle && _state != _SessionState.error) return;
    setState(() { _state = _SessionState.connecting; _sessionError = null; _label = '—'; _conf = 0; _frameCount = 0; });
    if (!await _initCamera()) {
      setState(() { _state = _SessionState.error; _sessionError = 'Camera unavailable'; });
      return;
    }
    if (!await _connectWs()) {
      await _disposeCamera();
      setState(() { _state = _SessionState.error; _sessionError = 'Cannot connect to inference server.\nEnsure backend is running.'; });
      return;
    }
    _autoEngine.reset();
    _startFrameTimer();
    _startStabilityTimer();
    setState(() => _state = _SessionState.running);
  }

  Future<void> _stopSession() async {
    if (_state == _SessionState.idle || _state == _SessionState.stopping) return;
    setState(() => _state = _SessionState.stopping);
    _stopFrameTimer();
    _stopStabilityTimer();
    await _tts.stop();
    await _closeWs();
    await _disposeCamera();
    if (!mounted) return;
    setState(() { _state = _SessionState.idle; _label = '—'; _conf = 0; _isCameraReady = false; });
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    final was = _state == _SessionState.running;
    if (was) await _stopSession();
    _camIndex = (_camIndex + 1) % _cameras!.length;
    if (was) await _startSession();
  }

  void _addToken(String lbl, double conf, {bool fromAuto = false}) {
    final normalised = lbl.toLowerCase().trim();
    if (!_kModelWords.contains(normalised)) return;
    setState(() {
      _tokens.add(_GestureToken(label: normalised, confidence: conf));
      _rebuildSentence();
    });
    if (fromAuto) HapticFeedback.lightImpact();
  }

  void _addCurrentManually() {
    if (_label == '—' || _label.isEmpty) return;
    _addToken(_label, _conf);
    // Reset stability engine so the same sign doesn't auto-fire right after manual add
    _autoEngine.reset();
  }

  void _removeToken(int i) {
    setState(() { _tokens.removeAt(i); _rebuildSentence(); });
  }

  void _removeLastToken() {
    if (_tokens.isEmpty) return;
    setState(() { _tokens.removeLast(); _rebuildSentence(); });
  }

  void _clearBuilder() {
    setState(() { _tokens.clear(); _sentence = ''; _sentenceRegional = ''; });
  }

  void _rebuildSentence() {
    _sentence = SentenceBuilder.build(_tokens.map((t) => t.label).toList());
    if (_sentence.isNotEmpty) {
      _translate(_sentence, _langCodes[_selectedLang]!)
          .then((t) { if (mounted) setState(() => _sentenceRegional = t); });
    } else {
      _sentenceRegional = '';
    }
  }

  void _commitToTranscript() {
    if (_sentence.isEmpty) return;
    final t = _transcriptCtrl.text;
    _transcriptCtrl.text = t.isEmpty ? _sentence : '$t\n$_sentence';
    _transcriptCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _transcriptCtrl.text.length));
    _clearBuilder();
  }

  Future<void> _speak(String text, String langCode, String tag) async {
    if (text.isEmpty || text == '—' || text == '…') return;
    if (_ttsSpeaking && _ttsSpeakingLang == tag) {
      await _tts.stop();
      setState(() { _ttsSpeaking = false; _ttsSpeakingLang = ''; });
      return;
    }
    await _tts.stop();
    await _tts.setLanguage(langCode);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    setState(() { _ttsSpeaking = true; _ttsSpeakingLang = tag; });
    await _tts.speak(text);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() { _ttsSpeaking = false; _ttsSpeakingLang = ''; });
    });
  }

  String _ttsLangCode(String lang) {
    const m = { 'Hindi':'hi-IN','Marathi':'mr-IN','Gujarati':'gu-IN',
      'Tamil':'ta-IN','Telugu':'te-IN','Kannada':'kn-IN','Bengali':'bn-IN' };
    return m[lang] ?? 'hi-IN';
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_rounded, color: _C.green, size: 15),
        SizedBox(width: 8),
        Text('Copied to clipboard', style: TextStyle(fontSize: 13, color: Colors.white)),
      ]),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1A2236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _stabilityUiTimer?.cancel();
    _stopSession();
    _transcriptCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD — adapts between mobile-native and desktop website
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final d      = Theme.of(context).brightness == Brightness.dark;
    final w      = MediaQuery.of(context).size.width;
    final isMob  = w < 700;

    if (!_onboardingDone) {
      return _OnboardingFlow(
        isDark: d,
        onComplete: () { if (mounted) setState(() => _onboardingDone = true); },
      );
    }

    // Mobile → fullscreen camera + floating controls + bottom sheet panel
    if (isMob) return _buildMobile(context, d);

    // Desktop / wide → original side-by-side layout
    return _buildDesktop(context, d, w > 900);
  }

  // ══════════════════════════════════════════════
  //  MOBILE LAYOUT
  //  Camera fills entire screen. Output is a
  //  draggable bottom sheet. Controls are floating.
  // ══════════════════════════════════════════════
  Widget _buildMobile(BuildContext context, bool d) {
    final l        = AppLocalizations.of(context);
    final isRunning = _state == _SessionState.running;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(fit: StackFit.expand, children: [

        // ── Camera fills entire screen ──────────
        if (isRunning && _camCtrl != null && _camCtrl!.value.isInitialized)
          CameraPreview(_camCtrl!)
        else
          _MobileCamPlaceholder(isDark: d, state: _state),

        // Scanlines
        if (isRunning)
          IgnorePointer(child: CustomPaint(
              painter: _ScanlinePainter(color: _C.accent))),

        // Corner brackets overlay
        IgnorePointer(child: CustomPaint(painter: _CornerPainter(
            color: _C.accent.withOpacity(isRunning ? 0.7 : 0.3)))),

        // ── Top bar: back + status + flip ───────
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                // Back
                _CamIconBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context)),
                const Spacer(),
                // Status pill
                _MobileStatusPill(state: _state),
                const SizedBox(width: 10),
                // Flip camera
                _CamIconBtn(
                  icon: Icons.flip_camera_ios_rounded,
                  onTap: _switchCamera),
              ]),
            ),
          ),
        ),

        // LIVE badge
        if (isRunning)
          Positioned(top: 72, left: 16,
              child: _LiveBadge(pulse: _pulseAnim)),

        // ── Label + stability overlay ────────────
        // Shown when model returns a prediction
        if (isRunning && _conf > 0.15)
          Positioned(
            top: 72, left: 0, right: 0,
            child: Center(child: _MobileLabelOverlay(
              label: _label,
              confidence: _conf,
              stabilityProgress: _stabilityProgress,
            )),
          ),

        // ── Connecting / error overlays ──────────
        if (_state == _SessionState.connecting) _ConnectingOverlay(),
        if (_state == _SessionState.error) const _ErrorOverlay(),
        if (_state == _SessionState.error && _sessionError != null)
          Positioned(
            bottom: 260, left: 20, right: 20,
            child: _ErrBanner(message: _sessionError!, isDark: d)),

        // ── Bottom floating panel ────────────────
        // Contains: session button + language + tokens + sentence + transcript
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _MobileBottomPanel(
            isDark: d,
            state: _state,
            label: _label,
            conf: _conf,
            regionalLabel: _regionalLabel,
            selectedLang: _selectedLang,
            langCodes: _langCodes,
            tokens: _tokens,
            sentence: _sentence,
            sentenceRegional: _sentenceRegional,
            stabilityProgress: _stabilityProgress,
            ttsSpeaking: _ttsSpeaking,
            ttsSpeakingLang: _ttsSpeakingLang,
            transcriptCtrl: _transcriptCtrl,
            onStartSession:   _startSession,
            onStopSession:    _stopSession,
            onSwitchCamera:   _switchCamera,
            onAddManually:    _addCurrentManually,
            onRemoveLast:     _removeLastToken,
            onClearAll:       _clearBuilder,
            onCommit:         _commitToTranscript,
            onRemoveToken:    _removeToken,
            onLangChanged:    (v) { if (v != null && mounted) setState(() => _selectedLang = v); },
            onCopy:           _copy,
            onSpeak:          _speak,
            ttsLangCode:      _ttsLangCode,
            l:                l,
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════
  //  DESKTOP LAYOUT  (unchanged from original)
  // ══════════════════════════════════════════════
  Widget _buildDesktop(BuildContext context, bool d, bool isWide) {
    return Scaffold(
      backgroundColor: _C.bg(d),
      body: Stack(children: [
        Positioned.fill(child: _GridBg(isDark: d)),
        Positioned(top: -180, left: -110,
            child: _Glow(color: _C.accent.withOpacity(d ? 0.07 : 0.04), size: 580)),
        Positioned(bottom: -90, right: -90,
            child: _Glow(color: _C.green.withOpacity(d ? 0.04 : 0.025), size: 400)),
        SafeArea(
          child: Column(children: [
            GlobalNavbar(toggleTheme: widget.toggleTheme,
                setLocale: widget.setLocale, activeRoute: 'translate'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: isWide ? _wideLayout(d) : _narrowLayout(d),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _wideLayout(bool d) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(flex: 6, child: _cameraSection(d)),
    const SizedBox(width: 18),
    Expanded(flex: 5, child: Column(children: [
      _detectionSection(d),
      const SizedBox(height: 16),
      _sentenceSection(d),
      const SizedBox(height: 16),
      _transcriptSection(d),
    ])),
  ]);

  Widget _narrowLayout(bool d) => Column(children: [
    _cameraSection(d),
    const SizedBox(height: 16),
    _detectionSection(d),
    const SizedBox(height: 16),
    _sentenceSection(d),
    const SizedBox(height: 16),
    _transcriptSection(d),
  ]);

  // ─────────────────────────────────────────────
  //  CAMERA SECTION  (desktop only)
  // ─────────────────────────────────────────────
  Widget _cameraSection(bool d) {
    final l = AppLocalizations.of(context);
    final isRunning = _state == _SessionState.running;
    return _Card(isDark: d, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _Badge(icon: Icons.sensors_rounded, color: _C.accent, isDark: d),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.t('translate_vision_title'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _C.text(d))),
          const SizedBox(height: 2),
          Text(l.t('translate_vision_sub'),
              style: TextStyle(fontSize: 12, color: _C.textSub(d))),
        ])),
        _StatusChip(state: _state, isDark: d),
      ]),
      const SizedBox(height: 18),
      AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: d ? const Color(0xFF060810) : const Color(0xFF0A0E1C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.border(d))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(fit: StackFit.expand, children: [
              if (isRunning && _camCtrl != null && _camCtrl!.value.isInitialized)
                CameraPreview(_camCtrl!)
              else
                _CamPlaceholder(isDark: d),
              if (isRunning) IgnorePointer(child: CustomPaint(
                  painter: _ScanlinePainter(color: _C.accent))),
              if (isRunning) Positioned(top: 12, left: 12,
                  child: _LiveBadge(pulse: _pulseAnim)),
              if (isRunning && _conf > 0.15)
                Positioned(bottom: 12, left: 12, right: 12,
                  child: _StabilityConfBanner(
                    label: _label, confidence: _conf,
                    stabilityProgress: _stabilityProgress)),
              if (_state == _SessionState.connecting) _ConnectingOverlay(),
              if (_state == _SessionState.error) const _ErrorOverlay(),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _OutlineBtn(icon: Icons.flip_camera_android_rounded,
            label: l.t('translate_switch'), isDark: d, onTap: _switchCamera),
        const SizedBox(width: 12),
        Expanded(child: _SessionBtn(
            state: _state, isDark: d, onStart: _startSession, onStop: _stopSession)),
      ]),
      if (_state == _SessionState.error && _sessionError != null) ...[
        const SizedBox(height: 12),
        _ErrBanner(message: _sessionError!, isDark: d),
      ],
    ]));
  }

  // ─────────────────────────────────────────────
  //  DETECTION SECTION  (desktop only)
  // ─────────────────────────────────────────────
  Widget _detectionSection(bool d) {
    final l = AppLocalizations.of(context);
    final isActive = _state == _SessionState.running;
    return _Card(isDark: d, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _Badge(icon: Icons.translate_rounded, color: _C.green, isDark: d),
        const SizedBox(width: 12),
        Expanded(child: Text(l.t('translate_prediction'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.text(d)))),
        _LangSelector(value: _selectedLang, options: _langCodes.keys.toList(),
            isDark: d, onChanged: (v) { if (v != null) setState(() => _selectedLang = v); }),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _DetCard(code: 'EN', color: _C.accent, isDark: d,
            text: isActive ? _label : l.t('translate_waiting'), isActive: isActive)),
        const SizedBox(width: 8),
        _TtsBtn(color: _C.accent,
            isSpeaking: _ttsSpeaking && _ttsSpeakingLang == 'en',
            onTap: isActive ? () => _speak(_label, 'en-US', 'en') : null),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _DetCard(
            code: _selectedLang.substring(0, 2).toUpperCase(), color: _C.green, isDark: d,
            text: isActive ? (_regionalLabel.isNotEmpty ? _regionalLabel : '…') : l.t('translate_waiting'),
            isActive: isActive)),
        const SizedBox(width: 8),
        _TtsBtn(color: _C.green,
            isSpeaking: _ttsSpeaking && _ttsSpeakingLang == 'regional',
            onTap: isActive && _regionalLabel.isNotEmpty
                ? () => _speak(_regionalLabel, _ttsLangCode(_selectedLang), 'regional') : null),
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('CONFIDENCE', style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.w800, color: _C.textMuted(d), letterSpacing: 1.6)),
        Text(isActive ? '${(_conf * 100).toStringAsFixed(0)}%' : '—',
            style: TextStyle(fontSize: 11, color: _C.textSub(d), fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      _ConfBar(value: isActive ? _conf : 0),
      if (isActive) ...[
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Frames: $_frameCount',
              style: TextStyle(fontSize: 10, color: _C.textMuted(d))),
          if (_stabilityProgress > 0)
            Row(children: [
              SizedBox(width: 70, height: 4,
                child: ClipRRect(borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _stabilityProgress,
                    backgroundColor: _C.border(d),
                    valueColor: AlwaysStoppedAnimation(
                        _stabilityProgress >= 1.0 ? _C.green : _C.amber)))),
              const SizedBox(width: 6),
              Text(_stabilityProgress >= 1.0 ? 'Adding…' : 'Hold sign…',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: _stabilityProgress >= 1.0 ? _C.green : _C.amber)),
            ]),
        ]),
      ],
    ]));
  }

  // ─────────────────────────────────────────────
  //  SENTENCE SECTION  (desktop only)
  // ─────────────────────────────────────────────
  Widget _sentenceSection(bool d) {
    final l = AppLocalizations.of(context);
    return _Card(isDark: d,
      gradientAccent: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: d
            ? [_C.purple.withOpacity(0.07), Colors.transparent]
            : [_C.purple.withOpacity(0.04), Colors.transparent]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Badge(icon: Icons.auto_fix_high_rounded, color: _C.purple, isDark: d),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.t('translate_sentence_builder'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.text(d))),
            Text('Hold a sign to auto-add • Tap + to add manually',
                style: TextStyle(fontSize: 11, color: _C.textSub(d))),
          ])),
          GestureDetector(onTap: _addCurrentManually,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _C.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.accent.withOpacity(0.25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_rounded, color: _C.accent, size: 15),
                const SizedBox(width: 5),
                Text(l.t('translate_add_sign'),
                    style: const TextStyle(color: _C.accent, fontSize: 11, fontWeight: FontWeight.w800)),
              ]))),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _C.surface2(d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border(d))),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: _C.textMuted(d)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Hold a sign steady for ~0.8 s and it adds automatically. '
              'Use + to add immediately.',
              style: TextStyle(fontSize: 11, color: _C.textSub(d), height: 1.45))),
          ])),
        const SizedBox(height: 16),
        if (_tokens.isEmpty) _EmptyBuilder(isDark: d)
        else Wrap(spacing: 8, runSpacing: 8,
            children: _tokens.asMap().entries.map((e) => _TokenChip(
              index: e.key + 1, token: e.value,
              isLast: e.key == _tokens.length - 1,
              isDark: d, onRemove: () => _removeToken(e.key))).toList()),
        if (_tokens.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(children: [
            Icon(Icons.subdirectory_arrow_right_rounded, size: 13, color: _C.textMuted(d)),
            const SizedBox(width: 6),
            Text(l.t('translate_generated_sentence'),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: _C.textMuted(d), letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.surface2(d), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.purple.withOpacity(0.28))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _LangTag(code: 'EN', color: _C.purple),
                const SizedBox(width: 10),
                Expanded(child: Text(_sentence.isNotEmpty ? _sentence : '…',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                        color: _C.text(d), height: 1.35))),
                GestureDetector(onTap: () => _copy(_sentence),
                    child: Padding(padding: const EdgeInsets.all(4),
                        child: Icon(Icons.copy_rounded, size: 15, color: _C.textMuted(d)))),
                const SizedBox(width: 4),
                GestureDetector(onTap: () => _speak(_sentence, 'en-US', 'sentence_en'),
                    child: Padding(padding: const EdgeInsets.all(4),
                        child: Icon(_ttsSpeaking && _ttsSpeakingLang == 'sentence_en'
                            ? Icons.stop_rounded : Icons.volume_up_rounded,
                            size: 15, color: _C.purple.withOpacity(0.7)))),
              ]),
              if (_sentenceRegional.isNotEmpty) ...[
                const SizedBox(height: 10),
                Divider(color: _C.border(d), height: 1),
                const SizedBox(height: 10),
                Row(children: [
                  _LangTag(code: _selectedLang.substring(0, 2).toUpperCase(), color: _C.green),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_sentenceRegional,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                          color: _C.green, height: 1.35))),
                  GestureDetector(onTap: () => _copy(_sentenceRegional),
                      child: Padding(padding: const EdgeInsets.all(4),
                          child: Icon(Icons.copy_rounded, size: 15, color: _C.textMuted(d)))),
                  const SizedBox(width: 4),
                  GestureDetector(
                      onTap: () => _speak(_sentenceRegional, _ttsLangCode(_selectedLang), 'sentence_reg'),
                      child: Padding(padding: const EdgeInsets.all(4),
                          child: Icon(_ttsSpeaking && _ttsSpeakingLang == 'sentence_reg'
                              ? Icons.stop_rounded : Icons.volume_up_rounded,
                              size: 15, color: _C.green.withOpacity(0.7)))),
                ]),
              ],
            ])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _FillBtn(label: l.t('translate_save_transcript'),
                icon: Icons.save_alt_rounded, color: _C.accent, onTap: _commitToTranscript)),
            const SizedBox(width: 10),
            _IconBtnSmall(icon: Icons.backspace_outlined, color: _C.amber,
                tooltip: l.t('translate_remove_last'), onTap: _removeLastToken),
            const SizedBox(width: 8),
            _IconBtnSmall(icon: Icons.delete_sweep_rounded, color: _C.red,
                tooltip: l.t('translate_clear_all'), onTap: _clearBuilder),
          ]),
        ],
      ]));
  }

  // ─────────────────────────────────────────────
  //  TRANSCRIPT SECTION  (desktop only)
  // ─────────────────────────────────────────────
  Widget _transcriptSection(bool d) {
    final l = AppLocalizations.of(context);
    return _Card(isDark: d, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _Badge(icon: Icons.article_rounded, color: _C.amber, isDark: d),
        const SizedBox(width: 12),
        Expanded(child: Text(l.t('translate_transcription'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.text(d)))),
      ]),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(
          color: _C.surface2(d), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border(d))),
        child: TextField(
          controller: _transcriptCtrl, maxLines: 5,
          style: TextStyle(fontSize: 14, color: _C.text(d), height: 1.65),
          decoration: InputDecoration(
            hintText: l.t('translate_hint'),
            hintStyle: TextStyle(color: _C.textMuted(d), fontSize: 13),
            contentPadding: const EdgeInsets.all(16), border: InputBorder.none)),
      ),
      const SizedBox(height: 12),
      Row(children: [
        _IconBtnSmall(icon: Icons.copy_outlined, color: _C.accent,
            tooltip: l.t('translate_copy_transcript'), onTap: () => _copy(_transcriptCtrl.text)),
        const SizedBox(width: 8),
        _IconBtnSmall(icon: Icons.delete_outline_rounded, color: _C.red,
            tooltip: l.t('bridge_clear'), onTap: _transcriptCtrl.clear),
      ]),
    ]));
  }
}

// ══════════════════════════════════════════════
//  MOBILE-ONLY WIDGETS
// ══════════════════════════════════════════════

// ── Camera placeholder (mobile fullscreen) ────
class _MobileCamPlaceholder extends StatelessWidget {
  final bool isDark;
  final _SessionState state;
  const _MobileCamPlaceholder({required this.isDark, required this.state});
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF060810),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white.withOpacity(0.10))),
          child: const Icon(Icons.videocam_off_rounded,
              color: Colors.white24, size: 40)),
        const SizedBox(height: 20),
        Text(
          state == _SessionState.error ? 'Camera error' : 'Tap START to begin signing',
          style: const TextStyle(color: Colors.white38, fontSize: 14,
              fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

// ── Floating icon button (top controls) ────────
class _CamIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CamIconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.15))),
      child: Icon(icon, color: Colors.white, size: 20)));
}

// ── Status pill (floating top center) ─────────
class _MobileStatusPill extends StatelessWidget {
  final _SessionState state;
  const _MobileStatusPill({required this.state});
  @override
  Widget build(BuildContext context) {
    Color c; String lbl;
    switch (state) {
      case _SessionState.running:    c = _C.green; lbl = 'Live'; break;
      case _SessionState.connecting: c = _C.amber; lbl = 'Connecting'; break;
      case _SessionState.error:      c = _C.red;   lbl = 'Error'; break;
      default:                       c = Colors.white54; lbl = 'Ready';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.40))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
        const SizedBox(width: 6),
        Text(lbl, style: TextStyle(
            color: c, fontSize: 10.5, fontWeight: FontWeight.w700)),
      ]));
  }
}

// ── Label overlay (on-camera floating center) ─
class _MobileLabelOverlay extends StatelessWidget {
  final String label;
  final double confidence;
  final double stabilityProgress;
  const _MobileLabelOverlay({required this.label,
    required this.confidence, required this.stabilityProgress});
  @override
  Widget build(BuildContext context) {
    if (label == '—' || label.isEmpty) return const SizedBox.shrink();
    final confC = confidence > 0.75 ? _C.green : _C.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: confC.withOpacity(0.20),
              borderRadius: BorderRadius.circular(6)),
            child: Text('${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: confC, fontSize: 11, fontWeight: FontWeight.w800))),
        ]),
        if (stabilityProgress > 0) ...[
          const SizedBox(height: 6),
          SizedBox(width: 160, child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: stabilityProgress, minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(
                  stabilityProgress >= 1.0 ? _C.green : Colors.white54)))),
          const SizedBox(height: 3),
          Text(stabilityProgress >= 1.0 ? 'Adding…' : 'Hold steady…',
              style: TextStyle(
                color: stabilityProgress >= 1.0 ? _C.green : Colors.white54,
                fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ]));
  }
}

// ── Corner bracket painter ────────────────────
class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color..strokeWidth = 2.5
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const l = 28.0; const m = 20.0;
    // top-left
    canvas.drawPath(Path()..moveTo(m, m+l)..lineTo(m, m)..lineTo(m+l, m), p);
    // top-right
    canvas.drawPath(Path()..moveTo(size.width-m-l, m)..lineTo(size.width-m, m)..lineTo(size.width-m, m+l), p);
    // bottom-left
    canvas.drawPath(Path()..moveTo(m, size.height-m-l)..lineTo(m, size.height-m)..lineTo(m+l, size.height-m), p);
    // bottom-right
    canvas.drawPath(Path()..moveTo(size.width-m-l, size.height-m)..lineTo(size.width-m, size.height-m)..lineTo(size.width-m, size.height-m-l), p);
  }
  @override bool shouldRepaint(_CornerPainter o) => o.color != color;
}

// ── Mobile bottom panel ───────────────────────
// Frosted glass panel anchored at the bottom.
// Contains session button, lang picker, output cards, token builder, transcript.
// DraggableScrollableSheet gives it expand/collapse behaviour.
class _MobileBottomPanel extends StatefulWidget {
  final bool isDark;
  final _SessionState state;
  final String label, regionalLabel, selectedLang, sentence, sentenceRegional;
  final double conf, stabilityProgress;
  final Map<String, String> langCodes;
  final List<_GestureToken> tokens;
  final bool ttsSpeaking;
  final String ttsSpeakingLang;
  final TextEditingController transcriptCtrl;
  final VoidCallback onStartSession, onStopSession, onSwitchCamera,
      onAddManually, onRemoveLast, onClearAll, onCommit;
  final void Function(int) onRemoveToken;
  final void Function(String?) onLangChanged;
  final void Function(String) onCopy;
  final Future<void> Function(String, String, String) onSpeak;
  final String Function(String) ttsLangCode;
  final AppLocalizations l;

  const _MobileBottomPanel({
    required this.isDark, required this.state,
    required this.label, required this.conf,
    required this.regionalLabel, required this.selectedLang,
    required this.langCodes, required this.tokens,
    required this.sentence, required this.sentenceRegional,
    required this.stabilityProgress, required this.ttsSpeaking,
    required this.ttsSpeakingLang, required this.transcriptCtrl,
    required this.onStartSession, required this.onStopSession,
    required this.onSwitchCamera, required this.onAddManually,
    required this.onRemoveLast, required this.onClearAll,
    required this.onCommit, required this.onRemoveToken,
    required this.onLangChanged, required this.onCopy,
    required this.onSpeak, required this.ttsLangCode,
    required this.l,
  });

  @override
  State<_MobileBottomPanel> createState() => _MobileBottomPanelState();
}

class _MobileBottomPanelState extends State<_MobileBottomPanel> {
  // Which sub-panel is open: 0=output 1=builder 2=transcript
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    final isRunning = widget.state == _SessionState.running;
    final isLoading = widget.state == _SessionState.connecting
        || widget.state == _SessionState.stopping;
    final isErr = widget.state == _SessionState.error;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: d
                ? const Color(0xFF080E1E).withOpacity(0.92)
                : Colors.white.withOpacity(0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(
                color: d ? _C.dBorder2 : _C.lBorder2, width: 0.8))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // ── Drag handle ──────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: d ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2)))),

            // ── Session + lang row ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(children: [
                // Session button
                Expanded(child: _MobileSessionBtn(
                  state: widget.state,
                  isDark: d,
                  onStart: widget.onStartSession,
                  onStop: widget.onStopSession)),
                const SizedBox(width: 10),
                // Language picker — compact
                _MobileLangPill(
                  value: widget.selectedLang,
                  options: widget.langCodes.keys.toList(),
                  isDark: d,
                  onChanged: widget.onLangChanged),
              ])),

            // ── Sub-panel tabs ───────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _PanelTab(label: 'Output', icon: Icons.translate_rounded,
                    active: _tab == 0, isDark: d, onTap: () => setState(() => _tab = 0)),
                const SizedBox(width: 8),
                _PanelTab(label: 'Builder', icon: Icons.auto_fix_high_rounded,
                    active: _tab == 1, isDark: d, onTap: () => setState(() => _tab = 1),
                    badge: widget.tokens.length),
                const SizedBox(width: 8),
                _PanelTab(label: 'Transcript', icon: Icons.article_rounded,
                    active: _tab == 2, isDark: d, onTap: () => setState(() => _tab = 2)),
              ])),

            const SizedBox(height: 12),

            // ── Panel content ────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _tab == 0
                      ? _OutputPanel(widget: widget, d: d)
                      : _tab == 1
                      ? _BuilderPanel(widget: widget, d: d)
                      : _TranscriptPanel(widget: widget, d: d),
                ),
              ),
            ),

            // Safe area bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ]),
        ),
      ),
    );
  }
}

// ── Session button (mobile) ───────────────────
class _MobileSessionBtn extends StatefulWidget {
  final _SessionState state;
  final bool isDark;
  final VoidCallback onStart, onStop;
  const _MobileSessionBtn({required this.state, required this.isDark,
    required this.onStart, required this.onStop});
  @override State<_MobileSessionBtn> createState() => _MobileSessionBtnState();
}
class _MobileSessionBtnState extends State<_MobileSessionBtn> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    final isRunning = widget.state == _SessionState.running;
    final isLoading = widget.state == _SessionState.connecting
        || widget.state == _SessionState.stopping;
    final isErr     = widget.state == _SessionState.error;
    final c   = isRunning ? _C.red : isErr ? _C.amber : _C.accent;
    final lbl = isLoading
        ? (widget.state == _SessionState.connecting ? 'Connecting…' : 'Stopping…')
        : isRunning ? 'Stop' : isErr ? 'Retry' : 'START';
    final ico = isLoading ? Icons.hourglass_empty_rounded
        : isRunning ? Icons.stop_rounded
        : isErr ? Icons.refresh_rounded : Icons.videocam_rounded;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _p = true),
      onTapUp:     (_) {
        setState(() => _p = false);
        if (!isLoading) (isRunning ? widget.onStop : widget.onStart)();
      },
      onTapCancel: ()  => setState(() => _p = false),
      child: AnimatedScale(
        scale: _p ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: isRunning
                ? null
                : (isErr ? null : LinearGradient(colors: [c, c.withOpacity(0.75)])),
            color: (isRunning || isErr) ? c.withOpacity(0.12) : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(isRunning ? 0.35 : 0.0)),
            boxShadow: isRunning || isErr ? [] : [BoxShadow(
              color: c.withOpacity(0.38), blurRadius: 14, offset: const Offset(0, 5))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (isLoading)
              SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(c)))
            else
              Icon(ico, color: isRunning || isErr ? c : Colors.white, size: 17),
            const SizedBox(width: 7),
            Text(lbl, style: TextStyle(
              color: isRunning || isErr ? c : Colors.white,
              fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ]))));
  }
}

// ── Language pill (mobile, compact) ───────────
class _MobileLangPill extends StatelessWidget {
  final String value;
  final List<String> options;
  final bool isDark;
  final void Function(String?) onChanged;
  const _MobileLangPill({required this.value, required this.options,
    required this.isDark, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    decoration: BoxDecoration(
      color: _C.surface2(isDark), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _C.border2(isDark))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isDense: true,
        dropdownColor: _C.surface2(isDark),
        style: TextStyle(color: _C.text(isDark), fontWeight: FontWeight.w700, fontSize: 12),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: _C.textSub(isDark), size: 14),
        items: options.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: onChanged)));
}

// ── Panel tab chip ────────────────────────────
class _PanelTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active, isDark;
  final VoidCallback onTap;
  final int badge;
  const _PanelTab({required this.label, required this.icon,
    required this.active, required this.isDark, required this.onTap,
    this.badge = 0});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? _C.accent.withOpacity(isDark ? 0.15 : 0.09)
            : _C.surface2(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: active ? _C.accent.withOpacity(0.40) : _C.border(isDark))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: active ? _C.accent : _C.textSub(isDark)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          color: active ? _C.accent : _C.textSub(isDark),
          fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
        if (badge > 0) ...[
          const SizedBox(width: 5),
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(color: _C.accent, shape: BoxShape.circle),
            child: Center(child: Text('$badge',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
        ],
      ])));
}

// ── Output panel (tab 0) ──────────────────────
class _OutputPanel extends StatelessWidget {
  final _MobileBottomPanel widget;
  final bool d;
  const _OutputPanel({required this.widget, required this.d});
  @override
  Widget build(BuildContext context) {
    final isActive = widget.state == _SessionState.running;
    final confC    = widget.conf > 0.75 ? _C.green : _C.amber;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      // EN card
      _MobileDetRow(
        code: 'EN', color: _C.accent, isDark: d,
        text: isActive ? widget.label : '—',
        isSpeaking: widget.ttsSpeaking && widget.ttsSpeakingLang == 'en',
        onSpeak: isActive ? () => widget.onSpeak(widget.label, 'en-US', 'en') : null),
      const SizedBox(height: 8),
      // Regional card
      _MobileDetRow(
        code: widget.selectedLang.substring(0, 2).toUpperCase(),
        color: _C.green, isDark: d,
        text: isActive
            ? (widget.regionalLabel.isNotEmpty ? widget.regionalLabel : '…')
            : '—',
        isSpeaking: widget.ttsSpeaking && widget.ttsSpeakingLang == 'regional',
        onSpeak: isActive && widget.regionalLabel.isNotEmpty
            ? () => widget.onSpeak(widget.regionalLabel,
                widget.ttsLangCode(widget.selectedLang), 'regional')
            : null),
      // Confidence
      if (isActive) ...[
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Confidence', style: TextStyle(
              fontSize: 9.5, color: _C.textMuted(d),
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          Text('${(widget.conf * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 11, color: _C.textSub(d), fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: widget.conf, minHeight: 3,
            backgroundColor: _C.border(d),
            valueColor: AlwaysStoppedAnimation(confC))),
      ],
      const SizedBox(height: 6),
    ]);
  }
}

class _MobileDetRow extends StatelessWidget {
  final String code, text;
  final Color color;
  final bool isDark, isSpeaking;
  final VoidCallback? onSpeak;
  const _MobileDetRow({required this.code, required this.text,
    required this.color, required this.isDark, required this.isSpeaking,
    this.onSpeak});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _C.surface2(isDark), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _C.border(isDark))),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
        child: Text(code, style: TextStyle(
          fontSize: 8.5, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.3))),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w800,
        color: text == '—' ? _C.textMuted(isDark) : color,
        letterSpacing: -0.2))),
      if (onSpeak != null)
        GestureDetector(onTap: onSpeak,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isSpeaking ? color.withOpacity(0.16) : color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withOpacity(isSpeaking ? 0.45 : 0.18))),
            child: Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                color: color, size: 16))),
    ]));
}

// ── Builder panel (tab 1) ─────────────────────
class _BuilderPanel extends StatelessWidget {
  final _MobileBottomPanel widget;
  final bool d;
  const _BuilderPanel({required this.widget, required this.d});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      // Tokens or empty
      if (widget.tokens.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _C.surface2(d), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border(d))),
          child: Column(children: [
            Icon(Icons.gesture_rounded, color: _C.textMuted(d), size: 28),
            const SizedBox(height: 6),
            Text('Hold a sign steady to add it',
                style: TextStyle(color: _C.textSub(d), fontSize: 12)),
          ]))
      else
        Wrap(spacing: 7, runSpacing: 7,
            children: widget.tokens.asMap().entries.map((e) => _TokenChip(
              index: e.key + 1, token: e.value,
              isLast: e.key == widget.tokens.length - 1,
              isDark: d, onRemove: () => widget.onRemoveToken(e.key))).toList()),

      // Generated sentence
      if (widget.tokens.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.purple.withOpacity(d ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.purple.withOpacity(0.28))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(widget.sentence.isNotEmpty ? widget.sentence : '…',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: _C.text(d), height: 1.35))),
              GestureDetector(onTap: () => widget.onCopy(widget.sentence),
                  child: Icon(Icons.copy_rounded, size: 15, color: _C.textMuted(d))),
              const SizedBox(width: 4),
              GestureDetector(
                  onTap: () => widget.onSpeak(widget.sentence, 'en-US', 'sentence_en'),
                  child: Icon(widget.ttsSpeaking && widget.ttsSpeakingLang == 'sentence_en'
                      ? Icons.stop_rounded : Icons.volume_up_rounded,
                      size: 15, color: _C.purple.withOpacity(0.7))),
            ]),
            if (widget.sentenceRegional.isNotEmpty) ...[
              Divider(color: _C.border(d), height: 14),
              Text(widget.sentenceRegional,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: _C.green, height: 1.35)),
            ],
          ])),
      ],

      const SizedBox(height: 10),

      // Action row
      Row(children: [
        // Add manual
        Expanded(child: GestureDetector(onTap: widget.onAddManually,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(d ? 0.10 : 0.07),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _C.accent.withOpacity(0.25))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_rounded, color: _C.accent, size: 15),
              const SizedBox(width: 5),
              const Text('Add Sign', style: TextStyle(
                color: _C.accent, fontSize: 12, fontWeight: FontWeight.w800)),
            ])))),
        if (widget.tokens.isNotEmpty) ...[
          const SizedBox(width: 8),
          // Save to transcript
          Expanded(child: GestureDetector(onTap: widget.onCommit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _C.green.withOpacity(d ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _C.green.withOpacity(0.25))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.save_alt_rounded, color: _C.green, size: 15),
                SizedBox(width: 5),
                Text('Save', style: TextStyle(
                  color: _C.green, fontSize: 12, fontWeight: FontWeight.w800)),
              ])))),
          const SizedBox(width: 6),
          // Backspace
          GestureDetector(onTap: widget.onRemoveLast,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.amber.withOpacity(0.22))),
              child: const Icon(Icons.backspace_outlined, color: _C.amber, size: 15))),
          const SizedBox(width: 6),
          // Clear all
          GestureDetector(onTap: widget.onClearAll,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.red.withOpacity(0.22))),
              child: const Icon(Icons.delete_sweep_rounded, color: _C.red, size: 15))),
        ],
      ]),

      const SizedBox(height: 6),
    ]);
  }
}

// ── Transcript panel (tab 2) ──────────────────
class _TranscriptPanel extends StatelessWidget {
  final _MobileBottomPanel widget;
  final bool d;
  const _TranscriptPanel({required this.widget, required this.d});
  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        decoration: BoxDecoration(
          color: _C.surface2(d), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border(d))),
        child: TextField(
          controller: widget.transcriptCtrl, maxLines: 4,
          style: TextStyle(fontSize: 13.5, color: _C.text(d), height: 1.6),
          decoration: InputDecoration(
            hintText: l.t('translate_hint'),
            hintStyle: TextStyle(color: _C.textMuted(d), fontSize: 12.5),
            contentPadding: const EdgeInsets.all(14), border: InputBorder.none))),
      const SizedBox(height: 10),
      Row(children: [
        _MiniAction(icon: Icons.copy_outlined, label: 'Copy',
            color: _C.accent, isDark: d,
            onTap: () => widget.onCopy(widget.transcriptCtrl.text)),
        const SizedBox(width: 8),
        _MiniAction(icon: Icons.delete_outline_rounded, label: 'Clear',
            color: _C.red, isDark: d,
            onTap: widget.transcriptCtrl.clear),
      ]),
      const SizedBox(height: 6),
    ]);
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _MiniAction({required this.icon, required this.label,
    required this.color, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.22))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(
          color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ])));
}

// ═════════════════════════════════════════════
//  STABILITY CONF BANNER (replaces plain _ConfBanner)
// ═════════════════════════════════════════════
class _StabilityConfBanner extends StatelessWidget {
  final String label;
  final double confidence;
  final double stabilityProgress;

  const _StabilityConfBanner({
    required this.label,
    required this.confidence,
    required this.stabilityProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (label == '—' || label.isEmpty) return const SizedBox.shrink();
    final confC = confidence > 0.75 ? _C.green : _C.amber;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.07))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Text(label,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800, fontSize: 16))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: confC.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6)),
                child: Text('${(confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(color: confC, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
            // Stability progress bar at the bottom of the overlay
            if (stabilityProgress > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: stabilityProgress,
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(
                      stabilityProgress >= 1.0
                          ? _C.green
                          : Colors.white.withOpacity(0.7))),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
//  COMPONENTS  (unchanged from original)
// ═════════════════════════════════════════════
class _Card extends StatelessWidget {
  final Widget child; final bool isDark; final Gradient? gradientAccent;
  const _Card({required this.child, required this.isDark, this.gradientAccent});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _C.surface(isDark), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _C.border(isDark), width: 1.2),
      gradient: gradientAccent,
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
          blurRadius: 28, offset: const Offset(0, 8))]),
    child: child,
  );
}

class _Badge extends StatelessWidget {
  final IconData icon; final Color color; final bool isDark;
  const _Badge({required this.icon, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: color.withOpacity(isDark ? 0.14 : 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Icon(icon, color: color, size: 17),
  );
}

class _LangTag extends StatelessWidget {
  final String code; final Color color;
  const _LangTag({required this.code, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(code, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
        color: color, letterSpacing: 1.5)),
  );
}

class _StatusChip extends StatelessWidget {
  final _SessionState state; final bool isDark;
  const _StatusChip({required this.state, required this.isDark});
  @override
  Widget build(BuildContext context) {
    Color c; String lbl;
    switch (state) {
      case _SessionState.running:    c = _C.green;              lbl = 'Live'; break;
      case _SessionState.connecting: c = _C.amber;              lbl = 'Connecting'; break;
      case _SessionState.error:      c = _C.red;                lbl = 'Error'; break;
      default:                       c = _C.textMuted(isDark);  lbl = 'Idle';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.28))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
        const SizedBox(width: 6),
        Text(lbl, style: TextStyle(fontSize: 10, color: c,
            fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      ]),
    );
  }
}

class _LangSelector extends StatelessWidget {
  final String value; final List<String> options; final bool isDark;
  final ValueChanged<String?> onChanged;
  const _LangSelector({required this.value, required this.options,
    required this.isDark, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: _C.surface2(isDark), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.border2(isDark))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, dropdownColor: _C.surface2(isDark),
        style: TextStyle(color: _C.text(isDark), fontWeight: FontWeight.w700, fontSize: 12),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: _C.textSub(isDark), size: 16),
        items: options.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: onChanged),
    ),
  );
}

class _DetCard extends StatelessWidget {
  final String code, text; final Color color; final bool isDark, isActive;
  const _DetCard({required this.code, required this.text,
    required this.color, required this.isDark, required this.isActive});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: _C.surface2(isDark), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isActive ? color.withOpacity(0.35) : _C.border(isDark))),
    child: Row(children: [
      _LangTag(code: code, color: color), const SizedBox(width: 12),
      Expanded(child: Text(text, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: isActive ? color : _C.textMuted(isDark), letterSpacing: -0.3))),
    ]),
  );
}

class _ConfBar extends StatelessWidget {
  final double value;
  const _ConfBar({required this.value});
  @override
  Widget build(BuildContext context) {
    final c = value > 0.75 ? _C.green : value > 0.45 ? _C.amber : _C.accent;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value, minHeight: 4,
        backgroundColor: const Color(0x1AFFFFFF),
        valueColor: AlwaysStoppedAnimation<Color>(c)),
    );
  }
}

class _EmptyBuilder extends StatelessWidget {
  final bool isDark;
  const _EmptyBuilder({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 22),
    decoration: BoxDecoration(
      color: _C.surface2(isDark), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.border(isDark))),
    child: Column(children: [
      Icon(Icons.gesture_rounded, color: _C.textMuted(isDark), size: 30),
      const SizedBox(height: 8),
      Text('Hold a sign steady to build a sentence',
          style: TextStyle(color: _C.textSub(isDark), fontSize: 12)),
      const SizedBox(height: 4),
      Text('Or tap + to add the current sign manually',
          style: TextStyle(color: _C.textMuted(isDark), fontSize: 11)),
    ]),
  );
}

class _TokenChip extends StatelessWidget {
  final int index; final _GestureToken token; final bool isLast, isDark;
  final VoidCallback onRemove;
  const _TokenChip({required this.index, required this.token,
    required this.isLast, required this.isDark, required this.onRemove});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: isLast
          ? _C.purple.withOpacity(isDark ? 0.14 : 0.08)
          : _C.surface2(isDark),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: isLast ? _C.purple.withOpacity(0.4) : _C.border2(isDark),
          width: isLast ? 1.5 : 1)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$index', style: TextStyle(
              fontSize: 9, color: _C.textMuted(isDark), fontWeight: FontWeight.w700)),
          const SizedBox(width: 5),
          Text(token.label, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800,
              color: isLast ? _C.purple : _C.text(isDark))),
        ]),
      ),
      GestureDetector(
        onTap: onRemove,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Icon(Icons.close_rounded, size: 12,
              color: isLast ? _C.purple : _C.textMuted(isDark))),
      ),
    ]),
  );
}

class _FillBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _FillBtn({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.28))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 15), const SizedBox(width: 7),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}

class _IconBtnSmall extends StatelessWidget {
  final IconData icon; final Color color; final String tooltip; final VoidCallback onTap;
  const _IconBtnSmall({required this.icon, required this.color,
    required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, color: color, size: 16)),
    ),
  );
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon; final String label; final bool isDark; final VoidCallback onTap;
  const _OutlineBtn({required this.icon, required this.label, required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border2(isDark))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: _C.textSub(isDark)), const SizedBox(width: 7),
        Text(label, style: TextStyle(fontSize: 13, color: _C.textSub(isDark), fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

class _SessionBtn extends StatelessWidget {
  final _SessionState state; final bool isDark; final VoidCallback onStart, onStop;
  const _SessionBtn({required this.state, required this.isDark, required this.onStart, required this.onStop});
  @override
  Widget build(BuildContext context) {
    final isRunning = state == _SessionState.running;
    final isLoading = state == _SessionState.connecting || state == _SessionState.stopping;
    final isErr     = state == _SessionState.error;
    final Color c   = isRunning ? _C.red : isErr ? _C.amber : _C.accent;
    final String lbl = isLoading
        ? (state == _SessionState.connecting ? 'Connecting…' : 'Stopping…')
        : isRunning ? 'Stop Session' : isErr ? 'Retry' : 'Start Session';
    final IconData ico = isLoading
        ? Icons.hourglass_empty_rounded
        : isRunning ? Icons.stop_rounded : isErr ? Icons.refresh_rounded : Icons.play_arrow_rounded;
    return GestureDetector(
      onTap: isLoading ? null : (isRunning ? onStop : onStart),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (isLoading)
            SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(c)))
          else
            Icon(ico, color: c, size: 17),
          const SizedBox(width: 8),
          Text(lbl, style: TextStyle(color: c, fontSize: 13,
              fontWeight: FontWeight.w800, letterSpacing: 0.2)),
        ]),
      ),
    );
  }
}

class _TtsBtn extends StatelessWidget {
  final Color color; final bool isSpeaking; final VoidCallback? onTap;
  const _TtsBtn({required this.color, required this.isSpeaking, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: isSpeaking ? color.withOpacity(0.18) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSpeaking ? color.withOpacity(0.6) : color.withOpacity(0.22),
            width: isSpeaking ? 1.5 : 1)),
      child: Icon(
        isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
        color: onTap == null ? color.withOpacity(0.3) : color, size: 18),
    ),
  );
}

class _ErrBanner extends StatelessWidget {
  final String message; final bool isDark;
  const _ErrBanner({required this.message, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _C.red.withOpacity(isDark ? 0.1 : 0.06), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.red.withOpacity(0.25))),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: _C.red, size: 15), const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(color: _C.red, fontSize: 12, fontWeight: FontWeight.w500))),
    ]),
  );
}

class _CamPlaceholder extends StatelessWidget {
  final bool isDark;
  const _CamPlaceholder({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.08))),
        child: Icon(Icons.videocam_off_rounded,
            color: Colors.white.withOpacity(0.22), size: 36)),
      const SizedBox(height: 14),
      Text('Press Start Session to begin',
          style: TextStyle(color: Colors.white.withOpacity(0.28), fontSize: 13)),
    ]),
  );
}

class _ConnectingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black54,
    child: const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_C.accent), strokeWidth: 2),
        SizedBox(height: 14),
        Text('Establishing connection…',
            style: TextStyle(color: _C.accent, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    ),
  );
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay();
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.7),
    child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.warning_amber_rounded, color: _C.red, size: 34), SizedBox(height: 10),
      Text('Connection Error', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
    ])),
  );
}

class _LiveBadge extends StatelessWidget {
  final Animation<double> pulse;
  const _LiveBadge({required this.pulse});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (_, __) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.red.withOpacity(0.92), borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
            color: _C.red.withOpacity(0.45 * pulse.value), blurRadius: 14, spreadRadius: 1)]),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
        SizedBox(width: 6),
        Text('LIVE', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.8)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  BACKGROUND UTILITIES
// ─────────────────────────────────────────────
class _GridBg extends StatelessWidget {
  final bool isDark;
  const _GridBg({required this.isDark});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter(isDark: isDark));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = isDark
          ? const Color(0xFF1A2235).withOpacity(0.45)
          : const Color(0xFFB8C2E0).withOpacity(0.30)
      ..strokeWidth = 0.5;
    const s = 48.0;
    for (double x = 0; x < size.width; x += s)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += s)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(_GridPainter o) => o.isDark != isDark;
}

class _Glow extends StatelessWidget {
  final Color color; final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: const SizedBox.expand()),
  );
}

class _ScanlinePainter extends CustomPainter {
  final Color color;
  _ScanlinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final sl = Paint()..color = Colors.white.withOpacity(0.018)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), sl);
    final bp = Paint()..color = color.withOpacity(0.6)..strokeWidth = 2
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const l = 22.0; const m = 14.0;
    canvas.drawPath(Path()..moveTo(m, m + l)..lineTo(m, m)..lineTo(m + l, m), bp);
    canvas.drawPath(Path()..moveTo(size.width - m - l, m)..lineTo(size.width - m, m)..lineTo(size.width - m, m + l), bp);
    canvas.drawPath(Path()..moveTo(m, size.height - m - l)..lineTo(m, size.height - m)..lineTo(m + l, size.height - m), bp);
    canvas.drawPath(Path()..moveTo(size.width - m - l, size.height - m)..lineTo(size.width - m, size.height - m)..lineTo(size.width - m, size.height - m - l), bp);
  }
  @override
  bool shouldRepaint(_) => false;
}