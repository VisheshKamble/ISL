// lib/screens/SignsPage.dart
// ─────────────────────────────────────────────────────────────────────────────
// VANI — ISL Signs Library (responsive + overflow fixed version)
// Last updated: responsive card aspect, smaller elements on phone, compact chips
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../components/GlobalNavbar.dart';
import '../l10n/AppLocalizations.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
const _kViolet         = Color(0xFF7C3AED);
const _kVioletLight    = Color(0xFFA78BFA);
const _kVioletGlow     = Color(0xFF6D28D9);
const _kObsidian       = Color(0xFF050508);
const _kSurface        = Color(0xFF0C0C14);
const _kSurfaceUp      = Color(0xFF111120);
const _kSurfaceHigh    = Color(0xFF181830);
const _kBorder         = Color(0xFF1E1E32);
const _kTextPri        = Color(0xFFF0EEFF);
const _kTextSec        = Color(0xFF8888AA);
const _kTextMuted      = Color(0xFF5A5A74);

const _kAccentAlphabet = Color(0xFF7C3AED);
const _kAccentNumbers  = Color(0xFFD97706);
const _kAccentWords    = Color(0xFF0891B2);

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class _SignEntry {
  final String placeholder;
  final String nameKey;
  final String meaningKey;
  final String descKey;
  final String categoryKey;
  final Color  accent;

  const _SignEntry({
    required this.placeholder,
    required this.nameKey,
    required this.meaningKey,
    required this.descKey,
    required this.categoryKey,
    required this.accent,
  });
}

