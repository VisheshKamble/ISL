// lib/components/GlobalNavbar.dart
import 'package:flutter/material.dart';
import '../screens/TranslateScreen.dart';
import '../screens/SignsPage.dart';
import '../screens/EmergencyScreen.dart';
import '../screens/TwoWayScreen.dart';
import '../l10n/AppLocalizations.dart';

// ── Breakpoints ──────────────────────────────
// > 750 → full desktop nav links shown
// ≤ 750 → compact mobile bar
const double _kDesktopBreak = 750;

class GlobalNavbar extends StatelessWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  final String activeRoute;

  const GlobalNavbar({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final primary       = Theme.of(context).primaryColor;
    final l             = AppLocalizations.of(context);
    final w             = MediaQuery.of(context).size.width;
    final currentLocale = Localizations.localeOf(context);
    final isMobile      = w <= _kDesktopBreak;

    // On mobile, tighter horizontal margin + less vertical padding
    final hMargin  = isMobile ? 12.0 : (w > 900 ? 48.0 : 16.0);
    final hPadding = isMobile ? 12.0 : 22.0;
    final vPadding = isMobile ? 10.0 : 14.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin, vertical: isMobile ? 12 : 20),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0A1C).withOpacity(0.85)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(isDark ? 0.10 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Brand ─────────────────────────────
          _Brand(primary: primary, context: context),

          // ── Right side ────────────────────────
          if (isMobile)
            _MobileActions(
              activeRoute:    activeRoute,
              toggleTheme:    toggleTheme,
              setLocale:      setLocale,
              currentLocale:  currentLocale,
              isDark:         isDark,
              primary:        primary,
              l:              l,
              context:        context,
            )
          else
            _DesktopActions(
              activeRoute:    activeRoute,
              toggleTheme:    toggleTheme,
              setLocale:      setLocale,
              currentLocale:  currentLocale,
              isDark:         isDark,
              primary:        primary,
              l:              l,
              context:        context,
            ),
        ],
      ),
    );
  }
}

