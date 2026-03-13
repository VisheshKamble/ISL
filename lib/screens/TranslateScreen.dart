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

// ─────────────────────────────────────────────
//  WEBSOCKET CONFIG
// ─────────────────────────────────────────────
const _kDefaultWsPort = 8000;
const _kWsPath = '/ws';

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

const _kFrameIntervalMs = 100;

// ─────────────────────────────────────────────
//  DESIGN SYSTEM  (full light + dark support)
// ─────────────────────────────────────────────
class _C {
  static const lBg        = Color(0xFFF6F8FF);
  static const lSurface   = Color(0xFFFFFFFF);
  static const lSurface2  = Color(0xFFF0F3FB);
  static const lBorder    = Color(0xFFE2E7F4);
  static const lBorder2   = Color(0xFFCDD4EC);
  static const lText      = Color(0xFF0C1230);
  static const lTextSub   = Color(0xFF4D5A7C);
  static const lTextMuted = Color(0xFF9AA5C2);

  static const dBg        = Color(0xFF070B17);
  static const dSurface   = Color(0xFF0C1020);
  static const dSurface2  = Color(0xFF121828);
  static const dBorder    = Color(0xFF1A2236);
  static const dBorder2   = Color(0xFF222E46);
  static const dText      = Color(0xFFECF0FF);
  static const dTextSub   = Color(0xFF8494B8);
  static const dTextMuted = Color(0xFF48556E);

  static const accent     = Color(0xFF4F6EF7);
  static const accentDeep = Color(0xFF3451D1);
  static const green      = Color(0xFF22C55E);
  static const amber      = Color(0xFFF59E0B);
  static const red        = Color(0xFFEF4444);
  static const purple     = Color(0xFFA78BFA);

  static Color bg(bool d)        => d ? dBg       : lBg;
  static Color surface(bool d)   => d ? dSurface  : lSurface;
  static Color surface2(bool d)  => d ? dSurface2 : lSurface2;
  static Color border(bool d)    => d ? dBorder   : lBorder;
  static Color border2(bool d)   => d ? dBorder2  : lBorder2;
  static Color text(bool d)      => d ? dText     : lText;
  static Color textSub(bool d)   => d ? dTextSub  : lTextSub;
  static Color textMuted(bool d) => d ? dTextMuted: lTextMuted;
}

// ─────────────────────────────────────────────
//  SENTENCE BUILDER
// ─────────────────────────────────────────────
class SentenceBuilder {
  static const Map<String, String> _wordMap = {
    'I': 'I', 'Me': 'I', 'You': 'you', 'He': 'he', 'She': 'she',
    'We': 'we', 'They': 'they',
    'Water': 'water', 'Food': 'food', 'Help': 'help',
    'Medicine': 'medicine', 'Toilet': 'bathroom', 'Sleep': 'sleep',
    'Rest': 'rest', 'Doctor': 'doctor',
    'Need': 'need', 'Want': 'want', 'Go': 'go to', 'Come': 'come',
    'Stop': 'stop', 'Like': 'like', 'Love': 'love', 'Eat': 'eat',
    'Drink': 'drink', 'Call': 'call', 'See': 'see',
    'Understand': 'understand', 'Know': 'know',
    'Pain': 'in pain', 'Sick': 'sick', 'Happy': 'happy', 'Sad': 'sad',
    'Tired': 'tired', 'Hungry': 'hungry', 'Thirsty': 'thirsty',
    'Cold': 'cold', 'Hot': 'hot', 'Okay': 'okay',
    'Yes': 'yes', 'No': 'no', 'Please': 'please',
    'Thank You': 'thank you', 'Sorry': 'sorry',
    'Hello': 'hello', 'Goodbye': 'goodbye',
    'More': 'more', 'Less': 'less', 'Here': 'here', 'There': 'there',
    'Home': 'home', 'Hospital': 'hospital',
    'Phone': 'phone', 'Family': 'family',
    'Friend': 'friend', 'Money': 'money', 'Time': 'time',
  };
  static const _drinkables = {'water','juice','milk','tea','coffee'};
  static const _eatables   = {'food','rice','bread','fruits'};
  static const _needables  = {
    'medicine','doctor','help','phone','money','bathroom',
    'rest','sleep','family','friend','ambulance','blanket',
  };
  static const _places     = {'home','hospital','bathroom','here','there','school','work'};
  static const _callables  = {'doctor','family','friend','phone','police'};
  static const _subjects   = {'i','you','he','she','we','they'};
  static const _noArticle  = {'help','water','food','medicine','rest','sleep','money','time'};
  static const _states     = {
    'sick','tired','hungry','thirsty','cold','hot','okay','happy','sad','in pain',
  };
  static const _verbs      = {
    'need','want','go to','come','stop','understand','know','help','eat','drink',
  };

