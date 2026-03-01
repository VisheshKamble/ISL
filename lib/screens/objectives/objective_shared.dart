// lib/screens/objectives/objective_shared.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/GlobalNavbar.dart';
import '../../l10n/AppLocalizations.dart';

// ─── DESIGN TOKENS ───────────────────────────
const kViolet      = Color(0xFF7C3AED);
const kVioletLight = Color(0xFFA78BFA);
const kCrimson     = Color(0xFFDC2626);
const kEmerald     = Color(0xFF059669);
const kAmber       = Color(0xFFD97706);
const kSky         = Color(0xFF0284C7);
const kObsidian    = Color(0xFF050508);
const kSurface     = Color(0xFF0C0C14);
const kSurfaceUp   = Color(0xFF121220);
const kBorder      = Color(0xFF1E1E30);
const kBorderBrt   = Color(0xFF2E2E48);
const kTextPri     = Color(0xFFF0EEFF);
const kTextSec     = Color(0xFF7A7A9A);
const kTextMuted   = Color(0xFF3A3A5A);

// ─── BASE OBJECTIVE PAGE ──────────────────────
class ObjectivePageBase extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;
  final Color accentColor;
  final IconData heroIcon;
  final String tag;        // e.g. "01"
  final String category;   // e.g. "ACCESSIBILITY"
  final String title;
  final String subtitle;
  final List<ObjStatData> stats;
  final List<Widget> sections;

  const ObjectivePageBase({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
    required this.accentColor,
    required this.heroIcon,
    required this.tag,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.sections,
  });

  @override
  State<ObjectivePageBase> createState() => _ObjectivePageBaseState();
}

class _ObjectivePageBaseState extends State<ObjectivePageBase>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
            begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1100;
    final hPad = isDesktop ? 96.0 : (w > 700 ? 48.0 : 24.0);

    return Scaffold(
      backgroundColor: isDark ? kObsidian : const Color(0xFFF7F7FC),
      body: Stack(
        children: [
          Positioned.fill(child: _GridTexture(isDark: isDark)),
          Positioned(
            top: -200, left: -100,
            child: _Glow(color: widget.accentColor.withOpacity(isDark ? 0.20 : 0.10), size: 600),
          ),
          Positioned(
            bottom: -200, right: -150,
            child: _Glow(color: widget.accentColor.withOpacity(isDark ? 0.10 : 0.05), size: 500),
          ),
          SafeArea(
            child: Column(
              children: [
                GlobalNavbar(
                  toggleTheme: widget.toggleTheme,
                  setLocale: widget.setLocale,
                  activeRoute: 'home',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 56),
                          FadeTransition(
                            opacity: _heroFade,
                            child: SlideTransition(
                              position: _heroSlide,
                              child: _ObjHero(
                                tag: widget.tag,
                                category: widget.category,
                                title: widget.title,
                                subtitle: widget.subtitle,
                                icon: widget.heroIcon,
                                accent: widget.accentColor,
                                isDark: isDark,
                                isDesktop: isDesktop,
                              ),
                            ),
                          ),
                          const SizedBox(height: 72),
                          _StatsRow(stats: widget.stats, isDark: isDark, accent: widget.accentColor),
                          const SizedBox(height: 72),
                          ...widget.sections,
                          const SizedBox(height: 80),
                          _BackButton(isDark: isDark, accent: widget.accentColor),
                          const SizedBox(height: 60),
                        ],
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

// ─── HERO ────────────────────────────────────
class _ObjHero extends StatelessWidget {
  final String tag, category, title, subtitle;
  final IconData icon;
  final Color accent;
  final bool isDark, isDesktop;
  const _ObjHero({
    required this.tag, required this.category, required this.title,
    required this.subtitle, required this.icon, required this.accent,
    required this.isDark, required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: accent.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('// $tag', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: accent, letterSpacing: 2.0,
              )),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(category, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: accent.withOpacity(0.8), letterSpacing: 1.5,
              )),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: isDesktop ? 58 : 36,
                    fontWeight: FontWeight.w900,
                    color: isDark ? kTextPri : const Color(0xFF0A0A1F),
                    letterSpacing: -2.0, height: 1.08,
                  )),
                  const SizedBox(height: 20),
                  Text(subtitle, style: TextStyle(
                    fontSize: isDesktop ? 18 : 15,
                    color: isDark ? kTextSec : const Color(0xFF5A5A7A),
                    height: 1.75,
                  )),
                ],
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 60),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: accent.withOpacity(0.25)),
                ),
                child: Icon(icon, color: accent, size: 56),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── STATS ROW ───────────────────────────────
class ObjStatData {
  final String value, label, description;
  final Color? color;
  const ObjStatData({
    required this.value, required this.label,
    this.description = '', this.color,
  });
}

