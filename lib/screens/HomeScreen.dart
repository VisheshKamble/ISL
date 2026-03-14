//lib/screens/HomeScreen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../components/GlobalNavbar.dart';
import '../l10n/AppLocalizations.dart';
import 'TranslateScreen.dart';
import 'objectives/AccessibilityPage.dart';
import 'objectives/BridgingGapsPage.dart';
import 'objectives/InclusivityPage.dart';
import 'objectives/PrivacyPage.dart';
import 'objectives/OfflinePage.dart';
import 'objectives/EducationPage.dart';


//  DESIGN TOKENS

const _kViolet      = Color(0xFF7C3AED);
const _kVioletLight = Color(0xFFA78BFA);
const _kObsidian    = Color(0xFF050508);
const _kSurface     = Color(0xFF0C0C14);
const _kSurfaceUp   = Color(0xFF121220);
const _kBorder      = Color(0xFF1E1E30);
const _kBorderBrt   = Color(0xFF2E2E48);
const _kTextPri     = Color(0xFFF0EEFF);
const _kTextSec     = Color(0xFF7A7A9A);
const _kTextMuted   = Color(0xFF3A3A5A);
const _kCrimson     = Color(0xFFDC2626);
const _kAmber       = Color(0xFFD97706);

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const HomeScreen({super.key, required this.toggleTheme, required this.setLocale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _statsVisible = false;
  final GlobalKey _statsKey = GlobalKey();

  late AnimationController _heroCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _heroCtrl.forward();
    _scrollController.addListener(_checkScroll);
  }

  void _checkScroll() {
    if (_statsVisible) return;
    final obj = _statsKey.currentContext?.findRenderObject();
    if (obj is RenderBox) {
      final pos = obj.localToGlobal(Offset.zero).dy;
      if (pos < MediaQuery.of(context).size.height * 0.88) {
        setState(() => _statsVisible = true);
      }
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1100;
    final isTablet = w > 700 && w <= 1100;
    final hPad = isDesktop ? 96.0 : (isTablet ? 48.0 : 24.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? _kObsidian : const Color(0xFFF7F7FC),
      body: Stack(
        children: [
          Positioned.fill(child: _GridTexture(isDark: isDark)),
          Positioned(top: -200, left: -100,
              child: _AmbientGlow(color: _kViolet.withOpacity(isDark ? 0.22 : 0.10), size: 700)),
          Positioned(bottom: -300, right: -200,
              child: _AmbientGlow(color: const Color(0xFF1D4ED8).withOpacity(isDark ? 0.14 : 0.06), size: 600)),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  GlobalNavbar(toggleTheme: widget.toggleTheme, setLocale: widget.setLocale, activeRoute: 'home'),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(
                      children: [
                        SizedBox(height: isDesktop ? 80 : 50),
                        FadeTransition(
                          opacity: _heroFade,
                          child: SlideTransition(
                            position: _heroSlide,
                            child: Column(
                              children: [
                                _StatusChip(l: l, pulse: _pulse),
                                SizedBox(height: isDesktop ? 44 : 32),
                                _HeroText(isDesktop: isDesktop, isTablet: isTablet, l: l, isDark: isDark),
                                SizedBox(height: isDesktop ? 28 : 22),
                                _HeroSub(isDesktop: isDesktop, l: l, isDark: isDark),
                                SizedBox(height: isDesktop ? 52 : 40),
                                _CTARow(
                                  l: l,
                                  onLaunch: () => Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, a, __) => TranslateScreen(
                                          toggleTheme: widget.toggleTheme, setLocale: widget.setLocale),
                                      transitionsBuilder: (_, anim, __, child) =>
                                          FadeTransition(opacity: anim, child: child),
                                      transitionDuration: const Duration(milliseconds: 400),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 120 : 80),
                        _DividerLine(isDark: isDark),
                        SizedBox(height: isDesktop ? 80 : 60),
                        Container(key: _statsKey,
                            child: _StatsSection(isDesktop: isDesktop, isVisible: _statsVisible, l: l, isDark: isDark)),
                        SizedBox(height: isDesktop ? 120 : 80),
                        _SectionLabel(text: l.t('obj_heading'), sub: l.t('obj_sub'), isDark: isDark),
                        SizedBox(height: isDesktop ? 56 : 40),
                        _ObjectivesGrid(
                          isDesktop: isDesktop, isTablet: isTablet,
                          l: l, isDark: isDark,
                          toggleTheme: widget.toggleTheme, setLocale: widget.setLocale,
                        ),
                        SizedBox(height: isDesktop ? 120 : 80),
                        _VisionCard(l: l, isDark: isDark),
                        SizedBox(height: isDesktop ? 80 : 60),
                        _Footer(isDark: isDark),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


//  GRID TEXTURE

class _GridTexture extends StatelessWidget {
  final bool isDark;
  const _GridTexture({required this.isDark});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter(isDark: isDark));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF1A1A2E).withOpacity(0.6) : const Color(0xFFE8E8F0).withOpacity(0.8)
      ..strokeWidth = 0.5;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dp = Paint()..color = _kViolet.withOpacity(isDark ? 0.12 : 0.08);
    for (double x = 0; x < size.width; x += step)
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, dp);
      }
  }
  @override bool shouldRepaint(_) => false;
}


//  AMBIENT GLOW

class _AmbientGlow extends StatelessWidget {
  final Color color;
  final double size;
  const _AmbientGlow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 150, sigmaY: 150), child: const SizedBox.expand()),
  );
}


//  STATUS CHIP

class _StatusChip extends StatelessWidget {
  final AppLocalizations l;
  final Animation<double> pulse;
  const _StatusChip({required this.l, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isDark ? _kSurfaceUp : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: _kViolet.withOpacity(isDark ? 0.35 : 0.2)),
          boxShadow: [BoxShadow(color: _kViolet.withOpacity(pulse.value * (isDark ? 0.15 : 0.06)), blurRadius: 20)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(
              shape: BoxShape.circle, color: _kVioletLight,
              boxShadow: [BoxShadow(color: _kVioletLight.withOpacity(pulse.value * 0.8), blurRadius: 8, spreadRadius: 1)],
            )),
            const SizedBox(width: 10),
            Text(l.t('badge'), style: TextStyle(
              color: isDark ? _kVioletLight : _kViolet,
              fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.4,
            )),
          ],
        ),
      ),
    );
  }
}


