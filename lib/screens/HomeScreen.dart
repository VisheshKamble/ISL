// lib/screens/HomeScreen.dart
// ─────────────────────────────────────────────
//  ARCHITECTURE
//  < 700px  → _MobileShell  — native app UX:
//              • compact top-bar (not GlobalNavbar)
//              • bottom navigation bar (4 tabs)
//              • Home tab: hero, quick-action cards, stats row,
//                          objectives scroll, impact banner
//              • Tabs 1-3: feature detail pages with launch CTA
//  ≥ 700px  → _WebsiteShell — original website layout unchanged
// ─────────────────────────────────────────────
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/GlobalNavbar.dart';
import '../l10n/AppLocalizations.dart';
import 'TranslateScreen.dart';
import 'TwoWayScreen.dart';
import 'EmergencyScreen.dart';
import 'SignsPage.dart';
import 'objectives/AccessibilityPage.dart';
import 'objectives/BridgingGapsPage.dart';
import 'objectives/InclusivityPage.dart';
import 'objectives/PrivacyPage.dart';
import 'objectives/OfflinePage.dart';
import 'objectives/EducationPage.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _kViolet      = Color(0xFF7C3AED);
const _kVioletLight = Color(0xFFA78BFA);
const _kVioletDeep  = Color(0xFF5B21B6);
const _kObsidian    = Color(0xFF040408);
const _kSurface     = Color(0xFF0C0C16);
const _kSurfaceUp   = Color(0xFF111120);
const _kBorder      = Color(0xFF1C1C30);
const _kBorderBrt   = Color(0xFF2C2C46);
const _kTextPri     = Color(0xFFF0EEFF);
const _kTextSec     = Color(0xFF7070A0);
const _kTextMuted   = Color(0xFF38385A);
const _kCrimson     = Color(0xFFDC2626);
const _kTeal        = Color(0xFF0891B2);
const _kTealLight   = Color(0xFF22D3EE);
const _kGreen       = Color(0xFF059669);
const _kGreenLight  = Color(0xFF34D399);