  static String buildFromGestures(List<String> g) {
    if (g.isEmpty) return '';
    final w = g.map((x) => _wordMap[x] ?? x.toLowerCase()).toList();
    if (w.length == 3 && _subjects.contains(w[0].toLowerCase())) {
      if (['need','want','like','eat','drink','call','love','see'].contains(w[1]))
        return _cap('${w[0]} ${w[1]} ${w[2]}.');
      if (w[1] == 'go to') return _cap('${w[0]} need to go to ${w[2]}.');
    }
    if (w.length == 2 && _subjects.contains(w[0].toLowerCase())) {
      if (!_states.contains(w[1]) && !_verbs.contains(w[1]))
        return _infer(w[0], w[1]);
      if (_states.contains(w[1])) return _cap('${w[0]} am ${w[1]}.');
      return _cap('${w[0]} ${w[1]}.');
    }
    if (w.length == 1) return _single(w[0]);
    if (w[0] == 'please' && w.length >= 2) return _cap('${w.sublist(1).join(' ')}, please.');
    if (w[0] == 'yes' && w.length == 2) return _cap('Yes, ${w[1]}.');
    if (w[0] == 'no'  && w.length == 2) return _cap('No, ${w[1]}.');
    return _cap('${w.join(' ')}.');
  }

  static String _infer(String subj, String noun) {
    final v3 = (subj == 'he' || subj == 'she') ? 'needs' : 'need';
    if (_drinkables.contains(noun)) return _cap('$subj $v3 some $noun.');
    if (_eatables.contains(noun))   return _cap('$subj $v3 some $noun.');
    if (_needables.contains(noun)) {
      final art = _noArticle.contains(noun) ? '' : 'a ';
      return _cap('$subj $v3 $art$noun.');
    }
    if (_places.contains(noun))    return _cap('$subj $v3 to go to $noun.');
    if (_callables.contains(noun)) return _cap('$subj $v3 to call $noun.');
    return _cap('$subj $v3 $noun.');
  }

