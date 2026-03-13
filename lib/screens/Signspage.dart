// lib/screens/SignsPage.dart
// ─────────────────────────────────────────────────────────────────────────────
//  VANI — ISL Signs Library  (drop into lib/screens/SignsPage.dart)
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../components/GlobalNavbar.dart';
import '../l10n/AppLocalizations.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _kViolet         = Color(0xFF7C3AED);
const _kVioletLight    = Color(0xFFA78BFA);
const _kVioletGlow     = Color(0xFF6D28D9);
const _kObsidian       = Color(0xFF050508);
const _kSurface        = Color(0xFF0C0C14);
const _kSurfaceUp      = Color(0xFF111120);
const _kSurfaceHigh    = Color(0xFF181830);
const _kBorder         = Color(0xFF1E1E32);
const _kBorderBright   = Color(0xFF2A2A44);
const _kTextPri        = Color(0xFFF0EEFF);
const _kTextSec        = Color(0xFF8888AA);
const _kTextMuted      = Color(0xFF44445A);

const _kAccentAlphabet = Color(0xFF7C3AED);
const _kAccentNumbers  = Color(0xFFD97706);
const _kAccentWords    = Color(0xFF0891B2);

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class _SignEntry {
  final String symbol;
  final String nameKey;      // e.g. "Letter A"
  final String meaningKey;   // SHORT meaning shown on card back headline
  final String descKey;      // hand-shape description shown as sub-text
  final String categoryKey;
  final Color  accent;
  const _SignEntry({
    required this.symbol,
    required this.nameKey,
    required this.meaningKey,
    required this.descKey,
    required this.categoryKey,
    required this.accent,
  });
}