class _StatsRow extends StatelessWidget {
  final List<ObjStatData> stats;
  final bool isDark;
  final Color accent;
  const _StatsRow({required this.stats, required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
      decoration: BoxDecoration(
        color: isDark ? kSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? kBorder : const Color(0xFFE0E0EE)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 24, runSpacing: 24,
        children: stats.map((s) => SizedBox(
          width: w > 900 ? 160 : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.value, style: TextStyle(
                fontSize: 34, fontWeight: FontWeight.w900,
                color: s.color ?? accent, letterSpacing: -1.0,
              )),
              const SizedBox(height: 4),
              Text(s.label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? kTextPri : const Color(0xFF0A0A1F),
              )),
              if (s.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(s.description, style: TextStyle(
                  fontSize: 12, color: isDark ? kTextSec : const Color(0xFF6A6A8A),
                  height: 1.4,
                )),
              ],
            ],
          ),
        )).toList(),
      ),
    );
  }
}

// ─── SECTION BUILDER HELPERS ─────────────────
class ObjSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  const ObjSection({
    super.key, required this.title, required this.child, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w900,
          color: isDark ? kTextPri : const Color(0xFF0A0A1F),
          letterSpacing: -0.5,
        )),
        const SizedBox(height: 6),
        Container(height: 2, width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [kViolet, kViolet.withOpacity(0)]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 28),
        child,
        const SizedBox(height: 56),
      ],
    );
  }
}

class ObjInfoCard extends StatelessWidget {
  final String title, body;
  final IconData icon;
  final Color accent;
  final bool isDark;
  const ObjInfoCard({
    super.key, required this.title, required this.body,
    required this.icon, required this.accent, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? kSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? kBorder : const Color(0xFFE8E8F0)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: isDark ? kTextPri : const Color(0xFF0A0A1F),
                )),
                const SizedBox(height: 6),
                Text(body, style: TextStyle(
                  fontSize: 13, color: isDark ? kTextSec : const Color(0xFF5A5A7A),
                  height: 1.6,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ObjQuoteBlock extends StatelessWidget {
  final String quote, source;
  final Color accent;
  final bool isDark;
  const ObjQuoteBlock({
    super.key, required this.quote, required this.source,
    required this.accent, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.08), accent.withOpacity(0.03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: accent, size: 32),
          const SizedBox(height: 12),
          Text(quote, style: TextStyle(
            fontSize: 17, color: isDark ? kTextPri : const Color(0xFF1A1A3A),
            height: 1.7, fontStyle: FontStyle.italic,
          )),
          const SizedBox(height: 16),
          Container(height: 1, color: accent.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(source, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: accent, letterSpacing: 0.5,
          )),
        ],
      ),
    );
  }
}

class ObjBarChart extends StatelessWidget {
  final List<(String, double, Color)> data; // (label, value 0-1, color)
  final bool isDark;
  const ObjBarChart({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? kSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? kBorder : const Color(0xFFE8E8F0)),
      ),
      child: Column(
        children: data.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d.$1, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? kTextPri : const Color(0xFF0A0A1F),
                  )),
                  Text('${(d.$2 * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: d.$3, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(height: 8,
                      color: isDark ? kBorderBrt : const Color(0xFFF0F0F8)),
                    FractionallySizedBox(
                      widthFactor: d.$2,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [d.$3, d.$3.withOpacity(0.6)]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class ObjTimelineItem extends StatelessWidget {
  final String year, event;
  final Color accent;
  final bool isDark, isLast;
  const ObjTimelineItem({
    super.key, required this.year, required this.event,
    required this.accent, required this.isDark, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.4)),
                ),
                child: Center(child: Text(year.substring(2), style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w900, color: accent,
                ))),
              ),
              if (!isLast) Expanded(child: Container(
                width: 1, color: accent.withOpacity(0.15),
              )),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(year, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800,
                    color: accent, letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 4),
                  Text(event, style: TextStyle(
                    fontSize: 14, color: isDark ? kTextSec : const Color(0xFF5A5A7A),
                    height: 1.5,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BACK BUTTON ─────────────────────────────
class _BackButton extends StatelessWidget {
  final bool isDark;
  final Color accent;
  const _BackButton({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? kSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? kBorder : const Color(0xFFE0E0EE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, color: accent, size: 18),
            const SizedBox(width: 10),
            Text(l.t('obj_page_back'), style: TextStyle(
              color: accent, fontWeight: FontWeight.w700, fontSize: 14,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── GRID TEXTURE ────────────────────────────
class _GridTexture extends StatelessWidget {
  final bool isDark;
  const _GridTexture({required this.isDark});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(isDark: isDark));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFF1A1A2E).withOpacity(0.5)
          : const Color(0xFFE4E4F0).withOpacity(0.7)
      ..strokeWidth = 0.5;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final dp = Paint()
      ..color = kViolet.withOpacity(isDark ? 0.12 : 0.07);
    for (double x = 0; x < size.width; x += step)
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, dp);
      }
  }
  @override bool shouldRepaint(_) => false;
}

// ─── GLOW ────────────────────────────────────
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
        child: const SizedBox.expand(),
      ),
    );
  }
}