  static String _single(String w) {
    const m = {
      'help':'I need help.', 'water':'I need water.', 'food':'I need food.',
      'doctor':'I need a doctor.', 'stop':'Please stop.',
      'yes':'Yes.', 'no':'No.', 'please':'Please.',
      'thank you':'Thank you.', 'sorry':'I am sorry.',
      'hello':'Hello!', 'goodbye':'Goodbye!', 'okay':'I am okay.',
      'in pain':'I am in pain.', 'sick':'I am sick.',
      'hungry':'I am hungry.', 'thirsty':'I am thirsty.',
      'tired':'I am tired.', 'cold':'I am feeling cold.',
      'hot':'I am feeling hot.', 'phone':'I need my phone.',
      'family':'I need my family.', 'bathroom':'I need the bathroom.',
      'medicine':'I need medicine.', 'more':'I need more.',
    };
    return m[w] ?? _cap('$w.');
  }

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
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
//  ONBOARDING FLOW  (3 s loader → 5-step guide)
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
  int _phase = 0; // 0 = loader, 1 = steps
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
    (
      icon: Icons.center_focus_strong_rounded,
      color: Color(0xFF4F6EF7),
      title: 'Position Yourself',
      body: 'Stand or sit so your upper body and hands are clearly visible. Keep 1–2 feet away from the camera for best detection accuracy.',
    ),
    (
      icon: Icons.back_hand_rounded,
      color: Color(0xFF22C55E),
      title: 'Hold Each Gesture',
      body: 'Hold each hand sign steady for at least 2 seconds. If a sign is missed, hold it for up to 5 seconds and the system will re-attempt detection.',
    ),
    (
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFF59E0B),
      title: 'Ensure Good Lighting',
      body: 'Make sure your hands are well lit. Avoid strong backlighting or shadows. Natural overhead light gives the best recognition results.',
    ),
    (
      icon: Icons.auto_fix_high_rounded,
      color: Color(0xFFA78BFA),
      title: 'Sentence Builder',
      body: 'Signs above 85% confidence are auto-chained into sentences. Tap "Add Sign" to add manually. Press "Save to Transcript" when done.',
    ),
    (
      icon: Icons.translate_rounded,
      color: Color(0xFFEF4444),
      title: 'Live Translation',
      body: 'Every detected sign is instantly translated to your chosen regional language. You can change the language anytime during a live session.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loaderCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _loaderAnim = CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeInOut);

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _dialogCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _dialogScale = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOutBack));
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
    if (_stepIndex < _steps.length - 1)
      setState(() => _stepIndex++);
    else
      widget.onComplete();
  }

  void _prev() { if (_stepIndex > 0) setState(() => _stepIndex--); }

  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    return Material(
      color: _C.bg(d),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: _phase == 0 ? _loader(d) : _steps_dialog(d),
      ),
    );
  }

  // ── Loader ──────────────────────────────────
  Widget _loader(bool d) => Stack(children: [
    Positioned.fill(child: _GridBg(isDark: d)),
    Positioned(top: -150, left: -100,
      child: _Glow(color: _C.accent.withOpacity(d ? 0.09 : 0.06), size: 540)),
    Positioned(bottom: -100, right: -80,
      child: _Glow(color: _C.purple.withOpacity(d ? 0.06 : 0.04), size: 400)),
    Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Spinning ring logo
      SizedBox(width: 100, height: 100,
        child: AnimatedBuilder(animation: _loaderAnim, builder: (_, __) =>
          CustomPaint(painter: _RingPainter(
            progress: _loaderAnim.value, isDark: d)))),
      const SizedBox(height: 32),
      Text('VANI', style: TextStyle(
        fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 12,
        color: _C.text(d))),
      const SizedBox(height: 6),
      Text('Sign Language Translator', style: TextStyle(
        fontSize: 12, color: _C.textSub(d), letterSpacing: 3,
        fontWeight: FontWeight.w500)),
      const SizedBox(height: 52),
      SizedBox(width: 210, child: Column(children: [
        AnimatedBuilder(animation: _loaderAnim, builder: (_, __) =>
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _loaderAnim.value, minHeight: 3,
              backgroundColor: _C.border(d),
              valueColor: const AlwaysStoppedAnimation(_C.accent)))),
        const SizedBox(height: 10),
        AnimatedBuilder(animation: _loaderAnim, builder: (_, __) =>
          Text(_loaderLabel(_loaderAnim.value), style: TextStyle(
            fontSize: 11, color: _C.textMuted(d), letterSpacing: 0.4))),
      ])),
    ])),
  ]);

  String _loaderLabel(double v) {
    if (v < 0.35) return 'Loading camera modules…';
    if (v < 0.70) return 'Initialising AI engine…';
    return 'Calibrating gesture model…';
  }

  // ── Steps dialog ─────────────────────────────
  Widget _steps_dialog(bool d) {
    final step = _steps[_stepIndex];
    final isLast = _stepIndex == _steps.length - 1;
    return Stack(children: [
      Positioned.fill(child: _GridBg(isDark: d)),
      Positioned(top: -150, left: -100,
        child: _Glow(color: _C.accent.withOpacity(d ? 0.07 : 0.05), size: 520)),
      Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ScaleTransition(scale: _dialogScale,
          child: FadeTransition(opacity: _dialogFade,
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
                // Gradient top strip
                Container(height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [step.color, _C.accent],
                      stops: const [0.0, 1.0]),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)))),
                Padding(padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                  child: Column(children: [
                    // "HOW TO USE" + counter
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _C.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text('HOW TO USE', style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w800,
                          color: _C.accent, letterSpacing: 2))),
                      const Spacer(),
                      Text('${_stepIndex + 1} / ${_steps.length}',
                        style: TextStyle(fontSize: 11,
                          color: _C.textMuted(d), fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 28),
                    // Icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: Container(
                        key: ValueKey(_stepIndex),
                        width: 74, height: 74,
                        decoration: BoxDecoration(
                          color: step.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: step.color.withOpacity(0.28), width: 2)),
                        child: Icon(step.icon, color: step.color, size: 32))),
                    const SizedBox(height: 20),
                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(step.title,
                        key: ValueKey('t$_stepIndex'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                          color: _C.text(d), letterSpacing: -0.3))),
                    const SizedBox(height: 10),
                    // Body
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(step.body,
                        key: ValueKey('b$_stepIndex'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: _C.textSub(d),
                          height: 1.65))),
                    const SizedBox(height: 28),
                    // Dots
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) {
                        final active = i == _stepIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 22 : 6, height: 6,
                          decoration: BoxDecoration(
                            color: active ? _C.accent : _C.border2(d),
                            borderRadius: BorderRadius.circular(3)));
                      })),
                    const SizedBox(height: 26),
                    // Buttons
                    Row(children: [
                      if (_stepIndex > 0) ...[
                        Expanded(child: _OBtn(
                          label: 'Back', icon: Icons.arrow_back_rounded,
                          isDark: d, onTap: _prev)),
                        const SizedBox(width: 12),
                      ],
                      Expanded(flex: 2, child: _PBtn(
                        label: isLast ? "Let's Begin" : 'Next',
                        icon: isLast
                          ? Icons.play_arrow_rounded
                          : Icons.arrow_forward_rounded,
                        isDark: d, onTap: _next)),
                    ]),
                    if (!isLast) ...[
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: widget.onComplete,
                        child: Text('Skip tutorial', style: TextStyle(
                          fontSize: 12, color: _C.textMuted(d),
                          decoration: TextDecoration.underline,
                          decorationColor: _C.textMuted(d)))),
                    ],
                  ])),
              ]),
            ))),
      )),
    ]);
  }
}

// ── Small button helpers for onboarding ──────
class _PBtn extends StatelessWidget {
  final String label; final IconData icon;
  final bool isDark; final VoidCallback onTap;
  const _PBtn({required this.label, required this.icon,
    required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _C.accent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: _C.accent.withOpacity(0.38),
          blurRadius: 22, offset: const Offset(0, 7))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(width: 6),
        Icon(icon, size: 16, color: Colors.white),
      ])));
}

class _OBtn extends StatelessWidget {
  final String label; final IconData icon;
  final bool isDark; final VoidCallback onTap;
  const _OBtn({required this.label, required this.icon,
    required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border2(isDark), width: 1.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: _C.textSub(isDark)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
          color: _C.textSub(isDark))),
      ])));
}