// ─────────────────────────────────────────────
// SIGN DATA
// ─────────────────────────────────────────────
const List<_SignEntry> _kSigns = [
  // ALPHABET (26)
  _SignEntry(placeholder: 'A', nameKey: 'sign_a_name', meaningKey: 'sign_a_meaning', descKey: 'sign_a_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'B', nameKey: 'sign_b_name', meaningKey: 'sign_b_meaning', descKey: 'sign_b_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'C', nameKey: 'sign_c_name', meaningKey: 'sign_c_meaning', descKey: 'sign_c_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'D', nameKey: 'sign_d_name', meaningKey: 'sign_d_meaning', descKey: 'sign_d_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'E', nameKey: 'sign_e_name', meaningKey: 'sign_e_meaning', descKey: 'sign_e_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'F', nameKey: 'sign_f_name', meaningKey: 'sign_f_meaning', descKey: 'sign_f_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'G', nameKey: 'sign_g_name', meaningKey: 'sign_g_meaning', descKey: 'sign_g_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'H', nameKey: 'sign_h_name', meaningKey: 'sign_h_meaning', descKey: 'sign_h_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'I', nameKey: 'sign_i_name', meaningKey: 'sign_i_meaning', descKey: 'sign_i_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'J', nameKey: 'sign_j_name', meaningKey: 'sign_j_meaning', descKey: 'sign_j_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'K', nameKey: 'sign_k_name', meaningKey: 'sign_k_meaning', descKey: 'sign_k_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'L', nameKey: 'sign_l_name', meaningKey: 'sign_l_meaning', descKey: 'sign_l_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'M', nameKey: 'sign_m_name', meaningKey: 'sign_m_meaning', descKey: 'sign_m_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'N', nameKey: 'sign_n_name', meaningKey: 'sign_n_meaning', descKey: 'sign_n_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'O', nameKey: 'sign_o_name', meaningKey: 'sign_o_meaning', descKey: 'sign_o_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'P', nameKey: 'sign_p_name', meaningKey: 'sign_p_meaning', descKey: 'sign_p_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'Q', nameKey: 'sign_q_name', meaningKey: 'sign_q_meaning', descKey: 'sign_q_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'R', nameKey: 'sign_r_name', meaningKey: 'sign_r_meaning', descKey: 'sign_r_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'S', nameKey: 'sign_s_name', meaningKey: 'sign_s_meaning', descKey: 'sign_s_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'T', nameKey: 'sign_t_name', meaningKey: 'sign_t_meaning', descKey: 'sign_t_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'U', nameKey: 'sign_u_name', meaningKey: 'sign_u_meaning', descKey: 'sign_u_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'V', nameKey: 'sign_v_name', meaningKey: 'sign_v_meaning', descKey: 'sign_v_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'W', nameKey: 'sign_w_name', meaningKey: 'sign_w_meaning', descKey: 'sign_w_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'X', nameKey: 'sign_x_name', meaningKey: 'sign_x_meaning', descKey: 'sign_x_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'Y', nameKey: 'sign_y_name', meaningKey: 'sign_y_meaning', descKey: 'sign_y_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),
  _SignEntry(placeholder: 'Z', nameKey: 'sign_z_name', meaningKey: 'sign_z_meaning', descKey: 'sign_z_desc', categoryKey: 'cat_alphabet', accent: _kAccentAlphabet),

  // NUMBERS (10)
  _SignEntry(placeholder: '0', nameKey: 'sign_0_name', meaningKey: 'sign_0_meaning', descKey: 'sign_0_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '1', nameKey: 'sign_1_name', meaningKey: 'sign_1_meaning', descKey: 'sign_1_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '2', nameKey: 'sign_2_name', meaningKey: 'sign_2_meaning', descKey: 'sign_2_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '3', nameKey: 'sign_3_name', meaningKey: 'sign_3_meaning', descKey: 'sign_3_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '4', nameKey: 'sign_4_name', meaningKey: 'sign_4_meaning', descKey: 'sign_4_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '5', nameKey: 'sign_5_name', meaningKey: 'sign_5_meaning', descKey: 'sign_5_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '6', nameKey: 'sign_6_name', meaningKey: 'sign_6_meaning', descKey: 'sign_6_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '7', nameKey: 'sign_7_name', meaningKey: 'sign_7_meaning', descKey: 'sign_7_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '8', nameKey: 'sign_8_name', meaningKey: 'sign_8_meaning', descKey: 'sign_8_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),
  _SignEntry(placeholder: '9', nameKey: 'sign_9_name', meaningKey: 'sign_9_meaning', descKey: 'sign_9_desc', categoryKey: 'cat_numbers', accent: _kAccentNumbers),

  // WORDS (20)
  _SignEntry(placeholder: 'Namaste', nameKey: 'sign_namaste_name', meaningKey: 'sign_namaste_meaning', descKey: 'sign_namaste_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Hello', nameKey: 'sign_hello_name', meaningKey: 'sign_hello_meaning', descKey: 'sign_hello_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Hi', nameKey: 'sign_hi_name', meaningKey: 'sign_hi_meaning', descKey: 'sign_hi_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'How are you?', nameKey: 'sign_howareyou_name', meaningKey: 'sign_howareyou_meaning', descKey: 'sign_howareyou_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Quiet', nameKey: 'sign_quiet_name', meaningKey: 'sign_quiet_meaning', descKey: 'sign_quiet_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Thanks', nameKey: 'sign_thanks_name', meaningKey: 'sign_thanks_meaning', descKey: 'sign_thanks_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Food', nameKey: 'sign_food_name', meaningKey: 'sign_food_meaning', descKey: 'sign_food_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'I love you', nameKey: 'sign_iloveyou_name', meaningKey: 'sign_iloveyou_meaning', descKey: 'sign_iloveyou_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Brother', nameKey: 'sign_brother_name', meaningKey: 'sign_brother_meaning', descKey: 'sign_brother_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Father', nameKey: 'sign_father_name', meaningKey: 'sign_father_meaning', descKey: 'sign_father_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Mother', nameKey: 'sign_mother_name', meaningKey: 'sign_mother_meaning', descKey: 'sign_mother_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Water', nameKey: 'sign_water_name', meaningKey: 'sign_water_meaning', descKey: 'sign_water_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'What?', nameKey: 'sign_what_name', meaningKey: 'sign_what_meaning', descKey: 'sign_what_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Please', nameKey: 'sign_please_name', meaningKey: 'sign_please_meaning', descKey: 'sign_please_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Help', nameKey: 'sign_help_name', meaningKey: 'sign_help_meaning', descKey: 'sign_help_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Sorry', nameKey: 'sign_sorry_name', meaningKey: 'sign_sorry_meaning', descKey: 'sign_sorry_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Good', nameKey: 'sign_good_name', meaningKey: 'sign_good_meaning', descKey: 'sign_good_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Bad', nameKey: 'sign_bad_name', meaningKey: 'sign_bad_meaning', descKey: 'sign_bad_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Today', nameKey: 'sign_today_name', meaningKey: 'sign_today_meaning', descKey: 'sign_today_desc', categoryKey: 'cat_words', accent: _kAccentWords),
  _SignEntry(placeholder: 'Time', nameKey: 'sign_time_name', meaningKey: 'sign_time_meaning', descKey: 'sign_time_desc', categoryKey: 'cat_words', accent: _kAccentWords),
];

// ─────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────
class SignsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;

  const SignsPage({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
  });

  @override
  State<SignsPage> createState() => _SignsPageState();
}

class _SignsPageState extends State<SignsPage> with TickerProviderStateMixin {
  String _cat = 'all';
  String _query = '';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_SignEntry> _filtered(AppLocalizations l) {
    return _kSigns.where((s) {
      final matchCat = _cat == 'all' || s.categoryKey == _cat;
      final q = _query.toLowerCase().trim();
      final matchQ = q.isEmpty ||
          l.t(s.nameKey).toLowerCase().contains(q) ||
          l.t(s.meaningKey).toLowerCase().contains(q) ||
          l.t(s.categoryKey).toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    final isDesktop = width > 1100;
    final isTablet  = width > 680 && width <= 1100;
    final isPhone   = width <= 680;

    final hPad = isDesktop ? 88.0 : (isTablet ? 44.0 : 16.0);

    final filtered = _filtered(l);

    return Scaffold(
      backgroundColor: isDark ? _kObsidian : const Color(0xFFF9FAFF),
      body: Stack(
        children: [
          Positioned.fill(child: _GridTexture(isDark: isDark)),
          Positioned(top: -220, right: -140, child: _Glow(color: _kViolet.withOpacity(isDark ? 0.16 : 0.07), size: 680)),
          Positioned(bottom: -180, left: -110, child: _Glow(color: const Color(0xFF0891B2).withOpacity(isDark ? 0.10 : 0.05), size: 520)),

          SafeArea(
            child: Column(
              children: [
                GlobalNavbar(
                  toggleTheme: widget.toggleTheme,
                  setLocale: widget.setLocale,
                  activeRoute: 'signs',
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isPhone ? 24 : 40),
                            _Header(isDark: isDark, l: l),
                            SizedBox(height: isPhone ? 24 : 32),
                            _SearchField(
                              isDark: isDark,
                              ctrl: _searchCtrl,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                            SizedBox(height: isPhone ? 16 : 20),
                            _FilterRow(
                              isDark: isDark,
                              selected: _cat,
                              l: l,
                              onSelect: (c) {
                                setState(() => _cat = c);
                                _fadeCtrl.forward(from: 0.0);
                              },
                              isPhone: isPhone,
                            ),
                            SizedBox(height: isPhone ? 20 : 28),
                            if (filtered.isNotEmpty)
                              _CountRow(
                                count: filtered.length,
                                total: _kSigns.length,
                                isDark: isDark,
                                l: l,
                              ),
                            SizedBox(height: isPhone ? 12 : 16),
                            if (filtered.isEmpty)
                              _EmptyState(isDark: isDark, l: l)
                            else
                              _Grid(
                                signs: filtered,
                                isDark: isDark,
                                l: l,
                                isDesktop: isDesktop,
                                isTablet: isTablet,
                                isPhone: isPhone,
                              ),
                            SizedBox(height: isPhone ? 60 : 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const _Header({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: _kViolet.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(colors: [_kViolet.withOpacity(0.06), _kVioletGlow.withOpacity(0.02)]),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: _kVioletLight)),
              const SizedBox(width: 8),
              Text(
                'ISL SIGNS LIBRARY',
                style: TextStyle(fontSize: 10.2, fontWeight: FontWeight.w800, color: _kVioletLight, letterSpacing: 2.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              height: 1.08,
              letterSpacing: -1.6,
              color: isDark ? _kTextPri : const Color(0xFF0F0F24),
            ),
            children: [
              TextSpan(text: l.t('signs_title_1')),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [_kViolet, _kVioletLight, Color(0xFF38BDF8)],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    l.t('signs_title_highlight'),
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(
            l.t('signs_subtitle'),
            style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? _kTextSec : const Color(0xFF5F5F7F)),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Pill(n: '${_kSigns.length}', label: l.t('signs_stat_total'), color: _kViolet, isDark: isDark),
            _Pill(n: '26', label: l.t('signs_stat_alphabet'), color: _kAccentAlphabet, isDark: isDark),
            _Pill(n: '10', label: l.t('signs_stat_numbers'), color: _kAccentNumbers, isDark: isDark),
            _Pill(
              n: '${_kSigns.where((e) => e.categoryKey == 'cat_words').length}',
              label: l.t('signs_stat_words'),
              color: _kAccentWords,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String n;
  final String label;
  final Color color;
  final bool isDark;

  const _Pill({required this.n, required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? _kSurfaceUp : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(isDark ? 0.07 : 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 5)],
            ),
          ),
          const SizedBox(width: 9),
          Text(
            n,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? _kTextPri : const Color(0xFF0A0A20)),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: isDark ? _kTextSec : const Color(0xFF767694)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH FIELD
// ─────────────────────────────────────────────
class _SearchField extends StatefulWidget {
  final bool isDark;
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.isDark,
    required this.ctrl,
    required this.onChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: widget.isDark ? _kSurfaceUp : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _focused ? _kViolet.withOpacity(0.55) : (widget.isDark ? _kBorder : const Color(0xFFE2E2F0)),
            width: _focused ? 1.4 : 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: _kViolet.withOpacity(0.11), blurRadius: 20, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: widget.ctrl,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: widget.isDark ? _kTextPri : const Color(0xFF0B0B22),
            fontSize: 14.2,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: l.t('signs_search_hint'),
            hintStyle: TextStyle(color: widget.isDark ? _kTextMuted : Colors.grey[400], fontSize: 14.2),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.search_rounded,
                color: _focused ? _kVioletLight : (widget.isDark ? _kTextSec : Colors.grey[500]),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: widget.ctrl.text.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark ? _kSurfaceHigh : Colors.grey[100],
                      ),
                      child: Icon(Icons.close_rounded, color: widget.isDark ? _kTextSec : Colors.grey[600], size: 14),
                    ),
                    onPressed: () {
                      widget.ctrl.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 0),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTER ROW + CHIP (compact on phone)
// ─────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final bool isDark;
  final String selected;
  final AppLocalizations l;
  final ValueChanged<String> onSelect;
  final bool isPhone;

  const _FilterRow({
    required this.isDark,
    required this.selected,
    required this.l,
    required this.onSelect,
    required this.isPhone,
  });

  static const _icons = <String, IconData>{
    'all': Icons.apps_rounded,
    'cat_alphabet': Icons.sort_by_alpha_rounded,
    'cat_numbers': Icons.tag_rounded,
    'cat_words': Icons.record_voice_over_rounded,
  };

  static const _colors = <String, Color>{
    'all': _kViolet,
    'cat_alphabet': _kAccentAlphabet,
    'cat_numbers': _kAccentNumbers,
    'cat_words': _kAccentWords,
  };

  @override
  Widget build(BuildContext context) {
    final cats = ['all', 'cat_alphabet', 'cat_numbers', 'cat_words'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: cats.map((cat) {
          final color = _colors[cat] ?? _kViolet;
          final count = cat == 'all' ? _kSigns.length : _kSigns.where((s) => s.categoryKey == cat).length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              isDark: isDark,
              isActive: selected == cat,
              label: cat == 'all' ? l.t('cat_all') : l.t(cat),
              icon: _icons[cat] ?? Icons.label_rounded,
              color: color,
              count: count,
              onTap: () => onSelect(cat),
              isPhone: isPhone,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Chip extends StatefulWidget {
  final bool isDark;
  final bool isActive;
  final bool isPhone;
  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _Chip({
    required this.isDark,
    required this.isActive,
    required this.isPhone,
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isPhone ? 12.0 : 16.0;
    final fontSizeLabel = widget.isPhone ? 11.5 : 12.2;
    final verticalPadding = widget.isPhone ? 8.0 : 11.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? LinearGradient(
                    colors: [widget.color, widget.color.withOpacity(0.82)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isActive
                ? null
                : (_hover ? widget.color.withOpacity(0.07) : (widget.isDark ? _kSurfaceUp : Colors.white)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive ? Colors.transparent : widget.color.withOpacity(_hover ? 0.4 : 0.20),
              width: 1.2,
            ),
            boxShadow: widget.isActive
                ? [BoxShadow(color: widget.color.withOpacity(0.30), blurRadius: 14, offset: const Offset(0, 4))]
                : _hover
                    ? [BoxShadow(color: widget.color.withOpacity(0.09), blurRadius: 8, offset: const Offset(0, 2))]
                    : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: widget.isActive ? Colors.white : (widget.isDark ? _kTextSec : const Color(0xFF6C6C8C)),
              ),
              SizedBox(width: widget.isPhone ? 6 : 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSizeLabel,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: widget.isActive ? Colors.white : (widget.isDark ? _kTextSec : const Color(0xFF6C6C8C)),
                ),
              ),
              SizedBox(width: widget.isPhone ? 6 : 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: widget.isActive ? Colors.white.withOpacity(0.24) : widget.color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: widget.isPhone ? 10 : 10.5,
                    fontWeight: FontWeight.w900,
                    color: widget.isActive ? Colors.white : widget.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COUNT ROW
// ─────────────────────────────────────────────
class _CountRow extends StatelessWidget {
  final int count;
  final int total;
  final bool isDark;
  final AppLocalizations l;

  const _CountRow({
    required this.count,
    required this.total,
    required this.isDark,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [_kViolet, _kVioletLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          count == total
              ? l.t('signs_showing_all').replaceAll('{n}', '$total')
              : l.t('signs_showing_filtered').replaceAll('{n}', '$count').replaceAll('{total}', '$total'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? _kTextSec : const Color(0xFF767694),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// GRID
// ─────────────────────────────────────────────
class _Grid extends StatelessWidget {
  final List<_SignEntry> signs;
  final bool isDark;
  final AppLocalizations l;
  final bool isDesktop;
  final bool isTablet;
  final bool isPhone;

  const _Grid({
    required this.signs,
    required this.isDark,
    required this.l,
    required this.isDesktop,
    required this.isTablet,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final columns = isDesktop ? 6 : (isTablet ? 4 : 2);

    final aspectRatio = isPhone ? 0.78 : (isTablet ? 0.82 : 0.86);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: isPhone ? 16 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: isPhone ? 12 : 16,
        crossAxisSpacing: isPhone ? 12 : 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: signs.length,
      itemBuilder: (context, index) => _Card(
        entry: signs[index],
        isDark: isDark,
        l: l,
        isPhone: isPhone,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CARD (FRONT + BACK)
// ─────────────────────────────────────────────
class _Card extends StatefulWidget {
  final _SignEntry entry;
  final bool isDark;
  final AppLocalizations l;
  final bool isPhone;

  const _Card({
    required this.entry,
    required this.isDark,
    required this.l,
    required this.isPhone,
  });

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubicEmphasized);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip(bool showBack) {
    if (showBack && !_flipped) {
      _ctrl.forward();
      _flipped = true;
    } else if (!showBack && _flipped) {
      _ctrl.reverse();
      _flipped = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _flip(true),
      onExit: (_) => _flip(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _flip(!_flipped),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            final angle = _anim.value * math.pi;
            final showBack = _anim.value > 0.5;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: showBack
                  ? Transform(
                      transform: Matrix4.identity()..rotateY(math.pi),
                      alignment: Alignment.center,
                      child: _Back(entry: widget.entry, isDark: widget.isDark, l: widget.l, isPhone: widget.isPhone),
                    )
                  : _Front(entry: widget.entry, isDark: widget.isDark, l: widget.l, isPhone: widget.isPhone),
            );
          },
        ),
      ),
    );
  }
}

class _Front extends StatelessWidget {
  final _SignEntry entry;
  final bool isDark;
  final AppLocalizations l;
  final bool isPhone;

  const _Front({
    required this.entry,
    required this.isDark,
    required this.l,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = isPhone ? 72.0 : 90.0;
    final letterSize = isPhone
        ? (entry.placeholder.length > 6 ? 22 : 32)
        : (entry.placeholder.length > 6 ? 28 : 40);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? _kSurface : Colors.white,
        border: Border.all(color: isDark ? _kBorder : const Color(0xFFE8E8F4), width: 1),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withOpacity(0.26), blurRadius: 16, offset: const Offset(0, 4))]
            : [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
                BoxShadow(color: entry.accent.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 5)),
              ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, entry.accent.withOpacity(0.38), Colors.transparent]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isPhone ? 8 : 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: entry.accent.withOpacity(isDark ? 0.13 : 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: entry.accent.withOpacity(isDark ? 0.28 : 0.16)),
                  ),
                  child: Text(
                    l.t(entry.categoryKey),
                    style: TextStyle(
                      fontSize: isPhone ? 8.5 : 9.5,
                      fontWeight: FontWeight.w800,
                      color: entry.accent.withOpacity(isDark ? 0.9 : 0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: isPhone ? 12 : 20),
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [entry.accent.withOpacity(isDark ? 0.18 : 0.09), entry.accent.withOpacity(0.02)]),
                    border: Border.all(color: entry.accent.withOpacity(isDark ? 0.32 : 0.18), width: 1.3),
                    boxShadow: [BoxShadow(color: entry.accent.withOpacity(isDark ? 0.15 : 0.08), blurRadius: 14, spreadRadius: 0.5)],
                  ),
                  child: Center(
                    child: Text(
                      entry.placeholder,
                      style: TextStyle(
                        fontSize: letterSize.toDouble(),
                        fontWeight: FontWeight.w900,
                        color: entry.accent,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isPhone ? 12 : 20),
                Text(
                  l.t(entry.nameKey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isPhone ? 12.5 : 14,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: isDark ? _kTextPri : const Color(0xFF0E0E2A),
                  ),
                ),
                SizedBox(height: isPhone ? 6 : 12),
                Opacity(
                  opacity: 0.65,
                  child: Text(
                    'tap to flip',
                    style: TextStyle(fontSize: isPhone ? 9 : 10, color: isDark ? _kTextMuted : Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Back extends StatelessWidget {
  final _SignEntry entry;
  final bool isDark;
  final AppLocalizations l;
  final bool isPhone;

  const _Back({
    required this.entry,
    required this.isDark,
    required this.l,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                entry.accent.withOpacity(isDark ? 0.28 : 0.14),
                entry.accent.withOpacity(isDark ? 0.12 : 0.06),
                _kObsidian.withOpacity(isDark ? 0.65 : 0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(color: entry.accent.withOpacity(isDark ? 0.48 : 0.30), width: 1.3),
            boxShadow: [BoxShadow(color: entry.accent.withOpacity(0.24), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Padding(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.accent.withOpacity(isDark ? 0.20 : 0.12),
                    border: Border.all(color: entry.accent.withOpacity(0.5), width: 1.3),
                  ),
                  child: Icon(Icons.sign_language, color: entry.accent, size: isPhone ? 18 : 20),
                ),
                SizedBox(height: isPhone ? 8 : 12),
                Text(
                  l.t(entry.nameKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isPhone ? 13 : 14.5, fontWeight: FontWeight.w800, color: isDark ? _kTextPri : const Color(0xFF0F0F24)),
                ),
                SizedBox(height: isPhone ? 6 : 8),
                Container(
                  width: 44,
                  height: 1.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, entry.accent, Colors.transparent]),
                    boxShadow: [BoxShadow(color: entry.accent.withOpacity(0.7), blurRadius: 7)],
                  ),
                ),
                SizedBox(height: isPhone ? 8 : 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isPhone ? 10 : 12, vertical: isPhone ? 6 : 8),
                  decoration: BoxDecoration(
                    color: entry.accent.withOpacity(isDark ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: entry.accent.withOpacity(0.25)),
                  ),
                  child: Text(
                    l.t(entry.meaningKey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isPhone ? 12 : 13, fontWeight: FontWeight.w900, height: 1.3, color: entry.accent.withOpacity(0.92)),
                  ),
                ),
                SizedBox(height: isPhone ? 12 : 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      l.t(entry.descKey),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isPhone ? 10 : 11, height: 1.5, color: isDark ? _kTextSec : const Color(0xFF585880)),
                    ),
                  ),
                ),
                SizedBox(height: isPhone ? 8 : 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isPhone ? 10 : 12, vertical: 3.5),
                  decoration: BoxDecoration(color: entry.accent.withOpacity(0.13), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    l.t(entry.categoryKey),
                    style: TextStyle(fontSize: isPhone ? 8.5 : 9.5, fontWeight: FontWeight.w800, color: entry.accent, letterSpacing: 1.1),
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

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const _EmptyState({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [_kViolet.withOpacity(0.10), _kViolet.withOpacity(0.02)]),
              border: Border.all(color: _kViolet.withOpacity(0.18)),
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: isDark ? _kTextSec : Colors.grey[400],
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('signs_no_results'),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: isDark ? _kTextSec : const Color(0xFF6A6A8A)),
          ),
          const SizedBox(height: 8),
          Text(
            l.t('signs_no_results_sub'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: isDark ? _kTextMuted : Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BACKGROUND
// ─────────────────────────────────────────────
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
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF1A1A2E).withOpacity(0.65) : const Color(0xFFE6E6F2).withOpacity(0.85)
      ..strokeWidth = 0.6;

    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final dotPaint = Paint()..color = _kViolet.withOpacity(isDark ? 0.12 : 0.08);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
        child: const SizedBox.expand(),
      ),
    );
  }
}