const _lBg       = Color(0xFFF5F6FE);
const _lSurface  = Color(0xFFFFFFFF);
const _lSurfaceUp= Color(0xFFF0F0FA);
const _lBorder   = Color(0xFFE4E4F2);
const _lBorderBrt= Color(0xFFCCCCE0);
const _lTextPri  = Color(0xFF0A0A20);
const _lTextSec  = Color(0xFF5A5A82);
const _lTextMuted= Color(0xFFB0B0C8);

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const HomeScreen({super.key, required this.toggleTheme, required this.setLocale});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _heroFade;
  late Animation<Offset>   _heroSlide;
  late Animation<double>   _pulse;

  // Desktop scroll
  final ScrollController _scroll   = ScrollController();
  bool  _statsVisible = false;
  final GlobalKey _statsKey = GlobalKey();

  // Mobile tabs
  int _tab = 0;
  late AnimationController _tabCtrl;
  late Animation<double>   _tabFade;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    _pulseCtrl= AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _tabCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));

    _heroFade = CurvedAnimation(parent: _heroCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _heroSlide= Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
        CurvedAnimation(parent: _heroCtrl,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut)));
    _pulse    = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _tabFade  = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOut);

    _heroCtrl.forward();
    _tabCtrl.forward();
    _scroll.addListener(_checkScroll);
  }

  void _checkScroll() {
    if (_statsVisible) return;
    final obj = _statsKey.currentContext?.findRenderObject();
    if (obj is RenderBox) {
      final pos = obj.localToGlobal(Offset.zero).dy;
      if (pos < MediaQuery.of(context).size.height * 0.9)
        setState(() => _statsVisible = true);
    }
  }

  void _switchTab(int idx) {
    if (idx == _tab) return;
    HapticFeedback.selectionClick();
    _tabCtrl.reverse().then((_) {
      if (mounted) { setState(() => _tab = idx); _tabCtrl.forward(); }
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose(); _pulseCtrl.dispose();
    _tabCtrl.dispose();  _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w       = MediaQuery.of(context).size.width;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    if (w < 700) return _buildMobile(context, isDark);
    return _buildWebsite(context, isDark, w);
  }

  // ── MOBILE ───────────────────────────────────
  Widget _buildMobile(BuildContext ctx, bool isDark) {
    final l = AppLocalizations.of(ctx);
    return Scaffold(
      backgroundColor: isDark ? _kObsidian : _lBg,
      extendBody: true,
      body: Stack(children: [
        Positioned.fill(child: _GridBg(isDark: isDark)),
        Positioned(top: -120, left: -60,
          child: _Glow(color: _kViolet.withOpacity(isDark ? 0.17 : 0.06), size: 340)),
        Positioned(bottom: -80, right: -80,
          child: _Glow(color: _kTeal.withOpacity(isDark ? 0.09 : 0.03), size: 250)),
        SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _tabFade,
            child: _mobileTabBody(ctx, l, isDark),
          ),
        ),
      ]),
      bottomNavigationBar: _BottomNav(
        isDark: isDark, tab: _tab, onTap: _switchTab, l: l),
    );
  }

  Widget _mobileTabBody(BuildContext ctx, AppLocalizations l, bool isDark) {
    switch (_tab) {
      case 0: return _MobileHome(isDark: isDark, pulse: _pulse,
          heroFade: _heroFade, heroSlide: _heroSlide, l: l,
          toggleTheme: widget.toggleTheme, setLocale: widget.setLocale);
      case 1: return _FeaturePage(isDark: isDark, l: l,
          title: l.t('nav_terminal'), subtitle: 'Sign language to text · Real-time AI',
          icon: Icons.translate_rounded, accentColor: _kViolet,
          launchLabel: l.t('get_started'),
          onLaunch: () => _push(ctx, TranslateScreen(
              toggleTheme: widget.toggleTheme, setLocale: widget.setLocale)),
          features: [
            (Icons.center_focus_strong_rounded, 'Camera detection',    'Point camera at signing hands'),
            (Icons.auto_fix_high_rounded,        'Hold to auto-add',    'Stability engine locks signs in'),
            (Icons.translate_rounded,            'Multilingual output', 'Hindi, Marathi, Tamil & more'),
            (Icons.article_rounded,              'Transcript log',      'Full session saved locally'),
          ]);
      case 2: return _FeaturePage(isDark: isDark, l: l,
          title: l.t('nav_signs'), subtitle: '64 ISL signs · Browse & learn',
          icon: Icons.back_hand_rounded, accentColor: _kTeal,
          launchLabel: 'Browse Signs',
          onLaunch: () => _push(ctx, SignsPage(
              toggleTheme: widget.toggleTheme, setLocale: widget.setLocale)),
          features: [
            (Icons.grid_view_rounded,   '64 signs',      'Complete ISL vocabulary library'),
            (Icons.flip_rounded,        'Flip cards',    'Hand shape + meaning on each card'),
            (Icons.search_rounded,      'Search',        'Find by name, meaning, category'),
            (Icons.category_rounded,    'Filter types',  'Alphabet, numbers, or words'),
          ]);
      case 3: return _FeaturePage(isDark: isDark, l: l,
          title: l.t('nav_bridge'), subtitle: 'Two-way deaf & hearing communication',
          icon: Icons.compare_arrows_rounded, accentColor: _kGreen,
          launchLabel: 'Open Bridge',
          onLaunch: () => _push(ctx, TwoWayScreen(
              toggleTheme: widget.toggleTheme, setLocale: widget.setLocale)),
          features: [
            (Icons.record_voice_over_rounded, 'Deaf person signs', 'Camera detects & sends sign'),
            (Icons.keyboard_rounded,          'Hearing types',     'Reply in any language'),
            (Icons.chat_bubble_rounded,       'Chat thread',       'Messenger-style history'),
            (Icons.flash_on_rounded,          'Quick phrases',     '12 professional pre-built phrases'),
          ]);
      default: return const SizedBox.shrink();
    }
  }

  void _push(BuildContext ctx, Widget s) => Navigator.push(ctx, PageRouteBuilder(
    pageBuilder: (_, __, ___) => s,
    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    transitionDuration: const Duration(milliseconds: 300)));

  // ── WEBSITE ──────────────────────────────────
  Widget _buildWebsite(BuildContext ctx, bool isDark, double w) {
    final isDesktop = w > 1100;
    final hPad = isDesktop ? 96.0 : 48.0;
    final l = AppLocalizations.of(ctx);

    return Scaffold(
      backgroundColor: isDark ? _kObsidian : _lBg,
      body: Stack(children: [
        Positioned.fill(child: _GridBg(isDark: isDark)),
        Positioned(top: -200, left: -100,
          child: _Glow(color: _kViolet.withOpacity(isDark ? 0.20 : 0.08), size: 700)),
        Positioned(bottom: -300, right: -200,
          child: _Glow(color: const Color(0xFF1D4ED8).withOpacity(isDark ? 0.12 : 0.05), size: 600)),
        SafeArea(
          child: SingleChildScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              GlobalNavbar(toggleTheme: widget.toggleTheme,
                  setLocale: widget.setLocale, activeRoute: 'home'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(children: [
                  SizedBox(height: isDesktop ? 80 : 56),
                  FadeTransition(opacity: _heroFade,
                    child: SlideTransition(position: _heroSlide,
                      child: Column(children: [
                        _StatusChip(l: l, pulse: _pulse, isDark: isDark),
                        SizedBox(height: isDesktop ? 44 : 32),
                        _HeroText(isDesktop: isDesktop, isTablet: !isDesktop, l: l, isDark: isDark),
                        SizedBox(height: isDesktop ? 28 : 22),
                        _HeroSub(isDesktop: isDesktop, l: l, isDark: isDark),
                        SizedBox(height: isDesktop ? 52 : 40),
                        _CTAButton(label: l.t('get_started'),
                          onTap: () => _push(ctx, TranslateScreen(
                              toggleTheme: widget.toggleTheme,
                              setLocale: widget.setLocale))),
                      ]))),
                  SizedBox(height: isDesktop ? 120 : 88),
                  _Divider(isDark: isDark),
                  SizedBox(height: isDesktop ? 80 : 64),
                  Container(key: _statsKey,
                    child: _StatsSection(isDesktop: isDesktop,
                        isVisible: _statsVisible, l: l, isDark: isDark)),
                  SizedBox(height: isDesktop ? 120 : 96),
                  _SectionLabel(text: l.t('obj_heading'), sub: l.t('obj_sub'), isDark: isDark),
                  SizedBox(height: isDesktop ? 56 : 40),
                  _ObjGrid(isDesktop: isDesktop, l: l, isDark: isDark,
                      toggleTheme: widget.toggleTheme, setLocale: widget.setLocale),
                  SizedBox(height: isDesktop ? 120 : 96),
                  _VisionCard(l: l, isDark: isDark),
                  SizedBox(height: isDesktop ? 80 : 64),
                  _Footer(isDark: isDark),
                  const SizedBox(height: 48),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════
//  MOBILE: BOTTOM NAV
// ══════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final bool isDark;
  final int tab;
  final ValueChanged<int> onTap;
  final AppLocalizations l;
  const _BottomNav({required this.isDark, required this.tab,
    required this.onTap, required this.l});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded,           Icons.home_outlined,           'Home'),
      (Icons.translate_rounded,      Icons.translate_outlined,      l.t('nav_terminal')),
      (Icons.back_hand_rounded,      Icons.back_hand_outlined,      l.t('nav_signs')),
      (Icons.compare_arrows_rounded, Icons.compare_arrows_rounded,  l.t('nav_bridge')),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF06060F).withOpacity(0.97) : Colors.white.withOpacity(0.97),
        border: Border(top: BorderSide(
          color: isDark ? _kBorder : _lBorder, width: 0.75)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
          blurRadius: 20, offset: const Offset(0, -4))]),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key; final item = e.value;
              final active = tab == i;
              final color  = active ? _kViolet : (isDark ? _kTextSec : _lTextSec);
              return Expanded(child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 40 : 32, height: active ? 40 : 32,
                    decoration: BoxDecoration(
                      color: active ? _kViolet.withOpacity(isDark ? 0.14 : 0.09) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(active ? item.$1 : item.$2, color: color,
                        size: active ? 21 : 19)),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: color,
                      fontSize: active ? 10.5 : 9.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500),
                    child: Text(item.$3, overflow: TextOverflow.ellipsis)),
                ]),
              ));
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  MOBILE: HOME TAB
// ══════════════════════════════════════════════
class _MobileHome extends StatelessWidget {
  final bool isDark;
  final Animation<double> pulse, heroFade;
  final Animation<Offset> heroSlide;
  final AppLocalizations l;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const _MobileHome({required this.isDark, required this.pulse,
    required this.heroFade, required this.heroSlide, required this.l,
    required this.toggleTheme, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _TopBar(isDark: isDark, l: l, pulse: pulse,
            toggleTheme: toggleTheme, setLocale: setLocale),
        FadeTransition(opacity: heroFade,
          child: SlideTransition(position: heroSlide,
            child: _Hero(isDark: isDark, l: l, context: context,
                toggleTheme: toggleTheme, setLocale: setLocale))),
        const SizedBox(height: 28),
        _QuickRow(isDark: isDark, l: l, context: context,
            toggleTheme: toggleTheme, setLocale: setLocale),
        const SizedBox(height: 24),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _StatsStrip(isDark: isDark, l: l)),
        const SizedBox(height: 28),
        Padding(padding: const EdgeInsets.only(left: 20, bottom: 14),
          child: Text('What We Stand For', style: TextStyle(
            color: isDark ? _kTextPri : _lTextPri,
            fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3))),
        _ObjectivesScroll(isDark: isDark, l: l,
            toggleTheme: toggleTheme, setLocale: setLocale),
        const SizedBox(height: 28),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _ImpactCard(isDark: isDark, l: l)),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ── Mobile Top Bar ────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final Animation<double> pulse;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const _TopBar({required this.isDark, required this.l, required this.pulse,
    required this.toggleTheme, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final locale  = Localizations.localeOf(context);
    final primary = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 6),
      child: Row(children: [
        // Brand
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [_kViolet, _kVioletLight]).createShader(b),
          child: const Text('VANI', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w900,
            color: Colors.white, letterSpacing: 4))),
        // Live dot
        AnimatedBuilder(animation: pulse, builder: (_, __) => Container(
          margin: const EdgeInsets.only(left: 7),
          width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: _kVioletLight,
            boxShadow: [BoxShadow(
              color: _kVioletLight.withOpacity(pulse.value * 0.65),
              blurRadius: 6, spreadRadius: 1)]))),
        const Spacer(),
        // Lang
        _LangPill(locale: locale, setLocale: setLocale,
            isDark: isDark, primary: primary),
        const SizedBox(width: 8),
        // Theme
        GestureDetector(
          onTap: toggleTheme,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isDark ? _kSurfaceUp : _lSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? _kBorder : _lBorder)),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 16, color: isDark ? _kTextSec : _lTextSec))),
      ]),
    );
  }
}