// ─────────────────────────────────────────────
//  RING PAINTER  (loader logo)
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _RingPainter({required this.progress, required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    canvas.drawCircle(c, r, Paint()..color = _C.accent.withOpacity(0.08));
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..color = _C.accent..strokeWidth = 3
        ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    // Inner pulse
    if (progress > 0.05) {
      canvas.drawCircle(c, r - 12,
        Paint()..color = _C.accent.withOpacity(0.08 * progress));
    }
    // Hand silhouette
    final p = Paint()
      ..color = _C.accent.withOpacity(0.3 + 0.65 * progress)
      ..style = PaintingStyle.fill;
    final cx = c.dx; final cy = c.dy;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 9), width: 28, height: 18),
      const Radius.circular(6)), p);
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15 + i * 10.0, cy - 12, 7, 20),
        const Radius.circular(4)), p);
    }
  }
  @override bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────
//  TRANSLATE SCREEN
// ─────────────────────────────────────────────
class TranslateScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const TranslateScreen({
    super.key, required this.toggleTheme, required this.setLocale});

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
  double _conf = 0.0;
  int _frameCount = 0;

  // Translation
  String _selectedLang = 'Hindi';
  String _regionalLabel = '';
  final Map<String, String> _langCodes = {
    'Hindi':'hi','Marathi':'mr','Gujarati':'gu',
    'Tamil':'ta','Telugu':'te','Kannada':'kn','Bengali':'bn',
  };

  // Sentence builder
  final List<_GestureToken> _tokens = [];
  String _sentence = '';
  String _sentenceRegional = '';
  String _lastLabel = '';
  DateTime _lastAt = DateTime(0);
  static const _kAutoThreshold = 0.85;
  static const _kCooldownMs    = 2000;

  // Frame
  Timer? _frameTimer;
  bool _isCapturing = false;

  // Transcript
  final TextEditingController _transcriptCtrl = TextEditingController();

  // Reconnect
  int _reconnects = 0;
  static const _kMaxReconnect = 5;
  Timer? _reconnectTimer;

  // Pulse anim
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
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if ((s == AppLifecycleState.inactive || s == AppLifecycleState.paused)
        && _state == _SessionState.running) _stopSession();
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
      _camCtrl = CameraController(_cameras![_camIndex],
        ResolutionPreset.medium, enableAudio: false,
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
      if (!kIsWeb && c != null && c.value.isInitialized
          && c.value.isStreamingImages) await c.stopImageStream();
      await c?.dispose();
    } catch (_) {}
  }

  Future<bool> _connectWs() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_getWebSocketUrl()));
      await _channel!.ready.timeout(const Duration(seconds: 3));
      _wsConnected = true; _reconnects = 0;
      _wsSub = _channel!.stream.listen(_onMsg,
        onError: _onErr, onDone: _onDone, cancelOnError: false);
      return true;
    } catch (_) { _wsConnected = false; return false; }
  }

  void _onMsg(dynamic raw) {
    if (!mounted) return;
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String? ?? 'prediction';
      if (type == 'ping') { _channel?.sink.add('__PING__'); return; }
      if (type == 'error' && mounted) {
        setState(() {
          _state = _SessionState.error;
          _sessionError = data['message'] as String? ?? 'Error';
        });
        return;
      }
      if (type == 'prediction') {
        final lbl  = (data['label'] ?? '—').toString();
        final conf = (data['confidence'] ?? 0.0).toDouble();
        setState(() { _label = lbl; _conf = conf;
          _frameCount = data['frame'] ?? _frameCount; });
        _maybeAutoAdd(lbl, conf);
        _translate(lbl, _langCodes[_selectedLang]!).then((t) {
          if (mounted) setState(() => _regionalLabel = t);
        });
      }
    } catch (_) {}
  }

  void _onErr(Object _) { _wsConnected = false;
    if (_state == _SessionState.running) _tryReconnect(); }
  void _onDone()        { _wsConnected = false;
    if (_state == _SessionState.running) _tryReconnect(); }

  void _tryReconnect() {
    if (_reconnects >= _kMaxReconnect) {
      if (mounted) setState(() {
        _state = _SessionState.error;
        _sessionError = 'Connection lost. Please restart.';
      });
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
    _frameTimer = Timer.periodic(
      Duration(milliseconds: _kFrameIntervalMs), (_) => _captureAndSend());
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

  void _stopFrameTimer() {
    _frameTimer?.cancel(); _frameTimer = null; _isCapturing = false;
  }

  Future<void> _startSession() async {
    if (_state != _SessionState.idle && _state != _SessionState.error) return;
    setState(() { _state = _SessionState.connecting;
      _sessionError = null; _label = '—'; _conf = 0; _frameCount = 0; });
    if (!await _initCamera()) {
      setState(() { _state = _SessionState.error;
        _sessionError = 'Camera unavailable'; }); return;
    }
    if (!await _connectWs()) {
      await _disposeCamera();
      setState(() { _state = _SessionState.error;
        _sessionError = 'Cannot connect to inference server.\nEnsure backend is running.'; });
      return;
    }
    _startFrameTimer();
    setState(() => _state = _SessionState.running);
  }

  Future<void> _stopSession() async {
    if (_state == _SessionState.idle || _state == _SessionState.stopping) return;
    setState(() => _state = _SessionState.stopping);
    _stopFrameTimer(); await _closeWs(); await _disposeCamera();
    if (!mounted) return;
    setState(() { _state = _SessionState.idle;
      _label = '—'; _conf = 0; _isCameraReady = false; });
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    final was = _state == _SessionState.running;
    if (was) await _stopSession();
    _camIndex = (_camIndex + 1) % _cameras!.length;
    if (was) await _startSession();
  }

  void _maybeAutoAdd(String lbl, double conf) {
    if (lbl == '—' || lbl == 'No Sign' || lbl.isEmpty) return;
    if (conf < _kAutoThreshold) return;
    final now = DateTime.now();
    if (lbl == _lastLabel
        && now.difference(_lastAt).inMilliseconds < _kCooldownMs) return;
    _addToken(lbl, conf);
  }

  void _addToken(String lbl, double conf) {
    if (lbl == '—' || lbl.isEmpty) return;
    setState(() { _tokens.add(_GestureToken(label: lbl, confidence: conf));
      _lastLabel = lbl; _lastAt = DateTime.now(); _rebuildSentence(); });
  }

  void _addCurrentManually() {
    if (_label == '—' || _label.isEmpty) return;
    _addToken(_label, _conf);
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
    _sentence = SentenceBuilder.buildFromGestures(
      _tokens.map((t) => t.label).toList());
    if (_sentence.isNotEmpty) {
      _translate(_sentence, _langCodes[_selectedLang]!).then((t) {
        if (mounted) setState(() => _sentenceRegional = t);
      });
    } else { _sentenceRegional = ''; }
  }

  void _commitToTranscript() {
    if (_sentence.isEmpty) return;
    final t = _transcriptCtrl.text;
    _transcriptCtrl.text = t.isEmpty ? _sentence : '$t\n$_sentence';
    _transcriptCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _transcriptCtrl.text.length));
    _clearBuilder();
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_rounded, color: _C.green, size: 15),
        const SizedBox(width: 8),
        const Text('Copied to clipboard',
          style: TextStyle(fontSize: 13, color: Colors.white)),
      ]),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1A2236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _stopSession();
    _transcriptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;

    if (!_onboardingDone) {
      return _OnboardingFlow(
        isDark: d,
        onComplete: () { if (mounted) setState(() => _onboardingDone = true); });
    }

    return Scaffold(
      backgroundColor: _C.bg(d),
      body: Stack(children: [
        Positioned.fill(child: _GridBg(isDark: d)),
        Positioned(top: -180, left: -110,
          child: _Glow(color: _C.accent.withOpacity(d ? 0.07 : 0.04), size: 580)),
        Positioned(bottom: -90, right: -90,
          child: _Glow(color: _C.green.withOpacity(d ? 0.04 : 0.025), size: 400)),
        SafeArea(child: Column(children: [
          GlobalNavbar(toggleTheme: widget.toggleTheme,
            setLocale: widget.setLocale, activeRoute: 'translate'),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: isWide ? _wideLayout(d) : _narrowLayout(d))),
        ])),
      ]),
    );
  }

  Widget _wideLayout(bool d) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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

  // ── Camera section ───────────────────────────
  Widget _cameraSection(bool d) {
    final l = AppLocalizations.of(context);
    final isRunning = _state == _SessionState.running;
    return _Card(isDark: d, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _Badge(icon: Icons.sensors_rounded, color: _C.accent, isDark: d),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.t('translate_vision_title'), style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: _C.text(d))),
              const SizedBox(height: 2),
              Text(l.t('translate_vision_sub'), style: TextStyle(
                fontSize: 12, color: _C.textSub(d))),
            ])),
          _StatusChip(state: _state, isDark: d),
        ]),
        const SizedBox(height: 18),
        // Viewport
        AspectRatio(aspectRatio: 16 / 10,
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
                else _CamPlaceholder(isDark: d),
                if (isRunning) IgnorePointer(child: CustomPaint(
                  painter: _ScanlinePainter(color: _C.accent))),
                if (isRunning) Positioned(top: 12, left: 12,
                  child: _LiveBadge(pulse: _pulseAnim)),
                if (isRunning && _conf > 0)
                  Positioned(bottom: 12, left: 12, right: 12,
                    child: _ConfBanner(label: _label, confidence: _conf)),
                if (_state == _SessionState.connecting) _ConnectingOverlay(),
                if (_state == _SessionState.error)      const _ErrorOverlay(),
              ])))),
        const SizedBox(height: 16),
        Row(children: [
          _OutlineBtn(icon: Icons.flip_camera_android_rounded,
            label: l.t('translate_switch'), isDark: d, onTap: _switchCamera),
          const SizedBox(width: 12),
          Expanded(child: _SessionBtn(state: _state, isDark: d,
            onStart: _startSession, onStop: _stopSession)),
        ]),
        if (_state == _SessionState.error && _sessionError != null) ...[
          const SizedBox(height: 12),
          _ErrBanner(message: _sessionError!, isDark: d),
        ],
      ]));
  }

  // ── Detection section ─────────────────────────
  Widget _detectionSection(bool d) {
    final l = AppLocalizations.of(context);
    final isActive = _state == _SessionState.running;
    return _Card(isDark: d, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _Badge(icon: Icons.translate_rounded, color: _C.green, isDark: d),
          const SizedBox(width: 12),
          Expanded(child: Text(l.t('translate_prediction'), style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, color: _C.text(d)))),
          _LangSelector(value: _selectedLang,
            options: _langCodes.keys.toList(), isDark: d,
            onChanged: (v) { if (v != null) setState(() => _selectedLang = v); }),
        ]),
        const SizedBox(height: 16),
        _DetCard(code: 'EN', color: _C.accent, isDark: d,
          text: isActive ? _label : l.t('translate_waiting'),
          isActive: isActive),
        const SizedBox(height: 10),
        _DetCard(
          code: _selectedLang.substring(0, 2).toUpperCase(),
          color: _C.green, isDark: d,
          text: isActive
            ? (_regionalLabel.isNotEmpty ? _regionalLabel : '…')
            : l.t('translate_waiting'),
          isActive: isActive),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('CONFIDENCE', style: TextStyle(fontSize: 9,
            fontWeight: FontWeight.w800, color: _C.textMuted(d),
            letterSpacing: 1.6)),
          Text(isActive ? '${(_conf * 100).toStringAsFixed(0)}%' : '—',
            style: TextStyle(fontSize: 11, color: _C.textSub(d),
              fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        _ConfBar(value: isActive ? _conf : 0),
        if (isActive) ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Frames: $_frameCount', style: TextStyle(
              fontSize: 10, color: _C.textMuted(d))),
            if (_conf >= _kAutoThreshold)
              Row(children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: _C.green)),
                const SizedBox(width: 5),
                const Text('Auto-adding', style: TextStyle(
                  fontSize: 10, color: _C.green, fontWeight: FontWeight.w700)),
              ]),
          ]),
        ],
      ]));
  }

  // ── Sentence builder section ──────────────────
  Widget _sentenceSection(bool d) {
    return _Card(isDark: d,
      gradientAccent: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: d
          ? [_C.purple.withOpacity(0.07), Colors.transparent]
          : [_C.purple.withOpacity(0.04), Colors.transparent]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Badge(icon: Icons.auto_fix_high_rounded,
            color: _C.purple, isDark: d),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sentence Builder', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: _C.text(d))),
              Text('Signs auto-chain into natural language', style: TextStyle(
                fontSize: 11, color: _C.textSub(d))),
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
                const Text('Add Sign', style: TextStyle(color: _C.accent,
                  fontSize: 11, fontWeight: FontWeight.w800)),
              ]))),
        ]),
        const SizedBox(height: 16),
        // Tokens
        if (_tokens.isEmpty)
          _EmptyBuilder(isDark: d)
        else
          Wrap(spacing: 8, runSpacing: 8,
            children: _tokens.asMap().entries.map((e) => _TokenChip(
              index: e.key + 1, token: e.value,
              isLast: e.key == _tokens.length - 1,
              isDark: d,
              onRemove: () => _removeToken(e.key))).toList()),
        // Built sentence
        if (_tokens.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(children: [
            Icon(Icons.subdirectory_arrow_right_rounded,
              size: 13, color: _C.textMuted(d)),
            const SizedBox(width: 6),
            Text('Generated sentence', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: _C.textMuted(d), letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.surface2(d),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.purple.withOpacity(0.28))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _LangTag(code: 'EN', color: _C.purple),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    _sentence.isNotEmpty ? _sentence : '…',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                      color: _C.text(d), height: 1.35))),
                  GestureDetector(onTap: () => _copy(_sentence),
                    child: Padding(padding: const EdgeInsets.all(4),
                      child: Icon(Icons.copy_rounded, size: 15,
                        color: _C.textMuted(d)))),
                ]),
                if (_sentenceRegional.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Divider(color: _C.border(d), height: 1),
                  const SizedBox(height: 10),
                  Row(children: [
                    _LangTag(
                      code: _selectedLang.substring(0, 2).toUpperCase(),
                      color: _C.green),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_sentenceRegional,
                      style: const TextStyle(fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _C.green, height: 1.35))),
                    GestureDetector(onTap: () => _copy(_sentenceRegional),
                      child: Padding(padding: const EdgeInsets.all(4),
                        child: Icon(Icons.copy_rounded, size: 15,
                          color: _C.textMuted(d)))),
                  ]),
                ],
              ])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _FillBtn(label: 'Save to Transcript',
              icon: Icons.save_alt_rounded, color: _C.accent,
              onTap: _commitToTranscript)),
            const SizedBox(width: 10),
            _IconBtn(icon: Icons.backspace_outlined, color: _C.amber,
              tooltip: 'Remove last', onTap: _removeLastToken),
            const SizedBox(width: 8),
            _IconBtn(icon: Icons.delete_sweep_rounded, color: _C.red,
              tooltip: 'Clear all', onTap: _clearBuilder),
          ]),
        ],
      ]));
  }

  // ── Transcript section ────────────────────────
  Widget _transcriptSection(bool d) {
    final l = AppLocalizations.of(context);
    return _Card(isDark: d, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _Badge(icon: Icons.article_rounded, color: _C.amber, isDark: d),
          const SizedBox(width: 12),
          Expanded(child: Text(l.t('translate_transcription'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
              color: _C.text(d)))),
        ]),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: _C.surface2(d),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border(d))),
          child: TextField(
            controller: _transcriptCtrl, maxLines: 5,
            style: TextStyle(fontSize: 14, color: _C.text(d), height: 1.65),
            decoration: InputDecoration(
              hintText: l.t('translate_hint'),
              hintStyle: TextStyle(color: _C.textMuted(d), fontSize: 13),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none))),
        const SizedBox(height: 12),
        Row(children: [
          _IconBtn(icon: Icons.copy_outlined, color: _C.accent,
            tooltip: 'Copy transcript',
            onTap: () => _copy(_transcriptCtrl.text)),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.delete_outline_rounded, color: _C.red,
            tooltip: 'Clear', onTap: _transcriptCtrl.clear),
        ]),
      ]));
  }
}

