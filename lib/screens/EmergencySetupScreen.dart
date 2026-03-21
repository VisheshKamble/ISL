// lib/screens/EmergencySetupScreen.dart
import 'package:flutter/material.dart';
import '../components/GlobalNavbar.dart';
import '../models/EmergencyContact.dart';
import '../services/EmergencyService.dart';
import '../utils/PlatformHelper.dart';

// ── Accent colours — same in both modes ─────────────────────────
const _kCrimson     = Color(0xFFE02020);
const _kCrimsonSoft = Color(0xFFFF4444);
const _kViolet      = Color(0xFF7C3AED);
const _kVioletLight = Color(0xFFA78BFA);
const _kAmber       = Color(0xFFD97706);
const _kGreen       = Color(0xFF10B981);

// ── Theme helper ─────────────────────────────────────────────────
class _T {
  final bool d;
  const _T(this.d);

  Color get scaffold  => d ? const Color(0xFF020205) : const Color(0xFFF4F6FD);
  Color get surface   => d ? const Color(0xFF0A0A12) : Colors.white;
  Color get surfaceUp => d ? const Color(0xFF10101C) : const Color(0xFFF8F8FC);
  Color get surfaceHi => d ? const Color(0xFF161625) : const Color(0xFFEEEEF8);
  Color get border    => d ? const Color(0xFF1C1C2E) : const Color(0xFFE0E0EE);
  Color get borderBrt => d ? const Color(0xFF252540) : const Color(0xFFCCCCDD);
  Color get textPri   => d ? const Color(0xFFF2F0FF) : const Color(0xFF0A0A1F);
  Color get textSec   => d ? const Color(0xFF6B6B8A) : const Color(0xFF6A6A8A);
  Color get textMuted => d ? const Color(0xFF2E2E4A) : const Color(0xFFAAAAAA);
}

// ── Relation → accent colour ─────────────────────────────────────
const _relationColors = {
  'Family':    Color(0xFF7C3AED),
  'Parent':    Color(0xFF0EA5E9),
  'Sibling':   Color(0xFF10B981),
  'Spouse':    Color(0xFFE02020),
  'Friend':    Color(0xFFD97706),
  'Doctor':    Color(0xFF06B6D4),
  'Caretaker': Color(0xFF8B5CF6),
  'Other':     Color(0xFF6B7280),
};
Color _colorFor(String r) => _relationColors[r] ?? const Color(0xFF6B7280);

class EmergencySetupScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;

  const EmergencySetupScreen({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
  });

  @override
  State<EmergencySetupScreen> createState() => _EmergencySetupScreenState();
}