class _LangPill extends StatelessWidget {
  final Locale locale;
  final Function(Locale) setLocale;
  final bool isDark;
  final Color primary;
  const _LangPill({required this.locale, required this.setLocale,
    required this.isDark, required this.primary});
  @override
  Widget build(BuildContext context) {
    final langs = [
      {'code': 'en', 'flag': '🇬🇧'},
      {'code': 'hi', 'flag': '🇮🇳'},
      {'code': 'mr', 'flag': '🇮🇳'},
    ];
    final cur = langs.firstWhere(
        (l) => l['code'] == locale.languageCode, orElse: () => langs[0]);
    return PopupMenuButton<String>(
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? const Color(0xFF141428) : Colors.white,
      elevation: 12,
      onSelected: (c) => setLocale(Locale(c)),
      itemBuilder: (_) => langs.map((lang) => PopupMenuItem<String>(
        value: lang['code'],
        child: Row(children: [
          Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(lang['code']!.toUpperCase(), style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13,
            color: lang['code'] == locale.languageCode
                ? primary : (isDark ? Colors.white70 : Colors.black87))),
          if (lang['code'] == locale.languageCode) ...[
            const Spacer(),
            Icon(Icons.check_rounded, color: primary, size: 14)],
        ]))).toList(),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.18))),
        child: Center(child: Text(cur['flag']!,
            style: const TextStyle(fontSize: 17)))));
  }
}