// ═════════════════════════════════════════════
//  COMPONENTS
// ═════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Gradient? gradientAccent;
  const _Card({required this.child, required this.isDark,
    this.gradientAccent});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _C.surface(isDark),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _C.border(isDark), width: 1.2),
      gradient: gradientAccent,
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
        blurRadius: 28, offset: const Offset(0, 8))]),
    child: child);
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
    child: Icon(icon, color: color, size: 17));
}

class _LangTag extends StatelessWidget {
  final String code; final Color color;
  const _LangTag({required this.code, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6)),
    child: Text(code, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
      color: color, letterSpacing: 1.5)));
}

class _StatusChip extends StatelessWidget {
  final _SessionState state; final bool isDark;
  const _StatusChip({required this.state, required this.isDark});
  @override
  Widget build(BuildContext context) {
    Color c; String lbl;
    switch (state) {
      case _SessionState.running:    c = _C.green; lbl = 'Live'; break;
      case _SessionState.connecting: c = _C.amber; lbl = 'Connecting'; break;
      case _SessionState.error:      c = _C.red;   lbl = 'Error'; break;
      default:                       c = _C.textMuted(isDark); lbl = 'Idle';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.28))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
        const SizedBox(width: 6),
        Text(lbl, style: TextStyle(fontSize: 10, color: c,
          fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      ]));
  }
}

