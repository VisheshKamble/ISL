// lib/screens/EmergencyScreen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/GlobalNavbar.dart';
import '../l10n/AppLocalizations.dart';
import '../services/EmergencyService.dart';
import '../utils/PlatformHelper.dart';
import 'EmergencySetupScreen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _kCrimson     = Color(0xFFDC2626);
const _kCrimsonSoft = Color(0xFFEF4444);
const _kViolet      = Color(0xFF7C3AED);
const _kVioletLight = Color(0xFFA78BFA);
const _kAmber       = Color(0xFFD97706);
const _kAmberSoft   = Color(0xFFFBBF24);
const _kBlue        = Color(0xFF0284C7);
const _kBlueSoft    = Color(0xFF38BDF8);
const _kGreen       = Color(0xFF059669);
const _kGreenLight  = Color(0xFF34D399);
const _kOrange      = Color(0xFFEA580C);
const _kOrangeSoft  = Color(0xFFFB923C);
const _kPurple      = Color(0xFF7E22CE);
const _kPurpleSoft  = Color(0xFFC084FC);
const _kTeal        = Color(0xFF0F766E);
const _kTealSoft    = Color(0xFF2DD4BF);

class _T {
  final bool d;
  const _T(this.d);
  Color get scaffold  => d ? const Color(0xFF030307) : const Color(0xFFF4F5FD);
  Color get surface   => d ? const Color(0xFF09091A) : Colors.white;
  Color get surfaceUp => d ? const Color(0xFF0E0E1E) : const Color(0xFFF7F7FC);
  Color get surfaceHi => d ? const Color(0xFF141428) : const Color(0xFFEEEEF8);
  Color get border    => d ? const Color(0xFF1A1A2E) : const Color(0xFFE2E2F2);
  Color get borderBrt => d ? const Color(0xFF252540) : const Color(0xFFCCCCDE);
  Color get textPri   => d ? const Color(0xFFF2F0FF) : const Color(0xFF080820);
  Color get textSec   => d ? const Color(0xFF6060A0) : const Color(0xFF606080);
  Color get textMuted => d ? const Color(0xFF282848) : const Color(0xFFB8B8D0);
  Color get gridLine  => d
      ? const Color(0xFF10102A).withOpacity(0.5)
      : const Color(0xFFE0E0F0).withOpacity(0.7);
}

// ─────────────────────────────────────────────
//  SCENARIO DATA MODEL
//  No emojis — using Material icons throughout.
// ─────────────────────────────────────────────
class _Scenario {
  final SOSMessageType type;
  final IconData icon;
  final String title;
  final String subtitle;
  final String signHint;       // ISL sign that triggers this
  final Color  color;
  final Color  soft;
  final String smsTemplate;    // contains {LOCATION} and {TIME}
  final String helpline;
  final String helplineName;

  const _Scenario({
    required this.type, required this.icon,
    required this.title, required this.subtitle,
    required this.signHint,
    required this.color, required this.soft,
    required this.smsTemplate,
    required this.helpline, required this.helplineName,
  });
}