// ─────────────────────────────────────────────
//  SIGN DATA  (64 total)
// ─────────────────────────────────────────────
const List<_SignEntry> _kSigns = [

  // ══ ALPHABET ═══════════════════════════════════════════════
  _SignEntry(symbol:'A', nameKey:'sign_a_name', meaningKey:'sign_a_meaning', descKey:'sign_a_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'B', nameKey:'sign_b_name', meaningKey:'sign_b_meaning', descKey:'sign_b_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'C', nameKey:'sign_c_name', meaningKey:'sign_c_meaning', descKey:'sign_c_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'D', nameKey:'sign_d_name', meaningKey:'sign_d_meaning', descKey:'sign_d_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'E',  nameKey:'sign_e_name', meaningKey:'sign_e_meaning', descKey:'sign_e_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'F', nameKey:'sign_f_name', meaningKey:'sign_f_meaning', descKey:'sign_f_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'G', nameKey:'sign_g_name', meaningKey:'sign_g_meaning', descKey:'sign_g_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'H', nameKey:'sign_h_name', meaningKey:'sign_h_meaning', descKey:'sign_h_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'I', nameKey:'sign_i_name', meaningKey:'sign_i_meaning', descKey:'sign_i_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'J', nameKey:'sign_j_name', meaningKey:'sign_j_meaning', descKey:'sign_j_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'K', nameKey:'sign_k_name', meaningKey:'sign_k_meaning', descKey:'sign_k_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'L', nameKey:'sign_l_name', meaningKey:'sign_l_meaning', descKey:'sign_l_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'M', nameKey:'sign_m_name', meaningKey:'sign_m_meaning', descKey:'sign_m_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'N', nameKey:'sign_n_name', meaningKey:'sign_n_meaning', descKey:'sign_n_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'O', nameKey:'sign_o_name', meaningKey:'sign_o_meaning', descKey:'sign_o_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'P',  nameKey:'sign_p_name', meaningKey:'sign_p_meaning', descKey:'sign_p_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'Q', nameKey:'sign_q_name', meaningKey:'sign_q_meaning', descKey:'sign_q_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'R', nameKey:'sign_r_name', meaningKey:'sign_r_meaning', descKey:'sign_r_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'S', nameKey:'sign_s_name', meaningKey:'sign_s_meaning', descKey:'sign_s_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'T', nameKey:'sign_t_name', meaningKey:'sign_t_meaning', descKey:'sign_t_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'U', nameKey:'sign_u_name', meaningKey:'sign_u_meaning', descKey:'sign_u_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'V',  nameKey:'sign_v_name', meaningKey:'sign_v_meaning', descKey:'sign_v_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'W', nameKey:'sign_w_name', meaningKey:'sign_w_meaning', descKey:'sign_w_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'X', nameKey:'sign_x_name', meaningKey:'sign_x_meaning', descKey:'sign_x_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'Y', nameKey:'sign_y_name', meaningKey:'sign_y_meaning', descKey:'sign_y_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),
  _SignEntry(symbol:'Z', nameKey:'sign_z_name', meaningKey:'sign_z_meaning', descKey:'sign_z_desc', categoryKey:'cat_alphabet', accent:_kAccentAlphabet),

  // ══ NUMBERS ════════════════════════════════════════════════
  _SignEntry(symbol:'0', nameKey:'sign_0_name', meaningKey:'sign_0_meaning', descKey:'sign_0_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'1', nameKey:'sign_1_name', meaningKey:'sign_1_meaning', descKey:'sign_1_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'2', nameKey:'sign_2_name', meaningKey:'sign_2_meaning', descKey:'sign_2_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'3', nameKey:'sign_3_name', meaningKey:'sign_3_meaning', descKey:'sign_3_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'4', nameKey:'sign_4_name', meaningKey:'sign_4_meaning', descKey:'sign_4_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'5', nameKey:'sign_5_name', meaningKey:'sign_5_meaning', descKey:'sign_5_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'6', nameKey:'sign_6_name', meaningKey:'sign_6_meaning', descKey:'sign_6_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'7', nameKey:'sign_7_name', meaningKey:'sign_7_meaning', descKey:'sign_7_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'8', nameKey:'sign_8_name', meaningKey:'sign_8_meaning', descKey:'sign_8_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),
  _SignEntry(symbol:'9', nameKey:'sign_9_name', meaningKey:'sign_9_meaning', descKey:'sign_9_desc', categoryKey:'cat_numbers', accent:_kAccentNumbers),

  // ══ WORDS ══════════════════════════════════════════════════
  _SignEntry(symbol:'', nameKey:'sign_namaste_name',   meaningKey:'sign_namaste_meaning',   descKey:'sign_namaste_desc',   categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_hello_name',     meaningKey:'sign_hello_meaning',     descKey:'sign_hello_desc',     categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_hi_name',        meaningKey:'sign_hi_meaning',        descKey:'sign_hi_desc',        categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_howareyou_name', meaningKey:'sign_howareyou_meaning', descKey:'sign_howareyou_desc', categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_quiet_name',     meaningKey:'sign_quiet_meaning',     descKey:'sign_quiet_desc',     categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_thanks_name',    meaningKey:'sign_thanks_meaning',    descKey:'sign_thanks_desc',    categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'',  nameKey:'sign_food_name',      meaningKey:'sign_food_meaning',      descKey:'sign_food_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_iloveyou_name',  meaningKey:'sign_iloveyou_meaning',  descKey:'sign_iloveyou_desc',  categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_brother_name',   meaningKey:'sign_brother_meaning',   descKey:'sign_brother_desc',   categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_father_name',    meaningKey:'sign_father_meaning',    descKey:'sign_father_desc',    categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_mother_name',    meaningKey:'sign_mother_meaning',    descKey:'sign_mother_desc',    categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_water_name',     meaningKey:'sign_water_meaning',     descKey:'sign_water_desc',     categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_what_name',      meaningKey:'sign_what_meaning',      descKey:'sign_what_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_please_name',    meaningKey:'sign_please_meaning',    descKey:'sign_please_desc',    categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_help_name',      meaningKey:'sign_help_meaning',      descKey:'sign_help_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_loud_name',      meaningKey:'sign_loud_meaning',      descKey:'sign_loud_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_yours_name',     meaningKey:'sign_yours_meaning',     descKey:'sign_yours_desc',     categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_sleeping_name',  meaningKey:'sign_sleeping_meaning',  descKey:'sign_sleeping_desc',  categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'',  nameKey:'sign_name_name',      meaningKey:'sign_name_meaning',      descKey:'sign_name_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_sorry_name',     meaningKey:'sign_sorry_meaning',     descKey:'sign_sorry_desc',     categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_good_name',      meaningKey:'sign_good_meaning',      descKey:'sign_good_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_bad_name',       meaningKey:'sign_bad_meaning',       descKey:'sign_bad_desc',       categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_today_name',     meaningKey:'sign_today_meaning',     descKey:'sign_today_desc',     categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_time_name',      meaningKey:'sign_time_meaning',      descKey:'sign_time_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_strong_name',    meaningKey:'sign_strong_meaning',    descKey:'sign_strong_desc',    categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_love_name',      meaningKey:'sign_love_meaning',      descKey:'sign_love_desc',      categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_bandaid_name',   meaningKey:'sign_bandaid_meaning',   descKey:'sign_bandaid_desc',   categoryKey:'cat_words', accent:_kAccentWords),
  _SignEntry(symbol:'', nameKey:'sign_happy_name',     meaningKey:'sign_happy_meaning',     descKey:'sign_happy_desc',     categoryKey:'cat_words', accent:_kAccentWords),
];

const _kCategoryOrder = ['cat_alphabet', 'cat_numbers', 'cat_words'];

// ─────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────
class SignsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  const SignsPage({super.key, required this.toggleTheme, required this.setLocale});
  @override State<SignsPage> createState() => _SignsPageState();
}

class _SignsPageState extends State<SignsPage> with TickerProviderStateMixin {
  String _cat    = 'all';
  String _query  = '';
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override void dispose() { _fadeCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  List<_SignEntry> _filtered(AppLocalizations l) => _kSigns.where((s) {
    final matchCat = _cat == 'all' || s.categoryKey == _cat;
    final q = _query.toLowerCase();
    final matchQ = q.isEmpty ||
        l.t(s.nameKey).toLowerCase().contains(q) ||
        l.t(s.meaningKey).toLowerCase().contains(q) ||
        l.t(s.categoryKey).toLowerCase().contains(q);
    return matchCat && matchQ;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final l         = AppLocalizations.of(context);
    final w         = MediaQuery.of(context).size.width;
    final isDesktop = w > 1100;
    final isTablet  = w > 680 && w <= 1100;
    final hPad      = isDesktop ? 88.0 : (isTablet ? 44.0 : 20.0);
    final filtered  = _filtered(l);

    return Scaffold(
      backgroundColor: isDark ? _kObsidian : const Color(0xFFF4F4FC),
      body: Stack(children: [
        // ── Background
        Positioned.fill(child: _GridTexture(isDark: isDark)),
        Positioned(top: -250, right: -150,
            child: _Glow(color: _kViolet.withOpacity(isDark ? 0.20 : 0.09), size: 700)),
        Positioned(bottom: -200, left: -120,
            child: _Glow(color: const Color(0xFF0891B2).withOpacity(isDark ? 0.12 : 0.05), size: 500)),
        Positioned(top: 300, left: -100,
            child: _Glow(color: _kAccentAlphabet.withOpacity(isDark ? 0.07 : 0.03), size: 400)),

        // ── Content
        SafeArea(child: Column(children: [
          GlobalNavbar(toggleTheme: widget.toggleTheme, setLocale: widget.setLocale, activeRoute: 'signs'),
          Expanded(child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 44),
                  _Header(isDark: isDark, l: l),
                  const SizedBox(height: 36),
                  _SearchField(
                    isDark: isDark, ctrl: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 20),
                  _FilterRow(
                    isDark: isDark, selected: _cat, l: l,
                    onSelect: (c) {
                      setState(() => _cat = c);
                      _fadeCtrl.forward(from: 0.65);
                    },
                  ),
                  const SizedBox(height: 32),
                  if (filtered.isNotEmpty) _CountRow(
                    count: filtered.length, total: _kSigns.length, isDark: isDark, l: l),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    _EmptyState(isDark: isDark, l: l)
                  else
                    _Grid(signs: filtered, isDark: isDark, l: l,
                        isDesktop: isDesktop, isTablet: isTablet),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          )),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark; final AppLocalizations l;
  const _Header({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Tag badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: _kViolet.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(colors: [
            _kViolet.withOpacity(0.08), _kVioletGlow.withOpacity(0.03),
          ]),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 5, height: 5, decoration: const BoxDecoration(
            shape: BoxShape.circle, color: _kVioletLight)),
          const SizedBox(width: 7),
          Text('ISL SIGNS LIBRARY', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w800,
            color: _kVioletLight, letterSpacing: 2.4,
          )),
        ]),
      ),
      const SizedBox(height: 22),
      // Headline
      RichText(text: TextSpan(
        style: TextStyle(
          fontSize: 48, fontWeight: FontWeight.w900, height: 1.06,
          letterSpacing: -2.5, color: isDark ? _kTextPri : const Color(0xFF08081A),
        ),
        children: [
          TextSpan(text: l.t('signs_title_1')),
          WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [_kViolet, _kVioletLight, Color(0xFF38BDF8)],
                stops: [0.0, 0.55, 1.0],
              ).createShader(b),
              child: Text(l.t('signs_title_highlight'), style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white,
                height: 1.06, letterSpacing: -2.5,
              )),
            )),
        ],
      )),
      const SizedBox(height: 16),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Text(l.t('signs_subtitle'), style: TextStyle(
          fontSize: 14.5, height: 1.75, letterSpacing: 0.1,
          color: isDark ? _kTextSec : const Color(0xFF5A5A7A),
        )),
      ),
      const SizedBox(height: 24),
      // Stat pills row
      Wrap(spacing: 10, runSpacing: 10, children: [
        _Pill(n: '${_kSigns.length}', label: l.t('signs_stat_total'),    color: _kViolet,         isDark: isDark),
        _Pill(n: '26',                label: l.t('signs_stat_alphabet'), color: _kAccentAlphabet, isDark: isDark),
        _Pill(n: '10',                label: l.t('signs_stat_numbers'),  color: _kAccentNumbers,  isDark: isDark),
        _Pill(n: '28',                label: l.t('signs_stat_words'),    color: _kAccentWords,    isDark: isDark),
      ]),
    ],
  );
}