class _LangSelector extends StatelessWidget {
  final String value; final List<String> options;
  final bool isDark; final ValueChanged<String?> onChanged;
  const _LangSelector({required this.value, required this.options,
    required this.isDark, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: _C.surface2(isDark),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.border2(isDark))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, dropdownColor: _C.surface2(isDark),
        style: TextStyle(color: _C.text(isDark),
          fontWeight: FontWeight.w700, fontSize: 12),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: _C.textSub(isDark), size: 16),
        items: options.map((l) =>
          DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: onChanged)));
}

class _DetCard extends StatelessWidget {
  final String code, text; final Color color;
  final bool isDark, isActive;
  const _DetCard({required this.code, required this.text, required this.color,
    required this.isDark, required this.isActive});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: _C.surface2(isDark),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isActive ? color.withOpacity(0.35) : _C.border(isDark))),
    child: Row(children: [
      _LangTag(code: code, color: color),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800,
        color: isActive ? color : _C.textMuted(isDark),
        letterSpacing: -0.3))),
    ]));
}

class _ConfBar extends StatelessWidget {
  final double value;
  const _ConfBar({required this.value});
  @override
  Widget build(BuildContext context) {
    final c = value > 0.75 ? _C.green : value > 0.45 ? _C.amber : _C.accent;
    return ClipRRect(borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(value: value, minHeight: 4,
        backgroundColor: const Color(0x1AFFFFFF),
        valueColor: AlwaysStoppedAnimation<Color>(c)));
  }
}