// Professional, multilingual-ready SMS templates.
// No emojis — plain text is more compatible across SMS carriers and
// is readable in assistive contexts (screen readers, feature phones).
const List<_Scenario> _kScenarios = [
  _Scenario(
    type: SOSMessageType.generalHelp,
    icon: Icons.emergency_rounded,
    title: 'I Need Help',
    subtitle: 'General distress — immediate assistance needed',
    signHint: 'ISL: HELP',
    color: _kCrimson, soft: _kCrimsonSoft,
    helpline: '112', helplineName: 'National Emergency',
    smsTemplate:
    'URGENT — EMERGENCY ALERT\n\n'
        'This alert was sent by the VANI sign-language assistance app.\n\n'
        'The sender is DEAF or MUTE and cannot speak or call for help. '
        'They need your immediate assistance.\n\n'
        'Actions required:\n'
        '  1. Call them back.\n'
        '  2. Go to their current location.\n'
        '  3. Contact emergency services (dial 112) on their behalf.\n\n'
        'Location: {LOCATION}\n'
        'Time: {TIME}\n\n'
        '— Sent automatically via VANI Emergency SOS',
  ),
  _Scenario(
    type: SOSMessageType.medical,
    icon: Icons.medical_services_rounded,
    title: 'Medical Emergency',
    subtitle: 'Injury, seizure, chest pain, or acute illness',
    signHint: 'ISL: BANDAID / DOCTOR',
    color: _kOrange, soft: _kOrangeSoft,
    helpline: '108', helplineName: 'Ambulance',
    smsTemplate:
    'URGENT — MEDICAL EMERGENCY\n\n'
        'This alert was sent by the VANI sign-language assistance app.\n\n'
        'The sender is DEAF or MUTE and is experiencing a medical emergency. '
        'They cannot call for help verbally.\n\n'
        'Actions required:\n'
        '  1. Call an ambulance — dial 108.\n'
        '  2. Go to their location immediately.\n'
        '  3. Contact a nearby doctor or hospital.\n\n'
        'Location: {LOCATION}\n'
        'Time: {TIME}\n\n'
        '— Sent automatically via VANI Emergency SOS',
  ),
  _Scenario(
    type: SOSMessageType.police,
    icon: Icons.shield_rounded,
    title: 'I Feel Unsafe',
    subtitle: 'Threat, harassment, assault, or danger',
    signHint: 'ISL: STRONG / QUIET',
    color: _kBlue, soft: _kBlueSoft,
    helpline: '100', helplineName: 'Police',
    smsTemplate:
    'URGENT — SAFETY EMERGENCY\n\n'
        'This alert was sent by the VANI sign-language assistance app.\n\n'
        'The sender is DEAF or MUTE and is in a dangerous situation. '
        'They cannot call the police verbally.\n\n'
        'Actions required:\n'
        '  1. Call the police — dial 100.\n'
        '  2. Go to their location immediately.\n'
        '  3. Alert someone nearby to assist them.\n\n'
        'Location: {LOCATION}\n'
        'Time: {TIME}\n\n'
        '— Sent automatically via VANI Emergency SOS',
  ),
  _Scenario(
    type: SOSMessageType.fire,
    icon: Icons.local_fire_department_rounded,
    title: 'Fire or Smoke',
    subtitle: 'Fire, gas leak, or smoke emergency',
    signHint: 'ISL: BAD / HELP',
    color: _kAmber, soft: _kAmberSoft,
    helpline: '101', helplineName: 'Fire Brigade',
    smsTemplate:
    'URGENT — FIRE / SMOKE EMERGENCY\n\n'
        'This alert was sent by the VANI sign-language assistance app.\n\n'
        'The sender is DEAF or MUTE and is reporting a fire or smoke emergency. '
        'They cannot call the fire brigade verbally.\n\n'
        'Actions required:\n'
        '  1. Call the fire brigade — dial 101.\n'
        '  2. Ensure evacuation of the building.\n'
        '  3. Alert people near this location.\n\n'
        'Location: {LOCATION}\n'
        'Time: {TIME}\n\n'
        '— Sent automatically via VANI Emergency SOS',
  ),
  _Scenario(
    type: SOSMessageType.custom,
    icon: Icons.directions_car_rounded,
    title: 'Road Accident',
    subtitle: 'Vehicle accident — injuries possible',
    signHint: 'ISL: BAD + SORRY',
    color: _kPurple, soft: _kPurpleSoft,
    helpline: '1033', helplineName: 'Highway Helpline',
    smsTemplate:
    'URGENT — ROAD ACCIDENT\n\n'
        'This alert was sent by the VANI sign-language assistance app.\n\n'
        'The sender is DEAF or MUTE and has been involved in or witnessed a road accident. '
        'They cannot call for help verbally.\n\n'
        'Actions required:\n'
        '  1. Call ambulance — dial 108.\n'
        '  2. Call highway helpline — dial 1033.\n'
        '  3. Go to their location and assist.\n\n'
        'Location: {LOCATION}\n'
        'Time: {TIME}\n\n'
        '— Sent automatically via VANI Emergency SOS',
  ),
  _Scenario(
    type: SOSMessageType.custom,
    icon: Icons.child_care_rounded,
    title: 'Child Safety',
    subtitle: 'Child missing, lost, or in distress',
    signHint: 'ISL: BROTHER / MOTHER',
    color: _kTeal, soft: _kTealSoft,
    helpline: '1098', helplineName: 'Childline',
    smsTemplate:
    'URGENT — CHILD SAFETY ALERT\n\n'
        'This alert was sent by the VANI sign-language assistance app.\n\n'
        'The sender is DEAF or MUTE and is reporting a child safety emergency. '
        'A child may be missing, lost, or in distress. They cannot call verbally.\n\n'
        'Actions required:\n'
        '  1. Call Childline — dial 1098.\n'
        '  2. Call police — dial 100.\n'
        '  3. Go to this location and assist immediately.\n\n'
        'Location: {LOCATION}\n'
        'Time: {TIME}\n\n'
        '— Sent automatically via VANI Emergency SOS',
  ),
];