class _Pill extends StatelessWidget {
  final String n, label; final Color color; final bool isDark;
  const _Pill({required this.n, required this.label, required this.color, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: isDark ? _kSurfaceUp : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.22)),
      boxShadow: [BoxShadow(
        color: color.withOpacity(isDark ? 0.08 : 0.06),
        blurRadius: 12, offset: const Offset(0, 3),
      )],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5)],
      )),
      const SizedBox(width: 9),
      Text(n, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? _kTextPri : const Color(0xFF0A0A1F))),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
          color: isDark ? _kTextSec : const Color(0xFF7A7A9A))),
    ]),
  );
}

// ─────────────────────────────────────────────
//  SEARCH FIELD
// ─────────────────────────────────────────────
class _SearchField extends StatefulWidget {
  final bool isDark; final TextEditingController ctrl; final ValueChanged<String> onChanged;
  const _SearchField({required this.isDark, required this.ctrl, required this.onChanged});
  @override State<_SearchField> createState() => _SearchFieldState();
}
class _SearchFieldState extends State<_SearchField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: widget.isDark ? _kSurfaceUp : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _focused ? _kViolet.withOpacity(0.6) : (widget.isDark ? _kBorder : const Color(0xFFE0E0EE)),
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: _kViolet.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: widget.ctrl,
          onChanged: widget.onChanged,
          style: TextStyle(color: widget.isDark ? _kTextPri : const Color(0xFF0A0A1F),
              fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: l.t('signs_search_hint'),
            hintStyle: TextStyle(color: widget.isDark ? _kTextMuted : Colors.grey[400], fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Icon(Icons.search_rounded,
                  color: _focused ? _kVioletLight : (widget.isDark ? _kTextSec : Colors.grey[400]),
                  size: 20),
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
                      child: Icon(Icons.close_rounded,
                          color: widget.isDark ? _kTextSec : Colors.grey[500], size: 14),
                    ),
                    onPressed: () { widget.ctrl.clear(); widget.onChanged(''); })
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER ROW
// ─────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final bool isDark; final String selected;
  final AppLocalizations l; final ValueChanged<String> onSelect;
  const _FilterRow({required this.isDark, required this.selected,
      required this.l, required this.onSelect});

  static const _icons  = <String, IconData>{
    'all': Icons.apps_rounded, 'cat_alphabet': Icons.sort_by_alpha_rounded,
    'cat_numbers': Icons.tag_rounded, 'cat_words': Icons.record_voice_over_rounded,
  };
  static const _colors = <String, Color>{
    'all': _kViolet, 'cat_alphabet': _kAccentAlphabet,
    'cat_numbers': _kAccentNumbers, 'cat_words': _kAccentWords,
  };

  @override
  Widget build(BuildContext context) {
    final cats = ['all', ..._kCategoryOrder];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
      child: Row(children: cats.map((cat) {
        final color = _colors[cat] ?? _kViolet;
        final count = cat == 'all' ? _kSigns.length
            : _kSigns.where((s) => s.categoryKey == cat).length;
        return Padding(padding: const EdgeInsets.only(right: 10),
          child: _Chip(
            isDark: isDark, isActive: selected == cat,
            label: cat == 'all' ? l.t('cat_all') : l.t(cat),
            icon: _icons[cat] ?? Icons.label_rounded,
            color: color, count: count,
            onTap: () => onSelect(cat),
          ));
      }).toList()),
    );
  }
}