class _EmptyBuilder extends StatelessWidget {
  final bool isDark;
  const _EmptyBuilder({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 22),
    decoration: BoxDecoration(
      color: _C.surface2(isDark),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.border(isDark))),
    child: Column(children: [
      Icon(Icons.gesture_rounded, color: _C.textMuted(isDark), size: 30),
      const SizedBox(height: 8),
      Text('Perform signs to build a sentence',
        style: TextStyle(color: _C.textSub(isDark), fontSize: 12)),
      const SizedBox(height: 4),
      Text('Signs ≥85% confidence auto-add',
        style: TextStyle(color: _C.textMuted(isDark), fontSize: 11)),
    ]));
}

class _TokenChip extends StatelessWidget {
  final int index; final _GestureToken token;
  final bool isLast, isDark; final VoidCallback onRemove;
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
      Padding(padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$index', style: TextStyle(fontSize: 9,
            color: _C.textMuted(isDark), fontWeight: FontWeight.w700)),
          const SizedBox(width: 5),
          Text(token.label, style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isLast ? _C.purple : _C.text(isDark))),
        ])),
      GestureDetector(onTap: onRemove,
        child: Padding(padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 7),
          child: Icon(Icons.close_rounded, size: 12,
            color: isLast ? _C.purple : _C.textMuted(isDark)))),
    ]));
}

class _FillBtn extends StatelessWidget {
  final String label; final IconData icon;
  final Color color; final VoidCallback onTap;
  const _FillBtn({required this.label, required this.icon,
    required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.28))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(color: color,
          fontSize: 13, fontWeight: FontWeight.w800)),
      ])));
}

