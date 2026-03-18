// lib/components/SOSFloatingButton.dart
// Drop this widget anywhere in your app's widget tree.
// It shows a persistent red SOS button — even on the translate screen.
// On mobile: also works via shake (configured in main.dart).
// Configures the SOS message type (general, medical, police) and opens a full-screen SOS page with more details and options.

import 'package:flutter/material.dart';
import '../services/EmergencyService.dart';
import '../screens/EmergencyScreen.dart';

class SOSFloatingButton extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;

  const SOSFloatingButton({
    super.key,
    required this.toggleTheme,
    required this.setLocale,
  });

  @override
  State<SOSFloatingButton> createState() => _SOSFloatingButtonState();
}

class _SOSFloatingButtonState extends State<SOSFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini quick-action buttons when expanded
        if (_expanded) ...[
          _QuickSOSButton(
            label: 'I need help',
            emoji: '🆘',
            color: const Color(0xFFDC2626),
            onTap: () {
              setState(() => _expanded = false);
              EmergencyService.instance.triggerSOS(
                  type: SOSMessageType.generalHelp);
            },
          ),
          const SizedBox(height: 8),
          _QuickSOSButton(
            label: 'Medical',
            emoji: '🏥',
            color: const Color(0xFFE53E3E),
            onTap: () {
              setState(() => _expanded = false);
              EmergencyService.instance.triggerSOS(
                  type: SOSMessageType.medical);
            },
          ),
          const SizedBox(height: 8),
          _QuickSOSButton(
            label: 'Police',
            emoji: '👮',
            color: const Color(0xFF0284C7),
            onTap: () {
              setState(() => _expanded = false);
              EmergencyService.instance.triggerSOS(
                  type: SOSMessageType.police);
            },
          ),
          const SizedBox(height: 8),
          _QuickSOSButton(
            label: 'Full screen',
            emoji: '📋',
            color: const Color(0xFF7C3AED),
            onTap: () {
              setState(() => _expanded = false);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a, __) => EmergencyScreen(
                    toggleTheme: widget.toggleTheme,
                    setLocale: widget.setLocale,
                  ),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // Main SOS FAB
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: _expanded ? 1.0 : _pulseAnim.value,
            child: child,
          ),
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            onLongPress: () {
              // Long press = immediate general SOS without opening menu
              setState(() => _expanded = false);
              EmergencyService.instance.triggerSOS(
                  type: SOSMessageType.generalHelp);
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _expanded ? '✕' : 'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: _expanded ? 16 : 13,
                    letterSpacing: _expanded ? 0 : 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickSOSButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _QuickSOSButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ]),
      ),
    );
  }
}