// ── Mobile Hero ───────────────────────────────
class _Hero extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final BuildContext context;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const _Hero({required this.isDark, required this.l, required this.context,
    required this.toggleTheme, required this.setLocale});

  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Tag
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _kViolet.withOpacity(isDark ? 0.13 : 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kViolet.withOpacity(0.22))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 5, height: 5,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _kVioletLight)),
          const SizedBox(width: 7),
          const Text('ISL · On-Device AI · Offline Ready', style: TextStyle(
            color: _kVioletLight, fontSize: 10.5,
            fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        ])),
      const SizedBox(height: 14),
      // Headline — left-aligned: native app feel
      Text('Sign Language\nTo Text,', style: TextStyle(
        fontSize: 30, fontWeight: FontWeight.w900, height: 1.12,
        color: isDark ? _kTextPri : _lTextPri, letterSpacing: -0.5)),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [_kViolet, _kVioletLight]).createShader(b),
        child: const Text('Instantly.', style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w900, height: 1.12,
          color: Colors.white, letterSpacing: -0.5))),
      const SizedBox(height: 12),
      Text('Empowering India\'s 63M+ deaf & mute\ncommunity — private, accurate, offline.',
        style: TextStyle(
          fontSize: 14, color: isDark ? _kTextSec : _lTextSec,
          height: 1.65, letterSpacing: 0.05)),
      const SizedBox(height: 20),
      // Full-width CTA
      GestureDetector(
        onTap: () => Navigator.push(ctx, PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              TranslateScreen(toggleTheme: toggleTheme, setLocale: setLocale),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 300))),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kViolet, _kVioletDeep]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
              color: _kViolet.withOpacity(0.38),
              blurRadius: 18, offset: const Offset(0, 7))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.translate_rounded, color: Colors.white, size: 17),
            const SizedBox(width: 10),
            Text(l.t('get_started'), style: const TextStyle(
              color: Colors.white, fontSize: 14.5,
              fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
          ]))),
    ]),
  );
}

// ── Quick Action Row ──────────────────────────
class _QuickRow extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final BuildContext context;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const _QuickRow({required this.isDark, required this.l, required this.context,
    required this.toggleTheme, required this.setLocale});

  PageRouteBuilder _fade(Widget s) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => s,
    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    transitionDuration: const Duration(milliseconds: 290));

  @override
  Widget build(BuildContext ctx) {
    final cards = [
      (_kTeal, _kTealLight, Icons.compare_arrows_rounded, 'Two-Way\nBridge',
       TwoWayScreen(toggleTheme: toggleTheme, setLocale: setLocale)),
      (_kCrimson, const Color(0xFFEF4444), Icons.emergency_rounded, 'SOS\nAlert',
       EmergencyScreen(toggleTheme: toggleTheme, setLocale: setLocale)),
      (_kGreen,  _kGreenLight, Icons.back_hand_rounded, 'Signs\nLibrary',
       SignsPage(toggleTheme: toggleTheme, setLocale: setLocale)),
    ];
    return SizedBox(height: 100, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final c = cards[i];
        return _QCard(color: c.$1, accent: c.$2, icon: c.$3,
            label: c.$4, isDark: isDark,
            onTap: () => Navigator.push(ctx, _fade(c.$5)));
      }));
  }
}

class _QCard extends StatefulWidget {
  final Color color, accent;
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _QCard({required this.color, required this.accent, required this.icon,
    required this.label, required this.isDark, required this.onTap});
  @override
  State<_QCard> createState() => _QCardState();
}
class _QCardState extends State<_QCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => setState(() => _pressed = true),
    onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
    onTapCancel: ()  => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: Container(
        width: 108,
        decoration: BoxDecoration(
          color: isDark ? _kSurfaceUp : _lSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withOpacity(isDark ? 0.24 : 0.16)),
          boxShadow: [BoxShadow(
            color: widget.color.withOpacity(isDark ? 0.11 : 0.07),
            blurRadius: 14, offset: const Offset(0, 4))]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(11)),
            child: Icon(widget.icon, color: widget.accent, size: 19)),
          const SizedBox(height: 8),
          Text(widget.label, textAlign: TextAlign.center, style: TextStyle(
            color: isDark ? _kTextPri : _lTextPri,
            fontSize: 11, fontWeight: FontWeight.w700, height: 1.25)),
        ]))));

  bool get isDark => widget.isDark;
}

