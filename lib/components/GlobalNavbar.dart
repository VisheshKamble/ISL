// lib/components/GlobalNavbar.dart
// ─────────────────────────────────────────────────────────────────
//  UPDATED: Added "SIGNS" nav link → navigates to SignsPage
// ─────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../screens/TranslateScreen.dart';
import '../screens/SignsPage.dart';          // ← NEW
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
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final primary  = Theme.of(context).primaryColor;
    final l        = AppLocalizations.of(context);
    final screenWidth  = MediaQuery.of(context).size.width;
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
                          builder: (context) => TranslateScreen(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                        ),
                      );
                    }
                  },
                ),
                // ── NEW: Signs link ──────────────────
                _NavLink(
                  label: l.t('nav_signs'),
                  isActive: activeRoute == 'signs',
                  onTap: () {
                    if (activeRoute != 'signs') {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, a, _) => SignsPage(
                            toggleTheme: toggleTheme,
                            setLocale: setLocale,
                          ),
                          transitionsBuilder: (_, anim, _, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  },
                ),
                // ────────────────────────────────────
                _NavLink(label: l.t('nav_api')),
                const SizedBox(width: 6),
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
//  LANGUAGE DROPDOWN  (unchanged)
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
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current['flag']!,
                style: const TextStyle(fontSize: 14)),
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
            Icon(Icons.keyboard_arrow_down_rounded,
                color: primary, size: 16),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  NAV LINK  (unchanged)
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