// ════════════════════════════════════════════
//  EMERGENCY SCREEN
// ════════════════════════════════════════════

class EmergencyScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  final String? detectedSign;

  const EmergencyScreen({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
    this.detectedSign,
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  final _service = EmergencyService.instance;

  bool _isSending = false;
  int? _activeSendIndex;
  String? _statusMsg;
  bool _statusOk = false;
  _Scenario? _autoScenario;

  late AnimationController _ambientCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _ambientAnim;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _service.updateContext(context);

    _ambientCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _ambientAnim = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _pulseAnim   = CurvedAnimation(parent: _pulseCtrl,   curve: Curves.easeInOut);
    _entryFade   = CurvedAnimation(parent: _entryCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut));
    _entrySlide  = Tween<Offset>(
        begin: const Offset(0, 0.02), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.0, 0.75, curve: Curves.easeOut)));

    _entryCtrl.forward();

    if (widget.detectedSign != null) {
      _autoScenario = _matchSign(widget.detectedSign!);
    }
  }

  _Scenario? _matchSign(String sign) {
    final s = sign.toLowerCase();
    if (s.contains('help') || s.contains('sos'))              return _kScenarios[0];
    if (s.contains('doctor') || s.contains('bandaid') ||
        s.contains('pain')   || s.contains('sick'))           return _kScenarios[1];
    if (s.contains('danger') || s.contains('police') ||
        s.contains('strong') || s.contains('quiet'))          return _kScenarios[2];
    if (s.contains('fire')   || s.contains('smoke'))          return _kScenarios[3];
    if (s.contains('accident')|| s.contains('car'))           return _kScenarios[4];
    if (s.contains('child')  || s.contains('brother') ||
        s.contains('mother'))                                  return _kScenarios[5];
    return _kScenarios[0];
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS(int idx) async {
    if (_isSending) return;
    final s = _kScenarios[idx];
    HapticFeedback.heavyImpact();

    setState(() { _isSending = true; _activeSendIndex = idx; _statusMsg = null; });

    final result = await _service.triggerSOS(
      type: s.type,
      customMessage: s.smsTemplate,
    );

    if (mounted) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isSending = false;
        _activeSendIndex = null;
        _statusOk  = result.success;
        _statusMsg = result.success
            ? (PlatformHelper.isMobile
            ? 'Alert dispatched to ${result.sentCount} contact${result.sentCount == 1 ? '' : 's'}. Help is on the way.'
            : 'Contact panel opened. Tap WhatsApp or Call to send your alert.')
            : result.reason;
      });
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) setState(() => _statusMsg = null);
      });
    }
  }

  // ── Build ────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t      = _T(isDark);
    final w      = MediaQuery.of(context).size.width;

    // Hard split: mobile-native below 700, website above
    if (w < 700) return _buildMobile(context, t, isDark);
    return _buildWebsite(context, t, w);
  }

  // ══════════════════════════════════════════════
  //  MOBILE LAYOUT — native app shell
  //  No GlobalNavbar. Back button in compact top bar.
  //  Scenario cards are large thumb-friendly tiles.
  //  Helplines, shake card, contacts btn in a scrollable body.
  // ══════════════════════════════════════════════
  Widget _buildMobile(BuildContext context, _T t, bool isDark) {
    return Scaffold(
      backgroundColor: t.scaffold,
      body: Stack(children: [
        AnimatedBuilder(animation: _ambientAnim, builder: (_, __) => Stack(children: [
          Positioned(top: -100, left: -40,
              child: _Glow(color: _kCrimson.withOpacity(
                  isDark ? 0.08 + _ambientAnim.value * 0.04 : 0.03), size: 300)),
          Positioned(bottom: -80, right: -60,
              child: _Glow(color: _kViolet.withOpacity(
                  isDark ? 0.05 + _ambientAnim.value * 0.03 : 0.015), size: 240)),
        ])),
        Positioned.fill(child: CustomPaint(painter: _GridPainter(t: t))),

        SafeArea(
          child: Column(children: [

            // ── Compact mobile top bar ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(children: [
                // Back
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                            color: t.surfaceUp,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.border)),
                        child: Icon(Icons.arrow_back_rounded, color: t.textSec, size: 18))),
                const SizedBox(width: 12),
                // Title
                Expanded(child: Row(children: [
                  AnimatedBuilder(animation: _pulseAnim, builder: (_, __) =>
                      Container(width: 6, height: 6, decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _kCrimsonSoft,
                          boxShadow: [BoxShadow(
                              color: _kCrimsonSoft.withOpacity(_pulseAnim.value * 0.8),
                              blurRadius: 6, spreadRadius: 1)]))),
                  const SizedBox(width: 8),
                  Text('Emergency SOS', style: TextStyle(
                      color: t.textPri, fontSize: 16, fontWeight: FontWeight.w800)),
                ])),
                // Setup contacts
                GestureDetector(
                    onTap: () => Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, __, ___) => EmergencySetupScreen(
                            toggleTheme: widget.toggleTheme, setLocale: widget.setLocale),
                        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        transitionDuration: const Duration(milliseconds: 260))),
                    child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                            color: t.surfaceUp, shape: BoxShape.circle,
                            border: Border.all(color: t.border)),
                        child: Icon(Icons.contacts_rounded, color: t.textSec, size: 17))),
              ]),
            ),

            // ── Scrollable body ──────────────────
            Expanded(
              child: FadeTransition(
                opacity: _entryFade,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Auto-detected sign banner
                    if (_autoScenario != null) ...[
                      _autoDetectBanner(t), const SizedBox(height: 12)],
                    // Status banner
                    if (_statusMsg != null) ...[
                      _statusBar(t), const SizedBox(height: 12)],
                    // No contacts warning
                    if (!_service.hasContacts) ...[
                      _noContactsBanner(t), const SizedBox(height: 12)],

                    // Section label
                    _MobileSectionLabel(
                        label: 'SELECT EMERGENCY TYPE',
                        sub: 'Tap a card — GPS alert sent instantly',
                        t: t),
                    const SizedBox(height: 12),

                    // 2-column scenario grid (touch-optimised sizing)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10, crossAxisSpacing: 10,
                      childAspectRatio: 1.18,
                      children: _kScenarios.asMap().entries.map((e) => _ScenarioCard(
                        scenario:       e.value,
                        t:              t,
                        pulseAnim:      _pulseAnim,
                        isSending:      _isSending && _activeSendIndex == e.key,
                        isDisabled:     _isSending && _activeSendIndex != e.key,
                        isAutoDetected: _autoScenario == e.value,
                        onTap:          () => _triggerSOS(e.key),
                      )).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Helplines strip
                    _MobileSectionLabel(label: 'HELPLINES', sub: 'Tap to call', t: t),
                    const SizedBox(height: 10),
                    _mobileHelplinesRow(t),

                    const SizedBox(height: 16),

                    // Shake card
                    if (PlatformHelper.supportsShake) ...[
                      _shakeCard(t),
                      const SizedBox(height: 12),
                    ],
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Mobile helplines row (tap-to-call tiles) ──
  Widget _mobileHelplinesRow(_T t) {
    final items = [
      ('112', 'Emergency', _kCrimson),
      ('108', 'Ambulance', _kOrange),
      ('100', 'Police',    _kBlue),
      ('101', 'Fire',      _kAmber),
    ];
    return Row(children: items.map((item) {
      final isLast = item == items.last;
      return Expanded(child: GestureDetector(
          onTap: () {},
          child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: item.$3.withOpacity(t.d ? 0.07 : 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.$3.withOpacity(0.20))),
              child: Column(children: [
                Text(item.$1, style: TextStyle(
                    color: item.$3, fontSize: 18,
                    fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text(item.$2, style: TextStyle(
                    color: t.textSec, fontSize: 9, fontWeight: FontWeight.w600)),
              ]))));
    }).toList());
  }

  // ══════════════════════════════════════════════
  //  WEBSITE LAYOUT (≥ 700px) — unchanged
  // ══════════════════════════════════════════════
  Widget _buildWebsite(BuildContext context, _T t, double w) {
    final isDesktop = w > 1100;
    final hPad = isDesktop ? 96.0 : 48.0;

    return Scaffold(
      backgroundColor: t.scaffold,
      body: Stack(children: [
        AnimatedBuilder(animation: _ambientAnim, builder: (_, __) => Stack(children: [
          Positioned(top: -180, left: w * 0.05,
              child: _Glow(color: _kCrimson.withOpacity(
                  t.d ? 0.07 + _ambientAnim.value * 0.04 : 0.025), size: 520)),
          Positioned(bottom: -200, right: -80,
              child: _Glow(color: _kViolet.withOpacity(
                  t.d ? 0.05 + _ambientAnim.value * 0.03 : 0.018), size: 400)),
        ])),
        Positioned.fill(child: CustomPaint(painter: _GridPainter(t: t))),
        SafeArea(
          child: Column(children: [
            GlobalNavbar(toggleTheme: widget.toggleTheme,
                setLocale: widget.setLocale, activeRoute: 'emergency'),
            Expanded(child: FadeTransition(opacity: _entryFade,
                child: SlideTransition(position: _entrySlide,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 56),
                      physics: const BouncingScrollPhysics(),
                      child: isDesktop ? _desktopLayout(t, w) : _tabletLayout(t),
                    )))),
          ]),
        ),
      ]),
    );
  }

  Widget _desktopLayout(_T t, double w) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _hero(t),
        const SizedBox(height: 24),
        if (_autoScenario != null) ...[ _autoDetectBanner(t), const SizedBox(height: 16) ],
        if (_statusMsg != null)    ...[ _statusBar(t),         const SizedBox(height: 16) ],
        if (!_service.hasContacts) ...[ _noContactsBanner(t), const SizedBox(height: 16) ],
        _helplinesRow(t),
        const SizedBox(height: 16),
        if (PlatformHelper.supportsShake) _shakeCard(t),
        const SizedBox(height: 14),
        _contactsBtn(t),
      ])),
      const SizedBox(width: 32),
      Expanded(flex: 6, child: _scenariosGrid(t, twoCol: true)),
    ],
  );

  Widget _tabletLayout(_T t) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _hero(t),
    const SizedBox(height: 20),
    if (_autoScenario != null) ...[ _autoDetectBanner(t), const SizedBox(height: 14) ],
    if (_statusMsg != null)    ...[ _statusBar(t),         const SizedBox(height: 14) ],
    if (!_service.hasContacts) ...[ _noContactsBanner(t), const SizedBox(height: 14) ],
    _scenariosGrid(t, twoCol: true),
    const SizedBox(height: 18),
    _helplinesRow(t),
    const SizedBox(height: 14),
    if (PlatformHelper.supportsShake) ...[ _shakeCard(t), const SizedBox(height: 12) ],
    _contactsBtn(t),
  ]);

  // ─────────────────────────────────────────────
  //  HERO — mobile overflow fixed:
  //  fontSize 44 + letterSpacing -2.0 on 375px → overflow.
  //  Fix: adaptive font sizes, no negative letter-spacing on mobile.
  // ─────────────────────────────────────────────

  Widget _hero(_T t) {
    final w        = MediaQuery.of(context).size.width;
    final isMobile = w <= 700;
    final titleFs  = isMobile ? 28.0 : 40.0;
    final titleLS  = isMobile ? -0.4 : -1.5;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Live badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: _kCrimson.withOpacity(0.07),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _kCrimson.withOpacity(0.20))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: _kCrimsonSoft,
                    boxShadow: [BoxShadow(
                        color: _kCrimsonSoft.withOpacity(_pulseAnim.value * 0.8),
                        blurRadius: 6, spreadRadius: 1)])),
          ),
          const SizedBox(width: 8),
          Text(
              PlatformHelper.isMobile
                  ? 'LIVE — SHAKE OR TAP'
                  : 'EMERGENCY SOS — TAP TO ALERT',
              style: const TextStyle(
                  color: _kCrimsonSoft, fontSize: 9.5,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        ]),
      ),

      const SizedBox(height: 14),

      Text(
          'Emergency\nAlert Centre',
          style: TextStyle(
              color: t.textPri, fontSize: titleFs,
              fontWeight: FontWeight.w900,
              height: 1.08, letterSpacing: titleLS)),

      const SizedBox(height: 10),

      Text(
          'Select the type of emergency. A formal alert with your GPS '
              'location will be sent instantly to all your saved contacts.',
          style: TextStyle(
              color: t.textSec, fontSize: isMobile ? 12.5 : 13.5,
              height: 1.7, letterSpacing: 0.05)),
    ]);
  }

  // ─────────────────────────────────────────────
  //  AUTO DETECT BANNER
  // ─────────────────────────────────────────────

  Widget _autoDetectBanner(_T t) {
    final s = _autoScenario!;
    return GestureDetector(
      onTap: () => _triggerSOS(_kScenarios.indexOf(s)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: s.color.withOpacity(t.d ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: s.color.withOpacity(0.30), width: 1.5),
            boxShadow: [BoxShadow(
                color: s.color.withOpacity(t.d ? 0.12 : 0.06),
                blurRadius: 16, offset: const Offset(0, 5))]),
        child: Row(children: [
          Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: s.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: s.color.withOpacity(0.25))),
              child: Icon(s.icon, color: s.soft, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ISL Sign Detected: "${widget.detectedSign}"',
                style: TextStyle(color: s.soft, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text('Suggested: ${s.title} — Tap to send immediately',
                style: TextStyle(color: t.textPri, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ])),
          Icon(Icons.arrow_forward_rounded, color: s.soft, size: 14),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  STATUS BAR
  // ─────────────────────────────────────────────

  Widget _statusBar(_T t) {
    final color = _statusOk ? _kGreen : _kCrimsonSoft;
    final icon  = _statusOk
        ? Icons.check_circle_outline_rounded
        : Icons.error_outline_rounded;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: child)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: color.withOpacity(t.d ? 0.07 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.22))),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(_statusMsg!,
              style: TextStyle(color: color, fontSize: 12.5,
                  fontWeight: FontWeight.w600, height: 1.4))),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  NO CONTACTS BANNER
  // ─────────────────────────────────────────────

  Widget _noContactsBanner(_T t) {
    return GestureDetector(
      onTap: () => Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => EmergencySetupScreen(
            toggleTheme: widget.toggleTheme, setLocale: widget.setLocale),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 280),
      )),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: _kAmber.withOpacity(t.d ? 0.06 : 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kAmber.withOpacity(0.18))),
        child: Row(children: [
          Icon(Icons.warning_rounded, color: _kAmber, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('No emergency contacts configured',
                style: TextStyle(color: _kAmber, fontSize: 11.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Alerts cannot be sent without contacts. Tap to add them.',
                style: TextStyle(color: _kAmber.withOpacity(0.70),
                    fontSize: 10.5, height: 1.4)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, color: _kAmber, size: 11),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SCENARIOS GRID
  // ─────────────────────────────────────────────

  Widget _scenariosGrid(_T t, {required bool twoCol}) {
    if (twoCol) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10, crossAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: _kScenarios.asMap().entries.map((e) => _ScenarioCard(
          scenario:      e.value,
          t:             t,
          pulseAnim:     _pulseAnim,
          isSending:     _isSending && _activeSendIndex == e.key,
          isDisabled:    _isSending && _activeSendIndex != e.key,
          isAutoDetected: _autoScenario == e.value,
          onTap:         () => _triggerSOS(e.key),
        )).toList(),
      );
    }

    return Column(
      children: _kScenarios.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: _ScenarioCard(
          scenario:      e.value,
          t:             t,
          pulseAnim:     _pulseAnim,
          isSending:     _isSending && _activeSendIndex == e.key,
          isDisabled:    _isSending && _activeSendIndex != e.key,
          isAutoDetected: _autoScenario == e.value,
          onTap:         () => _triggerSOS(e.key),
        ),
      )).toList(),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPLINES ROW — mobile overflow fixed:
  //  fontSize 16 numbers on 375px ÷ 4 columns was fine,
  //  but the label text wrapped poorly.
  //  Fix: use shorter labels + smaller font + same Expanded layout.
  // ─────────────────────────────────────────────

  Widget _helplinesRow(_T t) {
    final w        = MediaQuery.of(context).size.width;
    final isMobile = w <= 700;
    final numFs    = isMobile ? 14.0 : 16.0;
    final labFs    = isMobile ? 8.0  : 9.0;

    final items = [
      ('112', 'Emergency', _kCrimson),
      ('108', 'Ambulance', _kOrange),
      ('100', 'Police',    _kBlue),
      ('101', 'Fire',      _kAmber),
    ];
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: t.surfaceUp,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: t.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QUICK REFERENCE HELPLINES',
            style: TextStyle(color: t.textMuted, fontSize: 8.5,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Row(children: items.map((item) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: item == items.last ? 0 : 7),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
                color: item.$3.withOpacity(t.d ? 0.06 : 0.04),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: item.$3.withOpacity(0.15))),
            child: Column(children: [
              Text(item.$1,
                  style: TextStyle(color: item.$3,
                      fontSize: numFs, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text(item.$2,
                  style: TextStyle(color: t.textSec, fontSize: labFs, height: 1.2)),
            ]),
          ),
        )).toList()),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  //  SHAKE CARD
  // ─────────────────────────────────────────────

  Widget _shakeCard(_T t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: t.surfaceUp,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: t.border)),
      child: Row(children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: _kViolet.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _kViolet.withOpacity(0.12 + _pulseAnim.value * 0.12))),
              child: const Icon(Icons.vibration_rounded,
                  color: _kVioletLight, size: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Shake phone to send General Alert',
              style: TextStyle(color: t.textPri, fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Shake twice from any screen to alert all your contacts immediately.',
              style: TextStyle(color: t.textSec, fontSize: 10.5, height: 1.5)),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  //  CONTACTS BUTTON
  // ─────────────────────────────────────────────

  Widget _contactsBtn(_T t) {
    final count = _service.contactCount;
    return GestureDetector(
      onTap: () => Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => EmergencySetupScreen(
            toggleTheme: widget.toggleTheme, setLocale: widget.setLocale),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 280),
      )),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
            color: t.surfaceUp,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: t.border)),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: _kViolet.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.contacts_rounded,
                  color: _kVioletLight, size: 15)),
          const SizedBox(width: 11),
          Expanded(child: Text(
              count > 0
                  ? '$count emergency contact${count == 1 ? '' : 's'} configured'
                  : 'Set up emergency contacts',
              style: TextStyle(color: t.textSec, fontSize: 12.5,
                  fontWeight: FontWeight.w600))),
          Icon(Icons.arrow_forward_ios_rounded, color: t.textMuted, size: 11),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  SCENARIO CARD  — no emojis, Material icons only