// ── Stats Strip ───────────────────────────────
class _StatsStrip extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  const _StatsStrip({required this.isDark, required this.l});
  @override
  Widget build(BuildContext context) {
    final stats = [
      ('63M+',  l.t('stat_mute_label'), _kVioletLight),
      ('8.4M+', l.t('stat_isl_label'),  _kVioletLight),
      ('250',   l.t('stat_translators_label'), _kCrimson),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _kSurface : _lSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kBorder : _lBorder),
        boxShadow: [if (!isDark) BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(children: stats.asMap().entries.map((e) {
        final s = e.value; final last = e.key == stats.length - 1;
        return Expanded(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          decoration: BoxDecoration(border: last ? null : Border(
            right: BorderSide(color: isDark ? _kBorder : _lBorder))),
          child: Column(children: [
            Text(s.$1, style: TextStyle(color: s.$3, fontSize: 20,
                fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(s.$2, textAlign: TextAlign.center, style: TextStyle(
              color: isDark ? _kTextSec : _lTextSec,
              fontSize: 8.5, height: 1.3, fontWeight: FontWeight.w500)),
          ])));
      }).toList()));
  }
}

// ── Objectives Horizontal Scroll ──────────────
class _ObjectivesScroll extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const _ObjectivesScroll({required this.isDark, required this.l,
    required this.toggleTheme, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (Icons.accessibility_new_rounded, l.t('obj_accessibility'), l.t('obj_accessibility_desc'),
       const Color(0xFF7C3AED), AccessibilityPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.connecting_airports_rounded, l.t('obj_bridging'), l.t('obj_bridging_desc'),
       const Color(0xFF0284C7), BridgingGapsPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.people_outline_rounded, l.t('obj_inclusivity'), l.t('obj_inclusivity_desc'),
       const Color(0xFF059669), InclusivityPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.shield_outlined, l.t('obj_privacy'), l.t('obj_privacy_desc'),
       const Color(0xFFD97706), PrivacyPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.wifi_off_rounded, l.t('obj_offline'), l.t('obj_offline_desc'),
       const Color(0xFF6366F1), OfflinePage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.school_rounded, l.t('obj_education'), l.t('obj_education_desc'),
       const Color(0xFFDC2626), EducationPage(toggleTheme: toggleTheme, setLocale: setLocale)),
    ];
    return SizedBox(height: 158, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (ctx, i) {
        final c = cards[i];
        return _ObjCard(icon: c.$1, title: c.$2, desc: c.$3,
            color: c.$4, page: c.$5, isDark: isDark);
      }));
  }
}

class _ObjCard extends StatefulWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  final Widget page;
  final bool isDark;
  const _ObjCard({required this.icon, required this.title,
    required this.desc, required this.color,
    required this.page, required this.isDark});
  @override
  State<_ObjCard> createState() => _ObjCardState();
}
class _ObjCardState extends State<_ObjCard> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:   (_) => setState(() => _p = true),
    onTapUp:     (_) {
      setState(() => _p = false);
      Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.page,
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 260)));
    },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(
      scale: _p ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: Container(
        width: 146,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: widget.isDark ? _kSurfaceUp : _lSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withOpacity(widget.isDark ? 0.20 : 0.13)),
          boxShadow: [BoxShadow(
            color: widget.color.withOpacity(widget.isDark ? 0.09 : 0.05),
            blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(widget.isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(9)),
            child: Icon(widget.icon, color: widget.color, size: 16)),
          const SizedBox(height: 9),
          Text(widget.title, style: TextStyle(
            color: widget.isDark ? _kTextPri : _lTextPri,
            fontSize: 12.5, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 5),
          Expanded(child: Text(widget.desc, style: TextStyle(
            color: widget.isDark ? _kTextSec : _lTextSec,
            fontSize: 10.5, height: 1.4),
            maxLines: 3, overflow: TextOverflow.ellipsis)),
        ]))));
}

// ── Impact Card ───────────────────────────────
class _ImpactCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  const _ImpactCard({required this.isDark, required this.l});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? _kViolet.withOpacity(0.07) : _kViolet.withOpacity(0.04),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kViolet.withOpacity(isDark ? 0.18 : 0.10))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kViolet.withOpacity(0.10), shape: BoxShape.circle),
          child: const Icon(Icons.volunteer_activism_rounded,
              color: _kVioletLight, size: 15)),
        const SizedBox(width: 10),
        const Text('Our Mission', style: TextStyle(
          color: _kVioletLight, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 12),
      Text(l.t('vision_title'), style: const TextStyle(
        color: _kVioletLight, fontSize: 17,
        fontWeight: FontWeight.w800, letterSpacing: -0.3, height: 1.2)),
      const SizedBox(height: 10),
      Text(
        'With only 1 certified translator for every 33,000+ deaf individuals '
        'in India, VANI bridges the gap — delivering real-time sign language '
        'translation on your device, privately.',
        style: TextStyle(fontSize: 13,
          color: isDark ? _kTextSec : _lTextSec, height: 1.65)),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _kCrimson.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kCrimson.withOpacity(0.22))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 5, height: 5,
              decoration: const BoxDecoration(color: _kCrimson, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('1 interpreter : 33,000+ people', style: TextStyle(
            color: _kCrimson.withOpacity(0.85), fontSize: 11.5,
            fontWeight: FontWeight.w700)),
        ])),
    ]));
}