// ── Brand ─────────────────────────────────────
class _Brand extends StatelessWidget {
  final Color primary;
  final BuildContext context;
  const _Brand({required this.primary, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () => Navigator.of(ctx).popUntil((r) => r.isFirst),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.35)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: [primary, const Color(0xFF9D8FFF)],
            ).createShader(b),
            child: Text(
              AppLocalizations.of(ctx).t('app_title_short'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Desktop actions ───────────────────────────
class _DesktopActions extends StatelessWidget {
  final String activeRoute;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  final Locale currentLocale;
  final bool isDark;
  final Color primary;
  final AppLocalizations l;
  final BuildContext context;

  const _DesktopActions({
    required this.activeRoute, required this.toggleTheme,
    required this.setLocale,  required this.currentLocale,
    required this.isDark,     required this.primary,
    required this.l,          required this.context,
  });

  void _push(BuildContext ctx, Widget screen) {
    Navigator.push(ctx, PageRouteBuilder(
      pageBuilder:      (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavLink(label: l.t('nav_home'), isActive: activeRoute == 'home',
            onTap: () => Navigator.of(ctx).popUntil((r) => r.isFirst)),
        _NavLink(label: l.t('nav_terminal'), isActive: activeRoute == 'translate',
            onTap: () { if (activeRoute != 'translate')
              _push(ctx, TranslateScreen(toggleTheme: toggleTheme, setLocale: setLocale)); }),
        _NavLink(label: l.t('nav_signs'), isActive: activeRoute == 'signs',
            onTap: () { if (activeRoute != 'signs')
              _push(ctx, SignsPage(toggleTheme: toggleTheme, setLocale: setLocale)); }),
        _BridgeNavLink(
          label: l.t('nav_bridge'), isActive: activeRoute == 'bridge',
          onTap: () { if (activeRoute != 'bridge')
            _push(ctx, TwoWayScreen(toggleTheme: toggleTheme, setLocale: setLocale)); }),
        _EmergencyNavLink(
          isActive: activeRoute == 'emergency',
          onTap: () { if (activeRoute != 'emergency')
            _push(ctx, EmergencyScreen(toggleTheme: toggleTheme, setLocale: setLocale)); }),
        _NavLink(label: l.t('nav_api')),
        const SizedBox(width: 8),
        _LanguageDropdown(currentLocale: currentLocale, setLocale: setLocale,
            l: l, isDark: isDark, primary: primary),
        const SizedBox(width: 4),
        _Divider(isDark: isDark),
        const SizedBox(width: 4),
        _ThemeToggle(isDark: isDark, onTap: toggleTheme),
      ],
    );
  }
}

// ── Mobile actions ─────────────────────────────
// Key fix: on mobile we show ONLY icon buttons (no text labels),
// a compact flag-only language picker, and the theme toggle.
// This eliminates overflow completely.
class _MobileActions extends StatelessWidget {
  final String activeRoute;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  final Locale currentLocale;
  final bool isDark;
  final Color primary;
  final AppLocalizations l;
  final BuildContext context;

  const _MobileActions({
    required this.activeRoute, required this.toggleTheme,
    required this.setLocale,  required this.currentLocale,
    required this.isDark,     required this.primary,
    required this.l,          required this.context,
  });

  void _push(BuildContext ctx, Widget screen) {
    Navigator.push(ctx, PageRouteBuilder(
      pageBuilder:      (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bridge icon
        _MobileIconBtn(
          icon: Icons.compare_arrows_rounded,
          color: const Color(0xFF22D3EE),
          bgColor: const Color(0xFF0891B2).withOpacity(activeRoute == 'bridge' ? 0.18 : 0.08),
          borderColor: const Color(0xFF0891B2).withOpacity(activeRoute == 'bridge' ? 0.55 : 0.2),
          tooltip: l.t('bridge_screen_title'),
          onTap: () { if (activeRoute != 'bridge')
            _push(ctx, TwoWayScreen(toggleTheme: toggleTheme, setLocale: setLocale)); },
        ),
        const SizedBox(width: 4),
        // SOS icon
        _MobileSOSBtn(isActive: activeRoute == 'emergency',
          onTap: () { if (activeRoute != 'emergency')
            _push(ctx, EmergencyScreen(toggleTheme: toggleTheme, setLocale: setLocale)); }),
        const SizedBox(width: 4),
        // Language — flag only on mobile (no text)
        _MobileLangBtn(
            currentLocale: currentLocale,
            setLocale: setLocale,
            isDark: isDark,
            primary: primary),
        const SizedBox(width: 2),
        _ThemeToggle(isDark: isDark, onTap: toggleTheme),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 18,
    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.10),
  );
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _ThemeToggle({required this.isDark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 17,
          color: isDark ? Colors.white.withOpacity(0.55) : Colors.black.withOpacity(0.45),
        ),
      ),
    ),
  );
}

// Generic mobile icon button — no label, fixed 34×34
class _MobileIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color, bgColor, borderColor;
  final String tooltip;
  final VoidCallback onTap;
  const _MobileIconBtn({
    required this.icon, required this.color,
    required this.bgColor, required this.borderColor,
    required this.tooltip, required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Center(child: Icon(icon, color: color, size: 16)),
      ),
    ),
  );
}

// SOS mobile button with pulse
class _MobileSOSBtn extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _MobileSOSBtn({required this.isActive, required this.onTap});
  @override
  State<_MobileSOSBtn> createState() => _MobileSOSBtnState();
}
class _MobileSOSBtnState extends State<_MobileSOSBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.75)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const c = Color(0xFFDC2626);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: c.withOpacity(widget.isActive ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.withOpacity(widget.isActive ? 0.6 : 0.3)),
            boxShadow: [BoxShadow(
              color: c.withOpacity(_anim.value * 0.35),
              blurRadius: 8, spreadRadius: 0)],
          ),
          child: Center(
            child: Text(AppLocalizations.of(context).t('nav_emergency'),
              style: TextStyle(
                color: c, fontSize: 8.5,
                fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        ),
      ),
    );
  }
}