//  HERO TEXT

class _HeroText extends StatelessWidget {
  final bool isDesktop, isTablet;
  final AppLocalizations l;
  final bool isDark;
  const _HeroText({required this.isDesktop, required this.isTablet, required this.l, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fontSize = isDesktop ? 72.0 : (isTablet ? 52.0 : 36.0);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900,
            color: isDark ? _kTextPri : const Color(0xFF0A0A1F), height: 1.08, letterSpacing: -2.0),
        children: [
          TextSpan(text: l.t('hero_title_1')),
          WidgetSpan(child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_kViolet, _kVioletLight, Color(0xFF60A5FA)], stops: [0.0, 0.6, 1.0],
            ).createShader(bounds),
            child: Text(l.t('hero_title_highlight'), style: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.w900,
              color: Colors.white, height: 1.08, letterSpacing: -2.0,
            )),
          )),
          TextSpan(text: l.t('hero_title_2')),
        ],
      ),
    );
  }
}

class _HeroSub extends StatelessWidget {
  final bool isDesktop;
  final AppLocalizations l;
  final bool isDark;
  const _HeroSub({required this.isDesktop, required this.l, required this.isDark});
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: isDesktop ? 580 : 480),
    child: Text(l.t('hero_sub'), textAlign: TextAlign.center, style: TextStyle(
      fontSize: isDesktop ? 17 : 15,
      color: isDark ? _kTextSec : const Color(0xFF5A5A7A), height: 1.8, letterSpacing: 0.1,
    )),
  );
}


//  CTA ROW

class _CTARow extends StatelessWidget {
  final AppLocalizations l;
  final VoidCallback onLaunch;
  const _CTARow({required this.l, required this.onLaunch});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [_LaunchButton(label: l.t('get_started'), onTap: onLaunch)],
  );
}

class _LaunchButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _LaunchButton({required this.label, required this.onTap});
  @override
  State<_LaunchButton> createState() => _LaunchButtonState();
}

class _LaunchButtonState extends State<_LaunchButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _hovered ? [const Color(0xFF8B5CF6), _kViolet] : [_kViolet, const Color(0xFF5B21B6)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kVioletLight.withOpacity(_hovered ? 0.4 : 0.1)),
          boxShadow: [BoxShadow(color: _kViolet.withOpacity(_hovered ? 0.55 : 0.30), blurRadius: _hovered ? 48 : 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
            const SizedBox(width: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              transform: Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
            ),
          ],
        ),
      ),
    ),
  );
}


//  DIVIDER