class _IconBtn extends StatelessWidget {
  final IconData icon; final Color color;
  final String tooltip; final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color,
    required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(message: tooltip,
    child: GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, color: color, size: 16))));
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon; final String label;
  final bool isDark; final VoidCallback onTap;
  const _OutlineBtn({required this.icon, required this.label,
    required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border2(isDark))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: _C.textSub(isDark)),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(fontSize: 13,
          color: _C.textSub(isDark), fontWeight: FontWeight.w700)),
      ])));
}

class _SessionBtn extends StatelessWidget {
  final _SessionState state; final bool isDark;
  final VoidCallback onStart, onStop;
  const _SessionBtn({required this.state, required this.isDark,
    required this.onStart, required this.onStop});
  @override
  Widget build(BuildContext context) {
    final isRunning = state == _SessionState.running;
    final isLoading = state == _SessionState.connecting
      || state == _SessionState.stopping;
    final isErr = state == _SessionState.error;
    final Color c = isRunning ? _C.red : isErr ? _C.amber : _C.accent;
    final String lbl = isLoading
      ? (state == _SessionState.connecting ? 'Connecting…' : 'Stopping…')
      : isRunning ? 'Stop Session' : isErr ? 'Retry' : 'Start Session';
    final IconData ico = isLoading
      ? Icons.hourglass_empty_rounded
      : isRunning ? Icons.stop_rounded
      : isErr ? Icons.refresh_rounded : Icons.play_arrow_rounded;
    return GestureDetector(
      onTap: isLoading ? null : (isRunning ? onStop : onStart),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (isLoading)
            SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(c)))
          else Icon(ico, color: c, size: 17),
          const SizedBox(width: 8),
          Text(lbl, style: TextStyle(color: c,
            fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
        ])));
  }
}

class _ErrBanner extends StatelessWidget {
  final String message; final bool isDark;
  const _ErrBanner({required this.message, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _C.red.withOpacity(isDark ? 0.1 : 0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.red.withOpacity(0.25))),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: _C.red, size: 15),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(
        color: _C.red, fontSize: 12, fontWeight: FontWeight.w500))),
    ]));
}

class _CamPlaceholder extends StatelessWidget {
  final bool isDark;
  const _CamPlaceholder({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child:
    Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.08))),
        child: Icon(Icons.videocam_off_rounded,
          color: Colors.white.withOpacity(0.22), size: 36)),
      const SizedBox(height: 14),
      Text('Press Start Session to begin',
        style: TextStyle(
          color: Colors.white.withOpacity(0.28), fontSize: 13)),
    ]));
}

class _ConnectingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.black54,
    child: const Center(child: Column(mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_C.accent), strokeWidth: 2),
        SizedBox(height: 14),
        Text('Establishing connection…', style: TextStyle(
          color: _C.accent, fontWeight: FontWeight.w700, fontSize: 13)),
      ])));
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay();
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.7),
    child: const Center(child: Column(mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_amber_rounded, color: _C.red, size: 34),
        SizedBox(height: 10),
        Text('Connection Error', style: TextStyle(
          color: Colors.white70, fontWeight: FontWeight.w800)),
      ])));
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
        color: _C.red.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
          color: _C.red.withOpacity(0.45 * pulse.value),
          blurRadius: 14, spreadRadius: 1)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Colors.white)),
        const SizedBox(width: 6),
        const Text('LIVE', style: TextStyle(color: Colors.white,
          fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.8)),
      ])));
}

class _ConfBanner extends StatelessWidget {
  final String label; final double confidence;
  const _ConfBanner({required this.label, required this.confidence});
  @override
  Widget build(BuildContext context) {
    if (label == '—' || label.isEmpty) return const SizedBox.shrink();
    final c = confidence > 0.75 ? _C.green : _C.amber;
    return ClipRRect(borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.07))),
          child: Row(children: [
            Expanded(child: Text(label, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
              child: Text('${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: c, fontSize: 11,
                  fontWeight: FontWeight.w800))),
          ]))));
  }
}

// ─────────────────────────────────────────────
//  BACKGROUND UTILITIES
// ─────────────────────────────────────────────
class _GridBg extends StatelessWidget {
  final bool isDark;
  const _GridBg({required this.isDark});
  @override
  Widget build(BuildContext context) =>
    CustomPaint(painter: _GridPainter(isDark: isDark));
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
      child: const SizedBox.expand()));
}

class _ScanlinePainter extends CustomPainter {
  final Color color;
  _ScanlinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final sl = Paint()
      ..color = Colors.white.withOpacity(0.018)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), sl);
    final bp = Paint()
      ..color = color.withOpacity(0.6)..strokeWidth = 2
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const l = 22.0; const m = 14.0;
    canvas.drawPath(Path()..moveTo(m, m+l)..lineTo(m,m)..lineTo(m+l,m), bp);
    canvas.drawPath(Path()..moveTo(size.width-m-l,m)
      ..lineTo(size.width-m,m)..lineTo(size.width-m,m+l), bp);
    canvas.drawPath(Path()..moveTo(m,size.height-m-l)
      ..lineTo(m,size.height-m)..lineTo(m+l,size.height-m), bp);
    canvas.drawPath(Path()..moveTo(size.width-m-l,size.height-m)
      ..lineTo(size.width-m,size.height-m)
      ..lineTo(size.width-m,size.height-m-l), bp);
  }
  @override bool shouldRepaint(_) => false;
}