class _EmergencySetupScreenState extends State<EmergencySetupScreen>
    with SingleTickerProviderStateMixin {
  final _service = EmergencyService.instance;

  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final t         = _T(isDark);
    final contacts  = _service.getContacts();
    final w         = MediaQuery.of(context).size.width;
    final isDesktop = w > 1100;

    // Hard split: mobile-native below 700, website above
    if (w < 700) return _buildMobileShell(context, t, contacts, isDark);
    return _buildWebsite(context, t, contacts, isDesktop);
  }

  // ══════════════════════════════════════════════
  //  MOBILE SHELL — native app contacts manager
  //  No GlobalNavbar. Compact top bar with back.
  //  Full-width contact cards with swipe-friendly sizing.
  //  Capabilities strip replaces the old platform card.
  // ══════════════════════════════════════════════
  Widget _buildMobileShell(BuildContext context, _T t,
      List<EmergencyContact> contacts, bool isDark) {
    final hasPrimary = contacts.any((c) => c.isPrimary);

    return Scaffold(
      backgroundColor: t.scaffold,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: Column(children: [

            // ── Compact top bar ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                            color: t.surfaceUp, shape: BoxShape.circle,
                            border: Border.all(color: t.border)),
                        child: Icon(Icons.arrow_back_rounded, color: t.textSec, size: 18))),
                const SizedBox(width: 12),
                // Icon + title
                Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                        color: _kCrimson.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kCrimson.withOpacity(0.18))),
                    child: const Icon(Icons.contacts_rounded, color: _kCrimsonSoft, size: 16)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Emergency Contacts', style: TextStyle(
                      color: t.textPri, fontSize: 15, fontWeight: FontWeight.w800)),
                  Text('Up to 5 · Alerted on SOS', style: TextStyle(
                      color: t.textSec, fontSize: 10.5)),
                ])),
                // Count badge
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: (hasPrimary ? _kGreen : _kAmber).withOpacity(isDark ? 0.10 : 0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: (hasPrimary ? _kGreen : _kAmber).withOpacity(0.22))),
                    child: Text('${contacts.length}/5',
                        style: TextStyle(
                            color: hasPrimary ? _kGreen : _kAmber,
                            fontSize: 11, fontWeight: FontWeight.w700))),
              ]),
            ),

            // ── Body ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                physics: const BouncingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Mobile capabilities strip
                  _MobileCapStrip(t: t, isDark: isDark),
                  const SizedBox(height: 18),

                  // Shake card
                  if (PlatformHelper.supportsShake) ...[
                    _buildShakeInfoCard(t),
                    const SizedBox(height: 18),
                  ],

                  // Section header
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                        contacts.isEmpty ? 'No contacts yet' : 'Your Contacts',
                        style: TextStyle(color: t.textPri, fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    if (!hasPrimary && contacts.isNotEmpty)
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: _kAmber.withOpacity(isDark ? 0.08 : 0.06),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _kAmber.withOpacity(0.20))),
                          child: const Text('No primary set', style: TextStyle(
                              color: _kAmber, fontSize: 10, fontWeight: FontWeight.w600))),
                  ]),
                  const SizedBox(height: 12),

                  // Empty state
                  if (contacts.isEmpty) _buildEmptyState(t),

                  // Contact rows
                  ...contacts.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ContactRow(
                        contact: e.value, index: e.key, t: t,
                        onDelete:     () => _confirmDelete(e.key),
                        onSetPrimary: () => _setPrimary(e.key),
                        onEdit:       () => _openDialog(existing: e.value, index: e.key),
                      ))),

                  // Add button
                  if (contacts.length < 5) ...[
                    const SizedBox(height: 4),
                    _AddButton(t: t, onTap: () => _openDialog()),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  WEBSITE (≥ 700px) — unchanged
  // ══════════════════════════════════════════════
  Widget _buildWebsite(BuildContext context, _T t,
      List<EmergencyContact> contacts, bool isDesktop) {
    final hPad = isDesktop ? 120.0 : 64.0;
    return Scaffold(
      backgroundColor: t.scaffold,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: Column(children: [
            GlobalNavbar(toggleTheme: widget.toggleTheme,
                setLocale: widget.setLocale, activeRoute: 'emergency'),
            Expanded(child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 60),
              physics: const BouncingScrollPhysics(),
              child: isDesktop
                  ? _buildDesktopLayout(t, contacts)
                  : _buildTabletLayout(t, contacts),
            )),
          ]),
        ),
      ),
    );
  }

  // ── Layouts ──────────────────────────────────────────────────

  Widget _buildDesktopLayout(_T t, List<EmergencyContact> contacts) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 4,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildPageHeader(t),
          const SizedBox(height: 32),
          _buildPlatformCard(t),
          const SizedBox(height: 20),
          if (PlatformHelper.supportsShake) _buildShakeInfoCard(t),
        ]),
      ),
      const SizedBox(width: 48),
      Expanded(flex: 5, child: _buildContactsSection(t, contacts)),
    ]);
  }

  Widget _buildTabletLayout(_T t, List<EmergencyContact> contacts) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildPageHeader(t),
      const SizedBox(height: 28),
      _buildPlatformCard(t),
      const SizedBox(height: 24),
      _buildContactsSection(t, contacts),
      if (PlatformHelper.supportsShake) ...[
        const SizedBox(height: 20),
        _buildShakeInfoCard(t),
      ],
    ]);
  }

  // ── Page header ──────────────────────────────────────────────

  Widget _buildPageHeader(_T t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.arrow_back_rounded, color: t.textSec, size: 16),
          const SizedBox(width: 6),
          Text('Emergency', style: TextStyle(color: t.textSec, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: _kCrimson.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCrimson.withOpacity(0.2)),
          ),
          child: const Center(
              child: Icon(Icons.contacts_rounded, color: _kCrimsonSoft, size: 22)),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Emergency Contacts', style: TextStyle(
              color: t.textPri, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text('Up to 5 people alerted during SOS',
              style: TextStyle(color: t.textSec, fontSize: 13)),
        ]),
      ]),
    ]);
  }

  // ── Platform card (desktop/tablet only) ─────────────────────

  Widget _buildPlatformCard(_T t) {
    final isMobile = PlatformHelper.isMobile;
    final features = isMobile
        ? [
      (Icons.sms_rounded,       'Auto SMS with GPS coordinates'),
      (Icons.vibration_rounded, 'Shake phone to trigger instantly'),
      (Icons.location_on_rounded,'Precise location attached'),
      (Icons.notifications_rounded,'Vibration + sound feedback'),
    ]
        : [
      (Icons.chat_bubble_rounded, 'WhatsApp + call links open'),
      (Icons.location_on_rounded, 'Browser GPS when permitted'),
      (Icons.content_copy_rounded,'One-tap copy for message'),
      (Icons.link_rounded,        'All contacts shown at once'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surfaceUp,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isMobile ? Icons.smartphone_rounded : Icons.language_rounded,
              color: _kVioletLight, size: 15),
          const SizedBox(width: 8),
          Text(
            isMobile ? 'Mobile SOS capabilities' : 'Web SOS capabilities',
            style: const TextStyle(
                color: _kVioletLight, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
        ]),
        const SizedBox(height: 14),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(children: [
            Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                    color: _kViolet.withOpacity(t.d ? 0.10 : 0.07),
                    borderRadius: BorderRadius.circular(7)),
                child: Icon(f.$1, color: _kVioletLight, size: 13)),
            const SizedBox(width: 10),
            Text(f.$2, style: TextStyle(color: t.textSec, fontSize: 12, height: 1.4)),
          ]),
        )),
      ]),
    );
  }

  // ── Shake info card ──────────────────────────────────────────

  Widget _buildShakeInfoCard(_T t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kViolet.withOpacity(t.d ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kViolet.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: _kViolet.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kViolet.withOpacity(0.20))),
            child: const Icon(Icons.vibration_rounded, color: _kVioletLight, size: 17)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Shake-to-SOS is active', style: TextStyle(
              color: _kVioletLight, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text('Shake phone twice from any screen to trigger a general SOS.',
              style: TextStyle(color: t.textSec, fontSize: 11, height: 1.5)),
        ])),
      ]),
    );
  }

  // ── Contacts section ─────────────────────────────────────────

  Widget _buildContactsSection(_T t, List<EmergencyContact> contacts) {
    final hasPrimary = contacts.any((c) => c.isPrimary);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          contacts.isEmpty ? 'No contacts yet' : '${contacts.length} of 5 contacts',
          style: TextStyle(color: t.textSec, fontSize: 12,
              fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        if (contacts.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (hasPrimary ? _kGreen : _kAmber).withOpacity(t.d ? 0.08 : 0.06),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: (hasPrimary ? _kGreen : _kAmber).withOpacity(0.2)),
            ),
            child: Text(
              hasPrimary ? '● Primary set' : '○ No primary',
              style: TextStyle(
                  color: hasPrimary ? _kGreen : _kAmber,
                  fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
      ]),

      const SizedBox(height: 12),

      if (contacts.isEmpty) _buildEmptyState(t),

      ...contacts.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ContactRow(
          contact: e.value, index: e.key, t: t,
          onDelete:     () => _confirmDelete(e.key),
          onSetPrimary: () => _setPrimary(e.key),
          onEdit:       () => _openDialog(existing: e.value, index: e.key),
        ),
      )),

      const SizedBox(height: 4),
      if (contacts.length < 5) _AddButton(t: t, onTap: () => _openDialog()),
    ]);
  }

  Widget _buildEmptyState(_T t) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: t.surfaceUp,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
      ),
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: _kCrimson.withOpacity(t.d ? 0.08 : 0.06),
            shape: BoxShape.circle,
          ),
          child: const Center(
              child: Icon(Icons.person_add_rounded, color: _kCrimsonSoft, size: 24)),
        ),
        const SizedBox(height: 14),
        Text('Add your first contact', style: TextStyle(
            color: t.textPri, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text("They'll receive your SOS message\nwith your GPS location.",
            textAlign: TextAlign.center,
            style: TextStyle(color: t.textSec, fontSize: 12, height: 1.6)),
      ]),
    );
  }

  // ── Actions ──────────────────────────────────────────────────

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Remove contact?',
        body: 'This person will no longer receive your SOS alerts.',
        confirmLabel: 'Remove',
        confirmColor: _kCrimsonSoft,
        onConfirm: () async {
          await _service.deleteContact(index);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _setPrimary(int index) async {
    await _service.setPrimary(index);
    if (mounted) setState(() {});
  }

  void _openDialog({EmergencyContact? existing, int? index}) {
    showDialog(
      context: context,
      builder: (ctx) => _ContactFormDialog(
        existing: existing,
        onSave: (contact) async {
          try {
            index != null
                ? await _service.updateContact(index, contact)
                : await _service.addContact(contact);
            if (mounted) setState(() {});
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString()),
                backgroundColor: _kCrimson,
                behavior: SnackBarBehavior.floating,
              ));
            }
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CONTACT ROW
// ─────────────────────────────────────────────

class _ContactRow extends StatefulWidget {
  final EmergencyContact contact;
  final int index;
  final _T t;
  final VoidCallback onDelete, onSetPrimary, onEdit;

  const _ContactRow({
    required this.contact, required this.index, required this.t,
    required this.onDelete, required this.onSetPrimary, required this.onEdit,
  });

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t       = widget.t;
    final color   = _colorFor(widget.contact.relation);
    final initial = widget.contact.name.isNotEmpty
        ? widget.contact.name[0].toUpperCase() : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered ? t.surfaceHi : t.surfaceUp,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.contact.isPrimary
                ? _kCrimson.withOpacity(0.35)
                : (_hovered ? t.borderBrt : t.border),
            width: widget.contact.isPrimary ? 1.5 : 1.0,
          ),
        ),
        child: Row(children: [
          // Avatar with primary star
          Stack(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(t.d ? 0.1 : 0.07),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Center(child: Text(initial,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17))),
            ),
            if (widget.contact.isPrimary)
              Positioned(right: 0, bottom: 0, child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: _kCrimson, shape: BoxShape.circle,
                  border: Border.all(color: t.surface, width: 1.5),
                ),
                child: const Center(child: Icon(Icons.star_rounded, color: Colors.white, size: 8)),
              )),
          ]),

          const SizedBox(width: 14),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(widget.contact.name, style: TextStyle(
                  color: t.textPri, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(t.d ? 0.1 : 0.07),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(widget.contact.relation, style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 3),
            Text(widget.contact.phone, style: TextStyle(
                color: t.textSec, fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()])),
          ])),

          PopupMenuButton<String>(
            color: t.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 16,
            offset: const Offset(0, 8),
            icon: Icon(Icons.more_vert_rounded,
                color: _hovered ? t.textSec : t.textMuted, size: 18),
            onSelected: (v) {
              if (v == 'edit')    widget.onEdit();
              if (v == 'primary') widget.onSetPrimary();
              if (v == 'delete')  widget.onDelete();
            },
            itemBuilder: (_) => [
              if (!widget.contact.isPrimary)
                _menuItem(t, 'primary', '★  Set as primary', _kVioletLight),
              _menuItem(t, 'edit',   '✎  Edit contact',  t.textPri),
              _menuItem(t, 'delete', '✕  Remove',         _kCrimsonSoft),
            ],
          ),
        ]),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(_T t, String value, String label, Color color) =>
      PopupMenuItem(value: value, height: 40,
          child: Text(label, style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600)));
}