// Language selector — mobile shows flag only, desktop shows flag + label
class _MobileLangBtn extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) setLocale;
  final bool isDark;
  final Color primary;
  const _MobileLangBtn({
    required this.currentLocale, required this.setLocale,
    required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) {
    final langs = [
      {'code': 'en', 'flag': '🇬🇧'},
      {'code': 'hi', 'flag': '🇮🇳'},
      {'code': 'mr', 'flag': '🇮🇳'},
    ];
    final current = langs.firstWhere(
      (l) => l['code'] == currentLocale.languageCode,
      orElse: () => langs[0]);

    return PopupMenuButton<String>(
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? const Color(0xFF141428) : Colors.white,
      elevation: 10,
      onSelected: (code) => setLocale(Locale(code)),
      itemBuilder: (_) => langs.map((lang) => PopupMenuItem<String>(
        value: lang['code'],
        child: Row(children: [
          Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(lang['code']!.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13,
              color: lang['code'] == currentLocale.languageCode
                  ? primary
                  : (isDark ? Colors.white70 : Colors.black87))),
          if (lang['code'] == currentLocale.languageCode) ...[
            const Spacer(),
            Icon(Icons.check_rounded, color: primary, size: 14),
          ],
        ]),
      )).toList(),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.18)),
        ),
        child: Center(
          child: Text(current['flag']!, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BRIDGE NAV LINK (desktop)
// ─────────────────────────────────────────────
class _BridgeNavLink extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _BridgeNavLink({required this.label, required this.isActive, required this.onTap});
  @override
  State<_BridgeNavLink> createState() => _BridgeNavLinkState();
}
class _BridgeNavLinkState extends State<_BridgeNavLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0891B2);
    const tealL = Color(0xFF22D3EE);
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isActive ? teal.withOpacity(0.18) : teal.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isActive ? teal.withOpacity(0.55) : teal.withOpacity(0.18),
            width: widget.isActive ? 1.5 : 1.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _a,
            builder: (_, __) => Icon(Icons.compare_arrows_rounded,
              color: tealL.withOpacity(0.45 + _a.value * 0.55), size: 12)),
          const SizedBox(width: 5),
          Text(widget.label,
            style: const TextStyle(color: tealL, fontWeight: FontWeight.w800,
                fontSize: 11, letterSpacing: 0.8)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMERGENCY NAV LINK (desktop)
// ─────────────────────────────────────────────
class _EmergencyNavLink extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _EmergencyNavLink({required this.isActive, required this.onTap});
  @override
  State<_EmergencyNavLink> createState() => _EmergencyNavLinkState();
}
class _EmergencyNavLinkState extends State<_EmergencyNavLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const crimson = Color(0xFFDC2626);
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isActive ? crimson.withOpacity(0.18) : crimson.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isActive ? crimson.withOpacity(0.6) : crimson.withOpacity(0.22),
            width: widget.isActive ? 1.5 : 1.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _a,
            builder: (_, __) => Container(
              width: 5, height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: crimson,
                boxShadow: [BoxShadow(
                  color: crimson.withOpacity(_a.value * 0.8),
                  blurRadius: 5, spreadRadius: 1)]),
            )),
          const SizedBox(width: 6),
          Text(l.t('nav_emergency'),
            style: const TextStyle(color: crimson, fontWeight: FontWeight.w900,
                fontSize: 11, letterSpacing: 1.3)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LANGUAGE DROPDOWN (desktop)
// ─────────────────────────────────────────────
class _LanguageDropdown extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) setLocale;
  final AppLocalizations l;
  final bool isDark;
  final Color primary;
  const _LanguageDropdown({
    required this.currentLocale, required this.setLocale,
    required this.l,            required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final langs = [
      {'code': 'en', 'label': l.t('lang_en'), 'flag': '🇬🇧'},
      {'code': 'hi', 'label': l.t('lang_hi'), 'flag': '🇮🇳'},
      {'code': 'mr', 'label': l.t('lang_mr'), 'flag': '🇮🇳'},
    ];
    final current = langs.firstWhere(
      (lang) => lang['code'] == currentLocale.languageCode,
      orElse: () => langs[0]);

    return PopupMenuButton<String>(
      tooltip: l.t('nav_language'),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? const Color(0xFF141428) : Colors.white,
      elevation: 10,
      onSelected: (code) => setLocale(Locale(code)),
      itemBuilder: (_) => langs.map((lang) {
        final sel = lang['code'] == currentLocale.languageCode;
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Row(children: [
            Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(lang['label']!, style: TextStyle(
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
              color: sel ? primary : (isDark ? Colors.white70 : Colors.black87))),
            if (sel) ...[
              const Spacer(),
              Icon(Icons.check_rounded, color: primary, size: 14)],
          ]),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.14)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(current['flag']!, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(current['label']!, style: TextStyle(
            color: primary, fontWeight: FontWeight.w700,
            fontSize: 11, letterSpacing: 0.4)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: primary, size: 14),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAV LINK (desktop text link)
// ─────────────────────────────────────────────
class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const _NavLink({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? primary : (isDark ? Colors.white.withOpacity(0.5) : Colors.grey[600]),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11.5,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}