class _Chip extends StatefulWidget {
  final bool isDark, isActive; final String label; final IconData icon;
  final Color color; final int count; final VoidCallback onTap;
  const _Chip({required this.isDark, required this.isActive, required this.label,
      required this.icon, required this.color, required this.count, required this.onTap});
  @override State<_Chip> createState() => _ChipState();
}
class _ChipState extends State<_Chip> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit:  (_) => setState(() => _hov = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: widget.isActive ? LinearGradient(
            colors: [widget.color, widget.color.withOpacity(0.8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ) : null,
          color: widget.isActive ? null
              : (_hov ? widget.color.withOpacity(0.08)
                      : (widget.isDark ? _kSurfaceUp : Colors.white)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isActive ? Colors.transparent
                : widget.color.withOpacity(_hov ? 0.45 : 0.22),
            width: 1.2,
          ),
          boxShadow: widget.isActive ? [
            BoxShadow(color: widget.color.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 5)),
            BoxShadow(color: widget.color.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 8)),
          ] : _hov ? [BoxShadow(
              color: widget.color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 3))] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(widget.icon, size: 14,
              color: widget.isActive ? Colors.white
                  : (widget.isDark ? _kTextSec : const Color(0xFF6A6A8A))),
          const SizedBox(width: 8),
          Text(widget.label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4,
            color: widget.isActive ? Colors.white
                : (widget.isDark ? _kTextSec : const Color(0xFF6A6A8A)),
          )),
          const SizedBox(width: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: widget.isActive ? Colors.white.withOpacity(0.22) : widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${widget.count}', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w900,
              color: widget.isActive ? Colors.white : widget.color,
            )),
          ),
        ]),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  COUNT ROW