// ══════════════════════════════════════════════
//  MOBILE: FEATURE PAGE  (tabs 1-3)
// ══════════════════════════════════════════════
class _FeaturePage extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final String title, subtitle, launchLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onLaunch;
  final List<(IconData, String, String)> features;
  const _FeaturePage({required this.isDark, required this.l,
    required this.title, required this.subtitle, required this.icon,
    required this.accentColor, required this.onLaunch,
    required this.launchLabel, required this.features});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hero card
      Container(
        width: double.infinity, padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(isDark ? 0.17 : 0.09),
              accentColor.withOpacity(isDark ? 0.05 : 0.02)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(isDark ? 0.28 : 0.16))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(isDark ? 0.14 : 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withOpacity(0.24))),
            child: Icon(icon, color: accentColor, size: 25)),
          const SizedBox(height: 14),
          Text(title, style: TextStyle(
            color: isDark ? _kTextPri : _lTextPri,
            fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(
            color: isDark ? _kTextSec : _lTextSec, fontSize: 13.5, height: 1.5)),
        ])),
      const SizedBox(height: 22),
      Text('What\'s Inside', style: TextStyle(
        color: isDark ? _kTextMuted : _lTextMuted,
        fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
      const SizedBox(height: 10),
      ...features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isDark ? _kSurfaceUp : _lSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? _kBorder : _lBorder)),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(9)),
              child: Icon(f.$1, color: accentColor, size: 16)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.$2, style: TextStyle(
                color: isDark ? _kTextPri : _lTextPri,
                fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(f.$3, style: TextStyle(
                color: isDark ? _kTextSec : _lTextSec,
                fontSize: 11.5, height: 1.4)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded,
                color: isDark ? _kTextMuted : _lTextMuted, size: 11),
          ])))),
      const SizedBox(height: 24),
      // Launch CTA
      GestureDetector(
        onTap: onLaunch,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
              color: accentColor.withOpacity(0.38),
              blurRadius: 18, offset: const Offset(0, 7))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 10),
            Text(launchLabel, style: const TextStyle(
              color: Colors.white, fontSize: 15,
              fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
          ]))),
    ]));
}

// ══════════════════════════════════════════════
//  WEBSITE COMPONENTS  (≥700px — unchanged from previous)
// ══════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  final AppLocalizations l; final Animation<double> pulse; final bool isDark;
  const _StatusChip({required this.l, required this.pulse, required this.isDark});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (_, __) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceUp : _lSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _kViolet.withOpacity(isDark ? 0.32 : 0.18)),
        boxShadow: [BoxShadow(
          color: _kViolet.withOpacity(pulse.value * (isDark ? 0.14 : 0.05)),
          blurRadius: 18)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(
          shape: BoxShape.circle, color: _kVioletLight,
          boxShadow: [BoxShadow(
            color: _kVioletLight.withOpacity(pulse.value * 0.75),
            blurRadius: 7, spreadRadius: 1)])),
        const SizedBox(width: 9),
        Text(l.t('badge'), style: TextStyle(
          color: isDark ? _kVioletLight : _kViolet,
          fontWeight: FontWeight.w600, fontSize: 11.5, letterSpacing: 0.3)),
      ])));
}

class _HeroText extends StatelessWidget {
  final bool isDesktop, isTablet; final AppLocalizations l; final bool isDark;
  const _HeroText({required this.isDesktop, required this.isTablet, required this.l, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final fs = isDesktop ? 70.0 : 50.0;
    final ls = isDesktop ? -2.0 : -1.0;
    final color = isDark ? _kTextPri : _lTextPri;
    return Column(children: [
      Text(l.t('hero_title_1'), textAlign: TextAlign.center,
        style: TextStyle(fontSize: fs, fontWeight: FontWeight.w900,
            color: color, height: 1.10, letterSpacing: ls)),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [_kViolet, _kVioletLight, Color(0xFF60A5FA)],
          stops: [0.0, 0.55, 1.0]).createShader(b),
        child: Text(l.t('hero_title_highlight'), textAlign: TextAlign.center,
          style: TextStyle(fontSize: fs, fontWeight: FontWeight.w900,
              color: Colors.white, height: 1.10, letterSpacing: ls))),
      if (l.t('hero_title_2').isNotEmpty)
        Text(l.t('hero_title_2'), textAlign: TextAlign.center,
          style: TextStyle(fontSize: fs, fontWeight: FontWeight.w900,
              color: color, height: 1.10, letterSpacing: ls)),
    ]);
  }
}

class _HeroSub extends StatelessWidget {
  final bool isDesktop; final AppLocalizations l; final bool isDark;
  const _HeroSub({required this.isDesktop, required this.l, required this.isDark});
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: isDesktop ? 580 : 480),
    child: Text(l.t('hero_sub'), textAlign: TextAlign.center,
      style: TextStyle(fontSize: isDesktop ? 17 : 15.5,
        color: isDark ? _kTextSec : _lTextSec, height: 1.75, letterSpacing: 0.1)));
}

class _CTAButton extends StatefulWidget {
  final String label; final VoidCallback onTap;
  const _CTAButton({required this.label, required this.onTap});
  @override State<_CTAButton> createState() => _CTAButtonState();
}
class _CTAButtonState extends State<_CTAButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _h
              ? [const Color(0xFF8B5CF6), _kViolet]
              : [_kViolet, _kVioletDeep]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kVioletLight.withOpacity(_h ? 0.4 : 0.12)),
          boxShadow: [BoxShadow(
            color: _kViolet.withOpacity(_h ? 0.50 : 0.28),
            blurRadius: _h ? 44 : 22, offset: const Offset(0, 8))]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.label, style: const TextStyle(
            fontSize: 14.5, fontWeight: FontWeight.w700,
            color: Colors.white, letterSpacing: 0.4)),
          const SizedBox(width: 12),
          AnimatedSlide(offset: Offset(_h ? 0.25 : 0, 0),
            duration: const Duration(milliseconds: 160),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16)),
        ]))));
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(gradient: LinearGradient(colors: [
      Colors.transparent, isDark ? _kBorderBrt : const Color(0xFFCCCCE0), Colors.transparent])));
}