class _DividerLine extends StatelessWidget {
  final bool isDark;
  const _DividerLine({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(gradient: LinearGradient(colors: [
      Colors.transparent,
      isDark ? _kBorderBrt : const Color(0xFFD0D0E8),
      Colors.transparent,
    ])),
  );
}


//  STATS

class _StatsSection extends StatelessWidget {
  final bool isDesktop, isVisible;
  final AppLocalizations l;
  final bool isDark;
  const _StatsSection({required this.isDesktop, required this.isVisible, required this.l, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (value: '63000000', label: l.t('stat_mute_label'), color: _kVioletLight, suffix: '+'),
      (value: '8435000', label: l.t('stat_isl_label'), color: _kVioletLight, suffix: '+'),
      (value: '250', label: l.t('stat_translators_label'), color: _kCrimson, suffix: ''),
    ];
    return isDesktop
        ? IntrinsicHeight(
      child: Row(children: [
        for (int i = 0; i < stats.length; i++) ...[
          Expanded(child: _StatCell(value: stats[i].value, label: stats[i].label,
              color: stats[i].color, suffix: stats[i].suffix, isVisible: isVisible, isDark: isDark)),
          if (i < stats.length - 1) Container(width: 1, color: isDark ? _kBorder : const Color(0xFFDDDDEE)),
        ],
      ]),
    )
        : Column(children: stats.map((s) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _StatCell(value: s.value, label: s.label, color: s.color, suffix: s.suffix, isVisible: isVisible, isDark: isDark),
    )).toList());
  }
}

class _StatCell extends StatefulWidget {
  final String value, label, suffix;
  final Color color;
  final bool isVisible, isDark;
  const _StatCell({required this.value, required this.label, required this.color, required this.suffix, required this.isVisible, required this.isDark});
  @override
  State<_StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<_StatCell> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _anim = Tween<double>(begin: 0, end: double.parse(widget.value)).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo));
  }
  @override
  void didUpdateWidget(_StatCell old) {
    super.didUpdateWidget(old);
    if (widget.isVisible && !old.isVisible) _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
    child: AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: _fmt(_anim.value.toInt()), style: TextStyle(
            fontSize: 44, fontWeight: FontWeight.w900, color: widget.color,
            letterSpacing: -1.5, fontFeatures: const [FontFeature.tabularFigures()],
          )),
          TextSpan(text: widget.suffix, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: widget.color.withOpacity(0.6))),
        ])),
        const SizedBox(height: 10),
        Text(widget.label, textAlign: TextAlign.center, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: widget.isDark ? _kTextSec : const Color(0xFF6A6A8A), letterSpacing: 0.3,
        )),
      ]),
    ),
  );
}


//  SECTION LABEL

class _SectionLabel extends StatelessWidget {
  final String text, sub;
  final bool isDark;
  const _SectionLabel({required this.text, required this.sub, required this.isDark});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: _kViolet.withOpacity(0.3)), borderRadius: BorderRadius.circular(6)),
      child: Text('// OBJECTIVES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kViolet.withOpacity(0.8), letterSpacing: 2.0)),
    ),
    const SizedBox(height: 20),
    Text(text, textAlign: TextAlign.center, style: TextStyle(
      fontSize: 36, fontWeight: FontWeight.w900,
      color: isDark ? _kTextPri : const Color(0xFF0A0A1F), letterSpacing: -1.0, height: 1.1,
    )),
    const SizedBox(height: 12),
    Text(sub, style: TextStyle(fontSize: 14, color: isDark ? _kTextMuted : const Color(0xFF9A9AAA), letterSpacing: 0.2)),
  ]);
}


//  OBJECTIVES GRID — WITH NAVIGATION

class _ObjectivesGrid extends StatelessWidget {
  final bool isDesktop, isTablet;
  final AppLocalizations l;
  final bool isDark;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;