// ─────────────────────────────────────────────
class _CountRow extends StatelessWidget {
  final int count, total; final bool isDark; final AppLocalizations l;
  const _CountRow({required this.count, required this.total, required this.isDark, required this.l});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 18, decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      gradient: const LinearGradient(
        colors: [_kViolet, _kVioletLight], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    )),
    const SizedBox(width: 10),
    Text(
      count == total
          ? l.t('signs_showing_all').replaceAll('{n}', '$total')
          : l.t('signs_showing_filtered').replaceAll('{n}', '$count').replaceAll('{total}', '$total'),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2,
          color: isDark ? _kTextSec : const Color(0xFF7A7A9A)),
    ),
  ]);
}

// ─────────────────────────────────────────────
//  GRID
// ─────────────────────────────────────────────
class _Grid extends StatelessWidget {
  final List<_SignEntry> signs; final bool isDark, isDesktop, isTablet; final AppLocalizations l;
  const _Grid({required this.signs, required this.isDark, required this.l,
      required this.isDesktop, required this.isTablet});
  @override
  Widget build(BuildContext context) {
    final cols = isDesktop ? 6 : (isTablet ? 4 : 2);
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols, mainAxisSpacing: 16, crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: signs.length,
      itemBuilder: (ctx, i) => _Card(entry: signs[i], isDark: isDark, l: l),
    );
  }
}

