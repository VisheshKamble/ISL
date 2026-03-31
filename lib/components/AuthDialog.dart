// lib/components/AuthDialog.dart
//
// Colour scheme aligned to main.dart:
//   - All hardcoded purple/dark hex values replaced with Theme.of(context) tokens
//   - Uses colorScheme.primary (Apple Blue) as the accent instead of custom #7C3AED
//   - Surfaces, borders, and text pull from the same ColorScheme defined in VaniApp
//   - Dark/light mode handled automatically via ThemeData — no manual isDark branching
//     for colours

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/AppLocalizations.dart';
import '../services/SupabaseService.dart';
import '../services/EmergencyService.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/EmergencyContact.dart';

void showAuthDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.60),
    builder: (_) => const VaniAuthCard(),
  );
}

class AuthScreen extends StatelessWidget {
  final VoidCallback? onAuthenticated;
  const AuthScreen({super.key, this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: VaniAuthCard(
                embedded: true,
                canClose: false,
                onAuthenticated: onAuthenticated,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VaniAuthCard extends StatefulWidget {
  final bool embedded;
  final bool canClose;
  final VoidCallback? onAuthenticated;

  const VaniAuthCard({
    super.key,
    this.embedded = false,
    this.canClose = true,
    this.onAuthenticated,
  });

  @override
  State<VaniAuthCard> createState() => _VaniAuthDialogState();
}

class _VaniAuthDialogState extends State<VaniAuthCard>
    with SingleTickerProviderStateMixin {
  static const bool _authBackendEnabled = true;

  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() => _isLogin = !_isLogin);
    _anim
      ..reset()
      ..forward();
  }

  String _fakeEmail(String username) =>
      '${username.toLowerCase().replaceAll(' ', '_')}@vani.app';

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final l = AppLocalizations.of(context);

    try {
      if (!_authBackendEnabled) {
        if (mounted) {
          if (!widget.embedded) {
            Navigator.pop(context);
          }
          widget.onAuthenticated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.t('auth_backend_disabled')),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      final sb = Supabase.instance.client;
      final fakeEmail = _fakeEmail(_usernameCtrl.text.trim());

      if (_isLogin) {
        final response = await sb.auth.signInWithPassword(
          email: fakeEmail,
          password: _passwordCtrl.text.trim(),
        );
        if (response.session == null) {
          _showError(l.t('auth_login_failed'));
          return;
        }
        final box = Hive.box<EmergencyContact>('emergency_contacts');
        await box.clear();
        await SupabaseService.instance.upsertUserProfile();
        await EmergencyService.instance.syncFromSupabase();
      } else {
        final response = await sb.auth.signUp(
          email: fakeEmail,
          password: _passwordCtrl.text.trim(),
        );
        if (response.session == null) {
          _showError(l.t('auth_signup_failed'));
          return;
        }
        await SupabaseService.instance.upsertUserProfile(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
        await EmergencyService.instance.pushLocalContactsToSupabase();
      }

      if (mounted) {
        if (!widget.embedded) {
          Navigator.pop(context);
        }
        widget.onAuthenticated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Welcome back!' : 'Account created!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) _showError('${l.t('auth_error_prefix')}: ${e.message}');
    } on PostgrestException catch (e) {
      if (mounted) _showError('${l.t('auth_database_error_prefix')}: ${e.message}');
    } catch (e) {
      if (mounted) _showError('${l.t('auth_unexpected_error_prefix')}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // ── Pull every colour from the same ThemeData defined in main.dart ──────
    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary; // _kAppleBlue / _kAppleBlueDark
    final accentLight = cs.secondary; // _kAppleIndigo — used for glow
    final card = Theme.of(context).cardColor; // _lSurface / _dSurface
    final surface = cs.surfaceContainer; // _lSurface2 / _dSurface2
    final border = cs.outline; // _lSeparator / _dSeparator
    final textPrimary = cs.onSurface; // _lLabel / _dLabel
    final textMuted = cs.onSurface.withOpacity(0.55);

    final cardBody = FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: accentLight.withOpacity(0.14),
                  blurRadius: 48,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // ── Header ────────────────────────────────────────────
                    Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 20,
                              decoration: BoxDecoration(
                                // Single solid accent — no gradient, matches
                                // main.dart's flat Apple colour usage
                                color: accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'VANI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: accent,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (widget.canClose)
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: border.withOpacity(0.28),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Tab switcher ──────────────────────────────────────
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          _Tab(
                            label: l.t('auth_tab_login'),
                            selected: _isLogin,
                            accent: accent,
                            onTap: _isLogin ? null : _switchMode,
                            textMuted: textMuted,
                          ),
                          _Tab(
                            label: l.t('auth_tab_signup'),
                            selected: !_isLogin,
                            accent: accent,
                            onTap: _isLogin ? _switchMode : null,
                            textMuted: textMuted,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Username ──────────────────────────────────────────
                    _Field(
                      controller: _usernameCtrl,
                      label: l.t('auth_username_label'),
                      hint: l.t('auth_username_hint'),
                      prefixIcon: Icons.alternate_email_rounded,
                      accent: accent,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return l.t('auth_username_required');
                        if (v.trim().length < 3) return l.t('auth_min_3_chars');
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Sign-up only fields ───────────────────────────────
                    if (!_isLogin) ...[
                      _Field(
                        controller: _nameCtrl,
                        label: l.t('auth_full_name_label'),
                        hint: l.t('auth_full_name_hint'),
                        prefixIcon: Icons.person_outline_rounded,
                        accent: accent,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return l.t('auth_name_required');
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _Field(
                        controller: _phoneCtrl,
                        label: l.t('auth_phone_label'),
                        hint: l.t('auth_phone_hint'),
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        accent: accent,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return l.t('auth_phone_required');
                          if (v.trim().length < 7)
                            return l.t('auth_phone_invalid');
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Password ──────────────────────────────────────────
                    _Field(
                      controller: _passwordCtrl,
                      label: l.t('auth_password_label'),
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      accent: accent,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: textMuted,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l.t('auth_required');
                        if (!_isLogin && v.length < 6) return l.t('auth_min_6_chars');
                        return null;
                      },
                    ),

                    if (_isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            /* TODO: forgot password */
                          },
                          child: Text(
                            l.t('auth_forgot_password'),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Submit button ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: _loading
                          ? Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: accent,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isLogin ? l.t('auth_sign_in') : l.t('auth_create_account'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 14),

                    // ── Footer ────────────────────────────────────────────
                    Center(
                      child: Text(
                        l.t('auth_footer_tagline'),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: textMuted.withOpacity(0.65),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.embedded) return cardBody;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: cardBody,
    );
  }
}

// ─────────────────────────────────────────────
//  Tab pill
// ─────────────────────────────────────────────

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
    required this.textMuted,
  });
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback? onTap;
  final Color textMuted;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          // Selected tab uses the same Apple Blue from main.dart
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  Text field
// ─────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.accent,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label, hint;
  final IconData prefixIcon;
  final Color accent, surface, border, textPrimary, textMuted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: textMuted.withOpacity(0.45),
            fontSize: 13,
          ),
          prefixIcon: Icon(prefixIcon, color: textMuted, size: 17),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            // Focus ring uses the same Apple Blue from main.dart
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            // Error uses colorScheme.error → _kAppleRed from main.dart
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}