class _StatsSection extends StatelessWidget {
  final bool isDesktop, isVisible; final AppLocalizations l; final bool isDark;
  const _StatsSection({required this.isDesktop, required this.isVisible,
    required this.l, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final stats = [
      (value: '63000000', label: l.t('stat_mute_label'), color: _kVioletLight, suffix: '+'),
      (value: '8435000',  label: l.t('stat_isl_label'),  color: _kVioletLight, suffix: '+'),
      (value: '250',      label: l.t('stat_translators_label'), color: _kCrimson, suffix: ''),
    ];
    return IntrinsicHeight(child: Row(children: [
      for (int i = 0; i < stats.length; i++) ...[
        Expanded(child: _StatCell(value: stats[i].value, label: stats[i].label,
            color: stats[i].color, suffix: stats[i].suffix,
            isVisible: isVisible, isDark: isDark)),
        if (i < stats.length - 1)
          Container(width: 1, color: isDark ? _kBorder : const Color(0xFFDDDDEE)),
      ],
    ]));
  }
}

class _StatCell extends StatefulWidget {
  final String value, label, suffix; final Color color; final bool isVisible, isDark;
  const _StatCell({required this.value, required this.label, required this.color,
    required this.suffix, required this.isVisible, required this.isDark});
  @override State<_StatCell> createState() => _StatCellState();
}
class _StatCellState extends State<_StatCell> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _anim = Tween<double>(begin: 0, end: double.parse(widget.value))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo));
  }
  @override
  void didUpdateWidget(_StatCell old) {
    super.didUpdateWidget(old);
    if (widget.isVisible && !old.isVisible) _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
    child: AnimatedBuilder(animation: _anim, builder: (_, __) =>
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: _fmt(_anim.value.toInt()), style: TextStyle(
              fontSize: 44, fontWeight: FontWeight.w900, color: widget.color,
              letterSpacing: -1.5, fontFeatures: const [FontFeature.tabularFigures()])),
            TextSpan(text: widget.suffix, style: TextStyle(fontSize: 28,
                fontWeight: FontWeight.w900, color: widget.color.withOpacity(0.55))),
          ])),
          const SizedBox(height: 10),
          Text(widget.label, textAlign: TextAlign.center, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: widget.isDark ? _kTextSec : _lTextSec, letterSpacing: 0.3)),
        ])));
}

class _SectionLabel extends StatelessWidget {
  final String text, sub; final bool isDark;
  const _SectionLabel({required this.text, required this.sub, required this.isDark});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: _kViolet.withOpacity(0.28)),
        borderRadius: BorderRadius.circular(6)),
      child: Text('// OBJECTIVES', style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: _kViolet.withOpacity(0.75), letterSpacing: 2.0))),
    const SizedBox(height: 16),
    Text(text, textAlign: TextAlign.center, style: TextStyle(
      fontSize: 34, fontWeight: FontWeight.w900,
      color: isDark ? _kTextPri : _lTextPri, letterSpacing: -0.8, height: 1.15)),
    const SizedBox(height: 10),
    Text(sub, textAlign: TextAlign.center, style: TextStyle(
      fontSize: 14, color: isDark ? _kTextMuted : _lTextMuted, letterSpacing: 0.15)),
  ]);
}

class _ObjGrid extends StatelessWidget {
  final bool isDesktop; final AppLocalizations l; final bool isDark;
  final VoidCallback toggleTheme; final Function(Locale) setLocale;
  const _ObjGrid({required this.isDesktop, required this.l, required this.isDark,
    required this.toggleTheme, required this.setLocale});
  @override
  Widget build(BuildContext context) {
    final cards = [
      (Icons.accessibility_new_rounded,   l.t('obj_accessibility'), l.t('obj_accessibility_desc'), const Color(0xFF7C3AED),
       AccessibilityPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.connecting_airports_rounded, l.t('obj_bridging'), l.t('obj_bridging_desc'), const Color(0xFF0284C7),
       BridgingGapsPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.people_outline_rounded,      l.t('obj_inclusivity'), l.t('obj_inclusivity_desc'), const Color(0xFF059669),
       InclusivityPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.shield_outlined,             l.t('obj_privacy'), l.t('obj_privacy_desc'), const Color(0xFFD97706),
       PrivacyPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.wifi_off_rounded,            l.t('obj_offline'), l.t('obj_offline_desc'), const Color(0xFF6366F1),
       OfflinePage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (Icons.school_rounded,              l.t('obj_education'), l.t('obj_education_desc'), const Color(0xFFDC2626),
       EducationPage(toggleTheme: toggleTheme, setLocale: setLocale)),
    ];
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 3 : 2,
      mainAxisSpacing: 14, crossAxisSpacing: 14,
      childAspectRatio: isDesktop ? 1.6 : 1.45,
      children: cards.map((c) => _WebObjCard(
        icon: c.$1, title: c.$2, desc: c.$3,
        accent: c.$4, page: c.$5, isDark: isDark)).toList());
  }
}