// ─────────────────────────────────────────────
//  FLIP CARD
// ─────────────────────────────────────────────
class _Card extends StatefulWidget {
  final _SignEntry entry; final bool isDark; final AppLocalizations l;
  const _Card({required this.entry, required this.isDark, required this.l});
  @override State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _flip(bool show) {
    if (show && !_flipped) { _ctrl.forward(); _flipped = true; }
    if (!show && _flipped) { _ctrl.reverse(); _flipped = false; }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => _flip(true),
    onExit:  (_) => _flip(false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () => _flip(!_flipped),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle    = _anim.value * math.pi;
          final showBack = _anim.value > 0.5;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: showBack
                ? Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _Back(entry: widget.entry, isDark: widget.isDark, l: widget.l),
                  )
                : _Front(entry: widget.entry, isDark: widget.isDark, l: widget.l),
          );
        },
      ),
    ),
  );
}

// ══ CARD FRONT ════════════════════════════════
class _Front extends StatelessWidget {
  final _SignEntry entry; final bool isDark; final AppLocalizations l;
  const _Front({required this.entry, required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? _kSurface : Colors.white,
        border: Border.all(
          color: isDark ? _kBorder : const Color(0xFFE6E6F4),
          width: 1,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))]
            : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4)),
                BoxShadow(color: entry.accent.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 8)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(children: [
          // subtle top shimmer line
          Positioned(top: 0, left: 0, right: 0, child: Container(
            height: 1.5,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [
              Colors.transparent,
              entry.accent.withOpacity(isDark ? 0.5 : 0.3),
              Colors.transparent,
            ])),
          )),
          // corner glow
          Positioned(top: -20, right: -20, child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.accent.withOpacity(isDark ? 0.08 : 0.05),
            ),
          )),
          // content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.accent.withOpacity(isDark ? 0.14 : 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: entry.accent.withOpacity(isDark ? 0.3 : 0.18)),
                  ),
                  child: Text(l.t(entry.categoryKey), style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: entry.accent.withOpacity(isDark ? 0.9 : 0.85),
                    letterSpacing: 1.4,
                  )),
                ),
                const SizedBox(height: 16),
                // Emoji in ring
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      entry.accent.withOpacity(isDark ? 0.2 : 0.1),
                      entry.accent.withOpacity(isDark ? 0.04 : 0.02),
                    ]),
                    border: Border.all(
                      color: entry.accent.withOpacity(isDark ? 0.35 : 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [BoxShadow(
                      color: entry.accent.withOpacity(isDark ? 0.18 : 0.1),
                      blurRadius: 18, spreadRadius: 2,
                    )],
                  ),
                  child: Center(child: Text(entry.symbol,
                      style: const TextStyle(fontSize: 30, height: 1))),
                ),
                const SizedBox(height: 14),
                // Name
                Text(l.t(entry.nameKey),
                  textAlign: TextAlign.center, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: -0.3, height: 1.2,
                    color: isDark ? _kTextPri : const Color(0xFF0D0D28),
                  )),
                const SizedBox(height: 12),
                // Flip hint
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.touch_app_rounded, size: 10,
                      color: isDark ? _kTextMuted : Colors.grey[350]),
                  const SizedBox(width: 4),
                  Text('tap to flip', style: TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w500, letterSpacing: 0.3,
                    color: isDark ? _kTextMuted : Colors.grey[380],
                  )),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ══ CARD BACK ═════════════════════════════════
