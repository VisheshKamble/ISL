// lib/components/GlobalNavbar.dart
import 'package:flutter/material.dart';
import '../screens/TranslateScreen.dart';
import '../screens/SignsPage.dart';
import '../screens/EmergencyScreen.dart';
import '../screens/TwoWayScreen.dart';
import '../l10n/AppLocalizations.dart';

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
    final screenWidth   = MediaQuery.of(context).size.width;
    final currentLocale = Localizations.localeOf(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth > 900 ? 48 : 16,
        vertical: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0D0D1F).withOpacity(0.7)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Brand ──────────────────────────────────
          GestureDetector(
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primary, const Color(0xFF9D8FFF)],
                  ).createShader(bounds),
                  child: const Text(
                    "VANI",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Nav + Actions ───────────────────────────
          Row(
            children: [
              if (screenWidth > 750) ...[
                _NavLink(
                  label: l.t('nav_home'),
                  isActive: activeRoute == 'home',
                  onTap: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                ),
                _NavLink(
                  label: l.t('nav_terminal'),
                  isActive: activeRoute == 'translate',
                  onTap: () {
                    if (activeRoute != 'translate') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TranslateScreen(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                        ),
                      );
                    }
                  },
                ),
                _NavLink(
                  label: l.t('nav_signs'),
                  isActive: activeRoute == 'signs',
                  onTap: () {
                    if (activeRoute != 'signs') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => SignsPage(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  },
                ),
                // ── Two-Way Bridge link ──────────────
                _BridgeNavLink(
                  label: l.t('nav_bridge'),
                  isActive: activeRoute == 'bridge',
                  onTap: () {
                    if (activeRoute != 'bridge') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => TwoWayScreen(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  },
                ),
                // ── Emergency SOS link ───────────────
                _EmergencyNavLink(
                  isActive: activeRoute == 'emergency',
                  onTap: () {
                    if (activeRoute != 'emergency') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => EmergencyScreen(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  },
                ),
                _NavLink(label: l.t('nav_api')),
                const SizedBox(width: 6),
              ],

              // ── Mobile: compact icon buttons ────────
              if (screenWidth <= 750) ...[
                _MobileBridgeIcon(
                  isActive: activeRoute == 'bridge',
                  onTap: () {
                    if (activeRoute != 'bridge') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => TwoWayScreen(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  },
                ),
                _MobileEmergencyIcon(
                  isActive: activeRoute == 'emergency',
                  onTap: () {
                    if (activeRoute != 'emergency') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, a, __) => EmergencyScreen(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  },
                ),
              ],

              // Language Selector
              _LanguageDropdown(
                currentLocale: currentLocale,
                setLocale: setLocale,
                l: l,
                isDark: isDark,
                primary: primary,
              ),
              const SizedBox(width: 4),
              Container(
                  width: 1,
                  height: 20,
                  color: isDark ? Colors.white10 : Colors.black12),
              const SizedBox(width: 4),
              // Theme Toggle
              IconButton(
                onPressed: toggleTheme,
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                icon: Icon(
                  isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  BRIDGE NAV LINK — desktop (teal pill)
// ──────────────────────────────────────────────────────────────────
class _BridgeNavLink extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BridgeNavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_BridgeNavLink> createState() => _BridgeNavLinkState();
}

class _BridgeNavLinkState extends State<_BridgeNavLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0891B2);
    const tealLight = Color(0xFF22D3EE);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: widget.isActive
              ? teal.withOpacity(0.18)
              : teal.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isActive
                ? teal.withOpacity(0.55)
                : teal.withOpacity(0.2),
            width: widget.isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Icon(
                Icons.compare_arrows_rounded,
                color: tealLight.withOpacity(0.5 + _pulse.value * 0.5),
                size: 13,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: const TextStyle(
                color: tealLight,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  MOBILE BRIDGE ICON
// ──────────────────────────────────────────────────────────────────
class _MobileBridgeIcon extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _MobileBridgeIcon({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0891B2);
    const tealLight = Color(0xFF22D3EE);

    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: onTap,
        tooltip: 'Two-Way Communication',
        style: IconButton.styleFrom(
          backgroundColor: teal.withOpacity(isActive ? 0.18 : 0.08),
          side: BorderSide(
              color: teal.withOpacity(isActive ? 0.55 : 0.2)),
        ),
        icon: const Icon(
          Icons.compare_arrows_rounded,
          color: tealLight,
          size: 18,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  EMERGENCY NAV LINK — desktop (red pill with pulse dot)
// ──────────────────────────────────────────────────────────────────
class _EmergencyNavLink extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _EmergencyNavLink({
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_EmergencyNavLink> createState() => _EmergencyNavLinkState();
}

class _EmergencyNavLinkState extends State<_EmergencyNavLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const crimson = Color(0xFFDC2626);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: widget.isActive
              ? crimson.withOpacity(0.18)
              : crimson.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isActive
                ? crimson.withOpacity(0.6)
                : crimson.withOpacity(0.25),
            width: widget.isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: crimson,
                  boxShadow: [
                    BoxShadow(
                      color: crimson.withOpacity(_pulse.value * 0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              'SOS',
              style: TextStyle(
                color: crimson,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  MOBILE EMERGENCY ICON
// ──────────────────────────────────────────────────────────────────
class _MobileEmergencyIcon extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _MobileEmergencyIcon({
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_MobileEmergencyIcon> createState() => _MobileEmergencyIconState();
}

class _MobileEmergencyIconState extends State<_MobileEmergencyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const crimson = Color(0xFFDC2626);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Container(
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: crimson.withOpacity(_pulse.value * 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: child,
      ),
      child: IconButton(
        onPressed: widget.onTap,
        tooltip: 'Emergency SOS',
        style: IconButton.styleFrom(
          backgroundColor:
              crimson.withOpacity(widget.isActive ? 0.18 : 0.10),
          side: BorderSide(
              color: crimson.withOpacity(widget.isActive ? 0.6 : 0.3)),
        ),
        icon: const Icon(
          Icons.emergency_rounded,
          color: crimson,
          size: 18,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  LANGUAGE DROPDOWN
// ──────────────────────────────────────────────────────────────────
class _LanguageDropdown extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) setLocale;
  final AppLocalizations l;
  final bool isDark;
  final Color primary;

  const _LanguageDropdown({
    required this.currentLocale,
    required this.setLocale,
    required this.l,
    required this.isDark,
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
      orElse: () => langs[0],
    );

    return PopupMenuButton<String>(
      tooltip: l.t('nav_language'),
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1A1A3A) : Colors.white,
      elevation: 12,
      onSelected: (code) => setLocale(Locale(code)),
      itemBuilder: (context) => langs.map((lang) {
        final isSelected = lang['code'] == currentLocale.languageCode;
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Row(
            children: [
              Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 12),
              Text(
                lang['label']!,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? primary
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(Icons.check_rounded, color: primary, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current['flag']!, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              current['label']!,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, color: primary, size: 16),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  NAV LINK
// ──────────────────────────────────────────────────────────────────
class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavLink(
      {required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? primary
                : (isDark ? Colors.white54 : Colors.grey[600]),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}