// ════════════════════════════════════════════

class _ScenarioCard extends StatefulWidget {
  final _Scenario scenario;
  final _T t;
  final Animation<double> pulseAnim;
  final bool isSending, isDisabled, isAutoDetected;
  final VoidCallback onTap;
  const _ScenarioCard({
    required this.scenario, required this.t,
    required this.pulseAnim,
    required this.isSending, required this.isDisabled,
    required this.isAutoDetected, required this.onTap,
  });
  @override
  State<_ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<_ScenarioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double>   _hoverAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _hoverAnim = CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut);
  }
  @override
  void dispose() { _hoverCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s  = widget.scenario;
    final t  = widget.t;
    final c  = s.color;
    final sc = s.soft;

    return MouseRegion(
      onEnter: (_) { if (!widget.isDisabled) _hoverCtrl.forward(); },
      onExit:  (_) => _hoverCtrl.reverse(),
      child: GestureDetector(
        onTapDown:   (_) { if (!widget.isDisabled) setState(() => _pressed = true); },
        onTapUp:     (_) { setState(() => _pressed = false);
        if (!widget.isDisabled) widget.onTap(); },
        onTapCancel: ()  { setState(() => _pressed = false); },
        child: AnimatedBuilder(
          animation: _hoverAnim,
          builder: (_, __) {
            final hv = _hoverAnim.value;
            return AnimatedScale(
              scale: _pressed ? 0.955 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: AnimatedOpacity(
                opacity: widget.isDisabled ? 0.28 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        t.surfaceUp,
                        c.withOpacity(t.d ? 0.12 : 0.06),
                        widget.isAutoDetected ? 0.65 : (widget.isSending ? 1.0 : hv)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: c.withOpacity(
                            widget.isSending || widget.isAutoDetected
                                ? 0.55
                                : (0.15 + hv * 0.28)),
                        width: (widget.isSending || widget.isAutoDetected) ? 1.5 : 1.0),
                    boxShadow: [BoxShadow(
                        color: c.withOpacity(
                            widget.isSending ? (t.d ? 0.24 : 0.12)
                                : widget.isAutoDetected ? (t.d ? 0.15 : 0.07)
                                : hv * (t.d ? 0.10 : 0.05)),
                        blurRadius: widget.isSending ? 28 : 18,
                        offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Top row — icon + helpline badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                                color: c.withOpacity(t.d ? 0.11 : 0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: c.withOpacity(0.18 + hv * 0.18))),
                            child: Center(child: widget.isSending
                                ? SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.0, color: sc))
                                : Icon(s.icon, color: sc, size: 19)),
                          ),
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                  color: c.withOpacity(t.d ? 0.09 : 0.06),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: c.withOpacity(0.18))),
                              child: Text(s.helpline,
                                  style: TextStyle(color: sc,
                                      fontSize: 10.5, fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2))),
                        ],
                      ),

                      const SizedBox(height: 11),

                      // Title
                      Text(
                        widget.isSending ? 'Sending alert…' : s.title,
                        style: TextStyle(
                            color: widget.isSending ? sc : t.textPri,
                            fontSize: 13, fontWeight: FontWeight.w800,
                            letterSpacing: -0.2, height: 1.15),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle
                      Text(
                        widget.isSending
                            ? 'Contacting ${EmergencyService.instance.contactCount} person(s)…'
                            : s.subtitle,
                        style: TextStyle(
                            color: widget.isSending ? sc.withOpacity(0.65) : t.textSec,
                            fontSize: 9.5, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ISL sign hint (on hover or auto-detected)
                      if (widget.isAutoDetected || hv > 0.25) ...[
                        const SizedBox(height: 7),
                        AnimatedOpacity(
                          opacity: widget.isAutoDetected ? 1.0 : hv,
                          duration: const Duration(milliseconds: 140),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color: c.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(s.signHint,
                                style: TextStyle(
                                    color: sc.withOpacity(0.75),
                                    fontSize: 8.5, fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE SECTION LABEL
// ─────────────────────────────────────────────
class _MobileSectionLabel extends StatelessWidget {
  final String label, sub;
  final _T t;
  const _MobileSectionLabel({required this.label, required this.sub, required this.t});
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(
        color: t.textMuted, fontSize: 9.5,
        fontWeight: FontWeight.w700, letterSpacing: 1.4)),
    const SizedBox(height: 2),
    Text(sub, style: TextStyle(color: t.textSec, fontSize: 11.5)),
  ]);
}

// ─────────────────────────────────────────────
//  BACKGROUND HELPERS
// ─────────────────────────────────────────────

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
        child: const SizedBox.expand()),
  );
}

class _GridPainter extends CustomPainter {
  final _T t;
  const _GridPainter({required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = t.gridLine..strokeWidth = 0.5;
    const step = 52.0;
    for (double x = 0; x < size.width;  x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    final dp = Paint()
      ..color = _kCrimson.withOpacity(t.d ? 0.028 : 0.015);
    for (double x = 0; x < size.width;  x += step)
      for (double y = 0; y < size.height; y += step)
        canvas.drawCircle(Offset(x, y), 0.8, dp);
  }
  @override
  bool shouldRepaint(_GridPainter old) => old.t.d != t.d;
  Color get gridLine => t.d
      ? const Color(0xFF10102A).withOpacity(0.5)
      : const Color(0xFFE0E0F0).withOpacity(0.7);
}