  const _ObjectivesGrid({
    required this.isDesktop, required this.isTablet, required this.l,
    required this.isDark, required this.toggleTheme, required this.setLocale,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      (icon: Icons.accessibility_new_rounded, title: l.t('obj_accessibility'), desc: l.t('obj_accessibility_desc'),
      color: const Color(0xFF7C3AED), page: AccessibilityPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (icon: Icons.connecting_airports_rounded, title: l.t('obj_bridging'), desc: l.t('obj_bridging_desc'),
      color: const Color(0xFF0284C7), page: BridgingGapsPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (icon: Icons.people_outline_rounded, title: l.t('obj_inclusivity'), desc: l.t('obj_inclusivity_desc'),
      color: const Color(0xFF059669), page: InclusivityPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (icon: Icons.shield_outlined, title: l.t('obj_privacy'), desc: l.t('obj_privacy_desc'),
      color: const Color(0xFFD97706), page: PrivacyPage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (icon: Icons.wifi_off_rounded, title: l.t('obj_offline'), desc: l.t('obj_offline_desc'),
      color: const Color(0xFF6366F1), page: OfflinePage(toggleTheme: toggleTheme, setLocale: setLocale)),
      (icon: Icons.school_rounded, title: l.t('obj_education'), desc: l.t('obj_education_desc'),
      color: const Color(0xFFDC2626), page: EducationPage(toggleTheme: toggleTheme, setLocale: setLocale)),
    ];

    // ── MOBILE: use a plain Column so each card sizes to its own content ──
    if (!isDesktop && !isTablet) {
      return Column(
        children: cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ObjCard(
            icon: c.icon, title: c.title, desc: c.desc,
            isDark: isDark, accent: c.color, page: c.page,
            isMobile: true,
          ),
        )).toList(),
      );
    }

    // ── TABLET / DESKTOP: keep original GridView (unchanged) ──
    final cols = isDesktop ? 3 : 2;
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols, mainAxisSpacing: 16, crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.65 : 1.5,
      children: cards.map((c) => _ObjCard(
        icon: c.icon, title: c.title, desc: c.desc,
        isDark: isDark, accent: c.color, page: c.page,
        isMobile: false,
      )).toList(),
    );
  }
}

class _ObjCard extends StatefulWidget {
  final IconData icon;
  final String title, desc;
  final bool isDark;
  final Color accent;
  final Widget page;
  final bool isMobile;
  const _ObjCard({required this.icon, required this.title, required this.desc,
    required this.isDark, required this.accent, required this.page, required this.isMobile});
  @override State<_ObjCard> createState() => _ObjCardState();
}

class _ObjCardState extends State<_ObjCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, a, __) => widget.page,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 350),
        )),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Mobile: no fixed height — wrap content naturally
          // Tablet/Desktop: keep original behaviour (GridView controls height)
          padding: EdgeInsets.all(widget.isMobile ? 20 : 28),
          decoration: BoxDecoration(
            color: widget.isDark
                ? (_hovered ? _kSurfaceUp : _kSurface)
                : (_hovered ? Colors.white : const Color(0xFFFAFAFC)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? widget.accent.withOpacity(0.45) : (widget.isDark ? _kBorder : const Color(0xFFE0E0EE)),
              width: _hovered ? 1.5 : 1.0,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.accent.withOpacity(widget.isDark ? 0.18 : 0.10), blurRadius: 40, offset: const Offset(0, 12))]
                : [if (!widget.isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Mobile: shrink-wrap; Tablet/Desktop: center vertically inside fixed-height grid cell
            mainAxisSize: widget.isMobile ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: widget.isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(widget.isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.accent.withOpacity(_hovered ? 0.4 : 0.15)),
                    ),
                    child: Icon(widget.icon, color: widget.accent, size: 20),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.arrow_forward_rounded, color: widget.accent, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(widget.title, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2,
                color: widget.isDark ? _kTextPri : const Color(0xFF0F0F2A),
              )),
              const SizedBox(height: 6),
              Text(widget.desc, style: TextStyle(
                fontSize: 13, height: 1.5,
                color: widget.isDark ? _kTextSec : const Color(0xFF6A6A8A),
              )),
              const SizedBox(height: 12),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text('Explore →', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: widget.accent, letterSpacing: 0.3,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VISION CARD
// ─────────────────────────────────────────────
class _VisionCard extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  const _VisionCard({required this.l, required this.isDark});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 40),
        decoration: BoxDecoration(
          color: isDark ? _kViolet.withOpacity(0.07) : _kViolet.withOpacity(0.04),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _kViolet.withOpacity(isDark ? 0.2 : 0.12)),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 40, height: 1, color: _kViolet.withOpacity(0.4)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kViolet.withOpacity(0.12), shape: BoxShape.circle,
                border: Border.all(color: _kViolet.withOpacity(0.3)),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: _kVioletLight, size: 26),
            ),
            const SizedBox(width: 16),
            Container(width: 40, height: 1, color: _kViolet.withOpacity(0.4)),
          ]),
          const SizedBox(height: 28),
          Text(l.t('vision_title'), textAlign: TextAlign.center, style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w800, color: _kVioletLight, letterSpacing: -0.5, height: 1.2,
          )),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(l.t('vision_body'), textAlign: TextAlign.center, style: TextStyle(
              fontSize: 15, color: isDark ? _kTextSec : const Color(0xFF5A5A7A), height: 1.8,
            )),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _kCrimson.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kCrimson.withOpacity(0.25)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: _kCrimson, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text('1 translator : 33,000+ people', style: TextStyle(
                color: _kCrimson.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3,
              )),
            ]),
          ),
        ]),
      ),
    ),
  );
}

//  FOOTER

class _Footer extends StatelessWidget {
  final bool isDark;
  const _Footer({required this.isDark});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [
      Colors.transparent, isDark ? _kBorder : const Color(0xFFDDDDEE), Colors.transparent,
    ]))),
    const SizedBox(height: 32),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(colors: [_kViolet, _kVioletLight]).createShader(b),
        child: const Text('VANI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 5)),
      ),
      const SizedBox(width: 24),
      Container(width: 1, height: 14, color: isDark ? _kBorderBrt : const Color(0xFFDDDDEE)),
      const SizedBox(width: 24),
      Text('© 2026 — Empowering Silence', style: TextStyle(
        fontSize: 12, color: isDark ? _kTextMuted : const Color(0xFFAAAAAA), letterSpacing: 0.3,
      )),
    ]),
  ]);
}