class _WebObjCard extends StatefulWidget {
  final IconData icon; final String title, desc;
  final bool isDark; final Color accent; final Widget page;
  const _WebObjCard({required this.icon, required this.title, required this.desc,
    required this.isDark, required this.accent, required this.page});
  @override State<_WebObjCard> createState() => _WebObjCardState();
}
class _WebObjCardState extends State<_WebObjCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: () => Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child:
            SlideTransition(position: Tween<Offset>(
                begin: const Offset(0, 0.03), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)), child: child)),
        transitionDuration: const Duration(milliseconds: 320))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark
              ? (_h ? _kSurfaceUp : _kSurface)
              : (_h ? Colors.white : const Color(0xFFFAFAFD)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _h ? widget.accent.withOpacity(0.42) : (widget.isDark ? _kBorder : _lBorder),
            width: _h ? 1.5 : 1.0),
          boxShadow: _h
              ? [BoxShadow(color: widget.accent.withOpacity(widget.isDark ? 0.16 : 0.08),
                  blurRadius: 32, offset: const Offset(0, 10))]
              : [if (!widget.isDark) BoxShadow(color: Colors.black.withOpacity(0.03),
                  blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.accent.withOpacity(widget.isDark ? 0.14 : 0.07),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: widget.accent.withOpacity(_h ? 0.38 : 0.14))),
              child: Icon(widget.icon, color: widget.accent, size: 18)),
            const Spacer(),
            AnimatedOpacity(opacity: _h ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(7)),
                child: Icon(Icons.arrow_forward_rounded, color: widget.accent, size: 13))),
          ]),
          const SizedBox(height: 14),
          Text(widget.title, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2,
            color: widget.isDark ? _kTextPri : _lTextPri)),
          const SizedBox(height: 5),
          Text(widget.desc, style: TextStyle(
            fontSize: 12.5, height: 1.5,
            color: widget.isDark ? _kTextSec : _lTextSec)),
          const SizedBox(height: 10),
          AnimatedOpacity(opacity: _h ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Text('Explore →', style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w700,
              color: widget.accent, letterSpacing: 0.2))),
        ]))));
}

class _VisionCard extends StatelessWidget {
  final AppLocalizations l; final bool isDark;
  const _VisionCard({required this.l, required this.isDark});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 40),
        decoration: BoxDecoration(
          color: isDark ? _kViolet.withOpacity(0.06) : _kViolet.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kViolet.withOpacity(isDark ? 0.18 : 0.10))),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 32, height: 1, color: _kViolet.withOpacity(0.35)),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kViolet.withOpacity(0.10), shape: BoxShape.circle,
                border: Border.all(color: _kViolet.withOpacity(0.25))),
              child: const Icon(Icons.volunteer_activism_rounded,
                  color: _kVioletLight, size: 22)),
            const SizedBox(width: 14),
            Container(width: 32, height: 1, color: _kViolet.withOpacity(0.35)),
          ]),
          const SizedBox(height: 24),
          Text(l.t('vision_title'), textAlign: TextAlign.center, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, color: _kVioletLight,
            letterSpacing: -0.4, height: 1.25)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(l.t('vision_body'), textAlign: TextAlign.center, style: TextStyle(
              fontSize: 15, color: isDark ? _kTextSec : _lTextSec, height: 1.75))),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _kCrimson.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kCrimson.withOpacity(0.22))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(
                color: _kCrimson, shape: BoxShape.circle)),
              const SizedBox(width: 9),
              Text('1 translator : 33,000+ people', style: TextStyle(
                color: _kCrimson.withOpacity(0.85), fontSize: 12.5, fontWeight: FontWeight.w700)),
            ])),
        ]))));
}

class _Footer extends StatelessWidget {
  final bool isDark;
  const _Footer({required this.isDark});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(height: 1, decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.transparent,
        isDark ? _kBorderBrt : const Color(0xFFCCCCE0), Colors.transparent]))),
    const SizedBox(height: 28),
    Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20, runSpacing: 8, children: [
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [_kViolet, _kVioletLight]).createShader(b),
        child: const Text('VANI', style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w900,
          color: Colors.white, letterSpacing: 5))),
      Container(width: 1, height: 12,
          color: isDark ? _kBorderBrt : const Color(0xFFCCCCDD)),
      Text('© 2026 — Empowering Silence', style: TextStyle(
        fontSize: 11.5,
        color: isDark ? _kTextMuted : const Color(0xFFAAAAAACC),
        letterSpacing: 0.2)),
    ]),
  ]);
}

// ─────────────────────────────────────────────
//  SHARED BACKGROUND PRIMITIVES
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
          ? const Color(0xFF18182E).withOpacity(0.55)
          : const Color(0xFFE0E0EE).withOpacity(0.75)
      ..strokeWidth = 0.5;
    const step = 48.0;
    for (double x = 0; x < size.width;  x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    final dp = Paint()..color = _kViolet.withOpacity(isDark ? 0.10 : 0.06);
    for (double x = 0; x < size.width;  x += step)
      for (double y = 0; y < size.height; y += step)
        canvas.drawCircle(Offset(x, y), 1.0, dp);
  }
  @override bool shouldRepaint(_GridPainter o) => o.isDark != isDark;
}

class _Glow extends StatelessWidget {
  final Color color; final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
        child: const SizedBox.expand()));
}