// ─────────────────────────────────────────────
//  ADD BUTTON
// ─────────────────────────────────────────────

class _AddButton extends StatefulWidget {
  final _T t;
  final VoidCallback onTap;
  const _AddButton({required this.t, required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? _kViolet.withOpacity(t.d ? 0.08 : 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _hovered ? _kViolet.withOpacity(0.4) : t.borderBrt),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_rounded,
                color: _hovered ? _kVioletLight : t.textSec, size: 18),
            const SizedBox(width: 8),
            Text('Add emergency contact', style: TextStyle(
                color: _hovered ? _kVioletLight : t.textSec,
                fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CONTACT FORM DIALOG
// ─────────────────────────────────────────────

class _ContactFormDialog extends StatefulWidget {
  final EmergencyContact? existing;
  final Function(EmergencyContact) onSave;
  const _ContactFormDialog({this.existing, required this.onSave});

  @override
  State<_ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String _relation = 'Family';
  bool   _saving   = false;

  static const _relations = [
    'Family','Parent','Sibling','Spouse','Friend','Doctor','Caretaker','Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.existing?.name  ?? '');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
    _relation  = widget.existing?.relation ?? 'Family';
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t      = _T(isDark);
    final isEdit = widget.existing != null;

    return Dialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _kViolet.withOpacity(t.d ? 0.1 : 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kViolet.withOpacity(0.2)),
                  ),
                  child: const Center(
                      child: Icon(Icons.person_rounded, color: _kVioletLight, size: 18)),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isEdit ? 'Edit Contact' : 'New Contact', style: TextStyle(
                      color: t.textPri, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('Will be notified during SOS',
                      style: TextStyle(color: t.textSec, fontSize: 11)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: t.surfaceHi, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.close_rounded, color: t.textSec, size: 16),
                  ),
                ),
              ]),

              const SizedBox(height: 24),
              _buildDivider(t),
              const SizedBox(height: 24),

              // Name
              _buildLabel('Full name', t),
              const SizedBox(height: 6),
              _buildTextField(t: t, controller: _nameCtrl, hint: 'e.g. Priya Sharma',
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null),

              const SizedBox(height: 18),

              // Phone
              _buildLabel('Phone number', t),
              const SizedBox(height: 6),
              _buildTextField(
                t: t,
                controller: _phoneCtrl,
                hint: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                prefix: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('+91', style: TextStyle(
                      color: _kVioletLight, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  final c = v.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
                  if (c.length < 10 || !RegExp(r'^\d+$').hasMatch(c)) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Relation
              _buildLabel('Relation', t),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _relations.map((r) {
                  final selected = r == _relation;
                  final color    = _colorFor(r);
                  return GestureDetector(
                    onTap: () => setState(() => _relation = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(t.d ? 0.12 : 0.08)
                            : t.surfaceHi,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? color.withOpacity(0.45) : t.borderBrt,
                          width: selected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(r, style: TextStyle(
                        color: selected ? color : t.textSec,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      )),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Buttons
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: t.surfaceHi,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.borderBrt),
                      ),
                      child: Center(child: Text('Cancel', style: TextStyle(
                          color: t.textSec, fontWeight: FontWeight.w600, fontSize: 13))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _saving ? null : _save,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _saving
                            ? [_kViolet.withOpacity(0.4), _kViolet.withOpacity(0.4)]
                            : [_kViolet, const Color(0xFF5B21B6)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _saving ? [] : [BoxShadow(
                            color: _kViolet.withOpacity(0.35),
                            blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(child: _saving
                          ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEdit ? 'Save changes' : 'Add contact',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, _T t) => Text(text, style: TextStyle(
      color: t.textSec, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8));

  Widget _buildDivider(_T t) => Container(height: 1,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [
        Colors.transparent, t.borderBrt, Colors.transparent])));

  Widget _buildTextField({
    required _T t,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: t.textPri, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: t.textMuted, fontSize: 13),
        prefixIcon: prefix,
        filled: true,
        fillColor: t.surfaceHi,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: t.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: t.borderBrt)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kViolet, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kCrimson)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kCrimson, width: 1.5)),
        errorStyle: const TextStyle(color: _kCrimsonSoft, fontSize: 11),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    widget.onSave(EmergencyContact(
      name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(),
      relation: _relation, isPrimary: widget.existing?.isPrimary ?? false,
    ));
    if (mounted) Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────
//  CONFIRM DIALOG
// ─────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String title, body, confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title, required this.body, required this.confirmLabel,
    required this.confirmColor, required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = _T(isDark);

    return Dialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
                color: t.textPri, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(body, style: TextStyle(color: t.textSec, fontSize: 13, height: 1.6)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: t.textSec)))),
              const SizedBox(width: 8),
              Expanded(child: GestureDetector(
                onTap: () { Navigator.pop(context); onConfirm(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(t.d ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: confirmColor.withOpacity(0.3)),
                  ),
                  child: Center(child: Text(confirmLabel, style: TextStyle(
                      color: confirmColor, fontWeight: FontWeight.w700, fontSize: 13))),
                ),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE CAPABILITIES STRIP
//  Compact icon-grid showing what SOS can do on this device.
//  Used only in the mobile shell — replaces desktop platform card.
// ─────────────────────────────────────────────
class _MobileCapStrip extends StatelessWidget {
  final _T t;
  final bool isDark;
  const _MobileCapStrip({required this.t, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final caps = [
      (Icons.sms_rounded,           'Auto SMS',  'GPS attached',       _kCrimson),
      (Icons.vibration_rounded,     'Shake',     'Double = alert',     const Color(0xFF7C3AED)),
      (Icons.location_on_rounded,   'GPS',       'Precise coords',     const Color(0xFF0891B2)),
      (Icons.notifications_rounded, 'Haptics',   'Vibe feedback',      const Color(0xFF059669)),
    ];
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: t.surfaceUp,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.smartphone_rounded, color: _kVioletLight, size: 13),
            const SizedBox(width: 7),
            const Text('MOBILE SOS CAPABILITIES', style: TextStyle(
                color: _kVioletLight, fontSize: 9.5,
                fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 12),
          Row(children: caps.asMap().entries.map((e) {
            final c = e.value;
            final isLast = e.key == caps.length - 1;
            return Expanded(child: Container(
                margin: EdgeInsets.only(right: isLast ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                    color: c.$4.withOpacity(isDark ? 0.07 : 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.$4.withOpacity(0.16))),
                child: Column(children: [
                  Icon(c.$1, color: c.$4, size: 18),
                  const SizedBox(height: 5),
                  Text(c.$2, textAlign: TextAlign.center, style: TextStyle(
                      color: t.textPri, fontSize: 9.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(c.$3, textAlign: TextAlign.center, style: TextStyle(
                      color: t.textSec, fontSize: 8.5, height: 1.2)),
                ])));
          }).toList()),
        ]));
  }
}