class _Back extends StatelessWidget {
  final _SignEntry entry; final bool isDark; final AppLocalizations l;
  const _Back({required this.entry, required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [
                entry.accent.withOpacity(isDark ? 0.30 : 0.16),
                entry.accent.withOpacity(isDark ? 0.14 : 0.07),
                _kObsidian.withOpacity(isDark ? 0.60 : 0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: entry.accent.withOpacity(isDark ? 0.50 : 0.32), width: 1.5),
            boxShadow: [
              BoxShadow(color: entry.accent.withOpacity(isDark ? 0.28 : 0.14),
                  blurRadius: 32, offset: const Offset(0, 10)),
              BoxShadow(color: entry.accent.withOpacity(isDark ? 0.12 : 0.06),
                  blurRadius: 60, offset: const Offset(0, 18)),
            ],
          ),
          child: Stack(children: [
            // top shimmer
            Positioned(top: 0, left: 0, right: 0, child: Container(
              height: 1.5,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.white.withOpacity(isDark ? 0.20 : 0.40),
                Colors.transparent,
              ])),
            )),
            // corner decoration
            Positioned(bottom: -24, right: -24, child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: entry.accent.withOpacity(isDark ? 0.12 : 0.08),
              ),
            )),
            // content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Icon badge
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.accent.withOpacity(isDark ? 0.22 : 0.14),
                      border: Border.all(color: entry.accent.withOpacity(isDark ? 0.55 : 0.35), width: 1.5),
                      boxShadow: [BoxShadow(
                        color: entry.accent.withOpacity(isDark ? 0.35 : 0.2),
                        blurRadius: 16, spreadRadius: 1,
                      )],
                    ),
                    child: Icon(Icons.sign_language_rounded, color: entry.accent, size: 18),
                  ),

                  const SizedBox(height: 10),

                  // ── Sign name
                  Text(l.t(entry.nameKey),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.2,
                      color: isDark ? _kTextPri : const Color(0xFF08081A),
                    )),

                  const SizedBox(height: 6),

                  // ── Glowing divider
                  Container(
                    width: 40, height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        entry.accent,
                        Colors.transparent,
                      ]),
                      boxShadow: [BoxShadow(color: entry.accent.withOpacity(0.8), blurRadius: 8)],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── MEANING — prominent headline
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: entry.accent.withOpacity(isDark ? 0.15 : 0.09),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: entry.accent.withOpacity(isDark ? 0.28 : 0.18)),
                    ),
                    child: Text(l.t(entry.meaningKey),
                      textAlign: TextAlign.center,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w900, letterSpacing: 0.1, height: 1.3,
                        color: isDark ? entry.accent.withOpacity(0.95)
                            : entry.accent.withOpacity(0.88),
                      )),
                  ),

                  const SizedBox(height: 8),

                  // ── Hand-shape description
                  Expanded(
                    child: Text(l.t(entry.descKey),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: 10, height: 1.6, fontWeight: FontWeight.w500,
                        color: isDark ? _kTextSec : const Color(0xFF525270),
                      )),
                  ),

                  const SizedBox(height: 6),

                  // ── Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry.accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(l.t(entry.categoryKey), style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800,
                      color: entry.accent, letterSpacing: 1.4,
                    )),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark; final AppLocalizations l;
  const _EmptyState({required this.isDark, required this.l});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              _kViolet.withOpacity(0.12), _kViolet.withOpacity(0.02)]),
            border: Border.all(color: _kViolet.withOpacity(0.2)),
          ),
          child: Icon(Icons.search_off_rounded,
              color: isDark ? _kTextSec : Colors.grey[400], size: 44)),
        const SizedBox(height: 22),
        Text(l.t('signs_no_results'), style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: isDark ? _kTextSec : const Color(0xFF6A6A8A))),
        const SizedBox(height: 8),
        Text(l.t('signs_no_results_sub'), style: TextStyle(
            fontSize: 13, color: isDark ? _kTextMuted : Colors.grey[400])),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  BACKGROUND  —  Grid + Ambient glows
// ─────────────────────────────────────────────
class _GridTexture extends StatelessWidget {
  final bool isDark;
  const _GridTexture({required this.isDark});
  @override Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(isDark: isDark));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark
          ? const Color(0xFF1C1C30).withOpacity(0.7)
          : const Color(0xFFE4E4F0).withOpacity(0.9)
      ..strokeWidth = 0.5;
    const step = 52.0;
    for (double x = 0; x < size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    final dotPaint = Paint()..color = _kViolet.withOpacity(isDark ? 0.14 : 0.09);
    for (double x = 0; x < size.width; x += step)
      for (double y = 0; y < size.height; y += step)
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
  }
  @override bool shouldRepaint(_) => false;
}

class _Glow extends StatelessWidget {
  final Color color; final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 160, sigmaY: 160),
      child: const SizedBox.expand()),
  );
}