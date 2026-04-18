import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:shake/shake.dart';

import '../l10n/AppLocalizations.dart';
import '../models/EmergencyContact.dart';
import '../Utils/PlatformHelper.dart';
import 'backend_config.dart';
import 'LocationService.dart';
//  SOS MESSAGE TYPES  (unchanged)

enum SOSMessageType { generalHelp, medical, police, fire, custom }

String _localizedSosTypeLabel(AppLocalizations l, SOSMessageType type) {
  switch (type) {
    case SOSMessageType.generalHelp:
      return l.t('sos_general_title');
    case SOSMessageType.medical:
      return l.t('sos_medical_title');
    case SOSMessageType.police:
      return l.t('sos_police_title');
    case SOSMessageType.fire:
      return l.t('sos_fire_title');
    case SOSMessageType.custom:
      return l.t('sos_label_emergency');
  }
}

String _defaultSosTemplateKey(SOSMessageType type) {
  switch (type) {
    case SOSMessageType.generalHelp:
      return 'sos_sms_general_template';
    case SOSMessageType.medical:
      return 'sos_sms_medical_template';
    case SOSMessageType.police:
      return 'sos_sms_police_template';
    case SOSMessageType.fire:
      return 'sos_sms_fire_template';
    case SOSMessageType.custom:
      return 'sos_sms_general_template';
  }
}

extension SOSMessageTypeExt on SOSMessageType {
  String get label {
    switch (this) {
      case SOSMessageType.generalHelp:
        return 'General Emergency';
      case SOSMessageType.medical:
        return 'Medical Emergency';
      case SOSMessageType.police:
        return 'Safety Emergency';
      case SOSMessageType.fire:
        return 'Fire Emergency';
      case SOSMessageType.custom:
        return 'Emergency Alert';
    }
  }

  String get fullMessage => _buildBase(null);

  String _buildBase(String? locationBlock) {
    final loc =
        locationBlock ?? 'Location data was not available at time of alert.';
    switch (this) {
      case SOSMessageType.generalHelp:
        return 'URGENT — EMERGENCY ALERT\n\n'
            'This message was sent automatically by the VANI sign-language assistance app.\n\n'
            'The person who sent this alert is DEAF or MUTE and cannot speak or call for help. '
            'They require your immediate assistance.\n\n'
            'Please do one or more of the following right now:\n'
            '  1. Call them back at the number associated with this contact.\n'
            '  2. Go to their current location.\n'
            '  3. Contact emergency services (Dial 112) on their behalf.\n\n'
            'They will respond via text message or sign language.\n\n'
            'Current location:\n$loc\n\n'
            'Time of alert: {TIME}\n\n'
            '— Sent automatically via VANI Emergency SOS';

      case SOSMessageType.medical:
        return 'URGENT — MEDICAL EMERGENCY\n\n'
            'This message was sent automatically by the VANI sign-language assistance app.\n\n'
            'The person who sent this alert is DEAF or MUTE and is experiencing a medical emergency. '
            'They are unable to call for help verbally.\n\n'
            'Immediate actions required:\n'
            '  1. Call an ambulance — Dial 108.\n'
            '  2. Go to their location immediately.\n'
            '  3. Contact a doctor or nearby hospital.\n\n'
            'Current location:\n$loc\n\n'
            'Time of alert: {TIME}\n\n'
            '— Sent automatically via VANI Emergency SOS';

      case SOSMessageType.police:
        return 'URGENT — SAFETY EMERGENCY\n\n'
            'This message was sent automatically by the VANI sign-language assistance app.\n\n'
            'The person who sent this alert is DEAF or MUTE and is in a dangerous situation. '
            'They are unable to call the police verbally.\n\n'
            'Immediate actions required:\n'
            '  1. Call the police — Dial 100.\n'
            '  2. Go to their location immediately.\n'
            '  3. Alert someone nearby who can assist them.\n\n'
            'Current location:\n$loc\n\n'
            'Time of alert: {TIME}\n\n'
            '— Sent automatically via VANI Emergency SOS';

      case SOSMessageType.fire:
        return 'URGENT — FIRE OR SMOKE EMERGENCY\n\n'
            'This message was sent automatically by the VANI sign-language assistance app.\n\n'
            'The person who sent this alert is DEAF or MUTE and is reporting a fire or smoke emergency. '
            'They cannot call the fire brigade verbally.\n\n'
            'Immediate actions required:\n'
            '  1. Call the fire brigade — Dial 101.\n'
            '  2. Ensure evacuation of the building.\n'
            '  3. Alert people near this location.\n\n'
            'Current location:\n$loc\n\n'
            'Time of alert: {TIME}\n\n'
            '— Sent automatically via VANI Emergency SOS';

      case SOSMessageType.custom:
        return 'URGENT — EMERGENCY ALERT\n\n'
            'This message was sent automatically by the VANI sign-language assistance app.\n\n'
            'The person who sent this alert is DEAF or MUTE and requires immediate assistance. '
            'They cannot communicate verbally.\n\n'
            'Please contact them or go to their location immediately.\n\n'
            'Current location:\n$loc\n\n'
            'Time of alert: {TIME}\n\n'
            '— Sent automatically via VANI Emergency SOS';
    }
  }
}
//  EMERGENCY SERVICE  (singleton)

class EmergencyService {
  static EmergencyService? _instance;
  static EmergencyService get instance => _instance ??= EmergencyService._();
  EmergencyService._();

  static const String _boxName = 'emergency_contacts';

  ShakeDetector? _shakeDetector;
  bool _shakeActive = false;
  bool _isTriggering = false;
  BuildContext? _context;


  Future<void> init(BuildContext context) async {
    _context = context;
    await _openBox();

    _startShakeDetection();
  }

  void updateContext(BuildContext context) => _context = context;

  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      Hive.registerAdapter(EmergencyContactAdapter());
      await Hive.openBox<EmergencyContact>(_boxName);
    }
  }


  /// Legacy sync hook kept for backward compatibility.
  /// No-op in local-only mode.
  Future<void> syncFromSupabase() async {}

  /// Legacy sync hook kept for backward compatibility.
  /// No-op in local-only mode.
  Future<void> pushLocalContactsToSupabase() async {}


  void _startShakeDetection() {
    if (!PlatformHelper.supportsShake) return;
    if (_shakeDetector != null) return;

    try {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: _onShakeDetected,
        minimumShakeCount: 2,
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 2.5,
      );
    } catch (_) {}
  }

  void _onShakeDetected(ShakeEvent _) {
    if (_shakeActive) return;
    if (_isTriggering) return;
    if (getContacts().isEmpty) return;

    _shakeActive = true;
    triggerSOS(type: SOSMessageType.generalHelp, triggeredByShake: true).then((
      _,
    ) {
      Future.delayed(const Duration(seconds: 5), () => _shakeActive = false);
    });
  }

  void stopShakeDetection() {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
    _shakeActive = false;
  }

  void restartShakeDetection() {
    stopShakeDetection();
    _startShakeDetection();
  }

  bool get shakeActive =>
      _shakeDetector != null && PlatformHelper.supportsShake;


  Box<EmergencyContact> get _box => Hive.box<EmergencyContact>(_boxName);

  List<EmergencyContact> getContacts() => _box.values.toList();

  /// Add contact to local Hive storage.
  Future<void> addContact(EmergencyContact contact) async {
    if (_box.length >= 5) {
      throw Exception('Maximum 5 emergency contacts allowed.');
    }
    if (!contact.isValid) {
      throw Exception('Invalid phone number: ${contact.phone}');
    }
    if (_box.isEmpty) contact.isPrimary = true;

    await _box.add(contact);
  }

  /// Update contact in local Hive storage.
  Future<void> updateContact(int index, EmergencyContact updated) async {
    if (!updated.isValid) throw Exception('Invalid phone number.');

    await _box.putAt(index, updated);
  }

  /// Delete contact from local Hive storage.
  Future<void> deleteContact(int index) async {
    await _box.deleteAt(index);

    // Reassign primary if needed
    final remaining = getContacts();
    if (remaining.isNotEmpty && !remaining.any((c) => c.isPrimary)) {
      remaining.first.isPrimary = true;
      await remaining.first.save();
    }
  }

  Future<void> setPrimary(int index) async {
    final contacts = getContacts();
    for (int i = 0; i < contacts.length; i++) {
      contacts[i].isPrimary = (i == index);
      await contacts[i].save();
    }
  }

  bool get hasContacts => _box.isNotEmpty;
  int get contactCount => _box.length;


  Future<SOSResult> triggerSOS({
    required SOSMessageType type,
    String? customMessage,
    bool triggeredByShake = false,
  }) async {
    if (_isTriggering) {
      return SOSResult(
        success: false,
        reason: 'SOS already in progress.',
        platform: PlatformHelper.platformName,
      );
    }
    _isTriggering = true;

    try {
      final contacts = getContacts();
      _triggerHaptics();

      final location = await _requireLiveLocationForSOS();
      if (!location.isAvailable) {
        final l = _context != null ? AppLocalizations.of(_context!) : null;
        return SOSResult(
          success: false,
          reason:
              l?.t('sos_location_required_reason') ??
              'Live location is required for SOS.',
          platform: PlatformHelper.platformName,
        );
      }

      final now = DateTime.now();
      final timeStr =
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}  '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      final locationBlock = '${location.mapsLink}\n(${location.displayString})';

      final l = _context != null ? AppLocalizations.of(_context!) : null;
      final resolvedMessage = customMessage ?? l?.t(_defaultSosTemplateKey(type));

      String fullMsg;
      if (resolvedMessage != null &&
          (resolvedMessage.contains('{LOCATION}') ||
              resolvedMessage.contains('{TIME}'))) {
        fullMsg = resolvedMessage
            .replaceAll('{LOCATION}', locationBlock)
            .replaceAll('{TIME}', timeStr);
      } else if (resolvedMessage != null) {
        fullMsg = resolvedMessage;
      } else {
        fullMsg = type._buildBase(locationBlock).replaceAll('{TIME}', timeStr);
      }

      if (contacts.isEmpty) {
        if (_context != null) _showNoContactsDialog(_context!);
        return SOSResult(
          success: false,
          reason: 'No emergency contacts configured.',
          platform: PlatformHelper.platformName,
        );
      }

      if (PlatformHelper.isMobile) {
        return await _sendMobileSOS(
          contacts: contacts,
          message: fullMsg,
          location: location,
          type: type,
        );
      } else if (PlatformHelper.isWeb) {
        return await _sendWebSOS(
          contacts: contacts,
          message: fullMsg,
          location: location,
          type: type,
        );
      } else {
        final result = await _sendViaBackendTwilio(
          contacts: contacts,
          message: fullMsg,
          location: location,
          type: type,
        );
        if (_context != null && result.success) {
          _showDesktopSOSDialog(_context!, fullMsg, contacts);
        }
        return result;
      }
    } finally {
      await Future.delayed(const Duration(seconds: 3));
      _isTriggering = false;
    }
  }


  Future<SOSResult> _sendMobileSOS({
    required List<EmergencyContact> contacts,
    required String message,
    required LocationResult location,
    required SOSMessageType type,
  }) async {
    return _sendViaBackendTwilio(
      contacts: contacts,
      message: message,
      location: location,
      type: type,
    );
  }


  Future<SOSResult> _sendWebSOS({
    required List<EmergencyContact> contacts,
    required String message,
    required LocationResult location,
    required SOSMessageType type,
  }) async {
    final result = await _sendViaBackendTwilio(
      contacts: contacts,
      message: message,
      location: location,
      type: type,
    );

    if (result.success && _context != null) {
      _showWebSOSModal(
        context: _context!,
        contacts: contacts,
        message: message,
        location: location,
        type: type,
      );
    }

    return result;
  }

  Future<SOSResult> _sendViaBackendTwilio({
    required List<EmergencyContact> contacts,
    required String message,
    required LocationResult location,
    required SOSMessageType type,
  }) async {
    final l = _context != null ? AppLocalizations.of(_context!) : null;
    final validContacts = contacts
        .where((c) => c.isValid)
        .take(5)
        .map(
          (c) => {
            'name': c.name,
            'phone': c.internationalPhone,
          },
        )
        .toList();

    if (validContacts.isEmpty) {
      return SOSResult(
        success: false,
        reason: l?.t('sos_no_contacts_body') ?? 'No emergency contacts configured.',
        platform: PlatformHelper.platformName,
      );
    }

    final payload = {
      'type': type.name,
      'message': message,
      'contacts': validContacts,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'display': location.displayString,
        'maps_link': location.mapsLink,
      },
      'platform': PlatformHelper.platformName,
      'sent_at': DateTime.now().toIso8601String(),
    };

    final errors = <String>[];
    for (final base in BackendConfig.apiBaseCandidates) {
      try {
        final uri = Uri.parse('$base/sos/send');
        final headers = <String, String>{
          'Content-Type': 'application/json',
        };
        if (BackendConfig.twilioAccountSid.isNotEmpty) {
          headers['x-twilio-account-sid'] = BackendConfig.twilioAccountSid;
        }
        if (BackendConfig.twilioAuthToken.isNotEmpty) {
          headers['x-twilio-auth-token'] = BackendConfig.twilioAuthToken;
        }
        if (BackendConfig.twilioFromNumber.isNotEmpty) {
          headers['x-twilio-from-number'] = BackendConfig.twilioFromNumber;
        }
        final res = await http
            .post(
              uri,
              headers: headers,
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 15));

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          final sentCount = (body['sent_count'] as num?)?.toInt() ?? 0;
          final total =
              (body['total_contacts'] as num?)?.toInt() ?? validContacts.length;
          final backendErrors = ((body['errors'] as List?) ?? const [])
              .map((e) => e.toString())
              .toList();
          final success = (body['success'] as bool?) ?? (sentCount > 0);
          final reason =
              body['message']?.toString() ??
              body['reason']?.toString() ??
              (success
                  ? l?.t('sos_sent_web') ?? 'SOS dispatched.'
                  : l?.t('sos_dispatch_failed') ?? 'Failed to dispatch SOS.');

          return SOSResult(
            success: success,
            reason: reason,
            platform: PlatformHelper.platformName,
            sentCount: sentCount,
            totalContacts: total,
            errors: backendErrors,
          );
        }

        errors.add('HTTP ${res.statusCode}: ${res.body}');
      } catch (e) {
        errors.add('$base -> $e');
      }
    }

    return SOSResult(
      success: false,
      reason:
          l?.t('sos_backend_unreachable') ??
          'Could not reach SOS server. Please try again.',
      platform: PlatformHelper.platformName,
      totalContacts: validContacts.length,
      errors: errors,
    );
  }

  void _triggerHaptics() {
    if (!PlatformHelper.canVibrate) return;
    try {
      Vibration.vibrate(
        pattern: [0, 300, 150, 300, 150, 600],
        intensities: [0, 255, 0, 255, 0, 255],
      );
    } catch (_) {}
  }
  //  DIALOGS (all unchanged)

  void _showNoContactsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => _SosDialog(
        isDark: isDark,
        title: l.t('sos_no_contacts_title'),
        body: l.t('sos_no_contacts_body'),
        accentColor: const Color(0xFFD97706),
        actions: [
          _SosDialogAction(
            label: l.t('common_ok'),
            isPrimary: false,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showDesktopSOSDialog(
    BuildContext context,
    String message,
    List<EmergencyContact> contacts,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => _DesktopSOSDialog(
        isDark: isDark,
        message: message,
        contacts: contacts,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showWebSOSModal({
    required BuildContext context,
    required List<EmergencyContact> contacts,
    required String message,
    required LocationResult location,
    required SOSMessageType type,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WebSOSModal(
        contacts: contacts,
        message: message,
        location: location,
        type: type,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<LocationResult> _requireLiveLocationForSOS() async {
    final location = await LocationService.instance.getLocationWithFallback(
      timeout: const Duration(seconds: 8),
    );
    if (location.isAvailable) return location;

    if (_context == null || (!PlatformHelper.isMobile && !PlatformHelper.isWeb)) {
      return location;
    }

    final allow = await _askLocationForThisSOS();
    if (!allow) {
      return const LocationResult(
        isAvailable: false,
        error: 'Location permission not granted for SOS.',
      );
    }

    while (true) {
      final retryLocation = await LocationService.instance.getLocationWithFallback(
        timeout: const Duration(seconds: 10),
      );
      if (retryLocation.isAvailable) return retryLocation;

      final shouldRetry = await _showLocationRetryDialog(
        retryLocation.error,
      );
      if (!shouldRetry) return retryLocation;
    }
  }

  Future<bool> _askLocationForThisSOS() async {
    if (_context == null) return true;
    if (!PlatformHelper.isMobile && !PlatformHelper.isWeb) return true;

    final result = await showDialog<bool>(
      context: _context!,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final t = _DT(isDark);
        final l = AppLocalizations.of(ctx);
        return AlertDialog(
          backgroundColor: t.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border2),
          ),
          title: Text(
            l.t('sos_location_required_title'),
            style: TextStyle(
              color: t.textPri,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            l.t('sos_location_required_body'),
            style: TextStyle(
              color: t.textSec,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l.t('common_close'),
                style: TextStyle(color: t.textSec, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.t('sos_allow_location'),
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _showLocationRetryDialog(String? error) async {
    if (_context == null) return false;

    final result = await showDialog<bool>(
      context: _context!,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final t = _DT(isDark);
        final l = AppLocalizations.of(ctx);
        final body = l.t('sos_location_retry_body').replaceAll(
          '{error}',
          (error ?? l.t('sos_location_unavailable')).trim(),
        );

        return AlertDialog(
          backgroundColor: t.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border2),
          ),
          title: Text(
            l.t('sos_location_required_title'),
            style: TextStyle(
              color: t.textPri,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            body,
            style: TextStyle(
              color: t.textSec,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l.t('common_close'),
                style: TextStyle(color: t.textSec, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.t('common_retry'),
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void dispose() => stopShakeDetection();
}
//  SOS RESULT

class SOSResult {
  final bool success;
  final String reason;
  final String platform;
  final int sentCount;
  final int totalContacts;
  final List<String> errors;

  const SOSResult({
    required this.success,
    required this.reason,
    required this.platform,
    this.sentCount = 0,
    this.totalContacts = 0,
    this.errors = const [],
  });
}
//  DESIGN TOKENS

class _DT {
  final bool d;
  const _DT(this.d);
  Color get bg => d ? const Color(0xFF06060E) : const Color(0xFFF5F5FA);
  Color get surface => d ? const Color(0xFF0D0D1A) : Colors.white;
  Color get card => d ? const Color(0xFF13131F) : const Color(0xFFF8F8FC);
  Color get border => d ? const Color(0xFF1E1E30) : const Color(0xFFE2E2F0);
  Color get border2 => d ? const Color(0xFF2A2A40) : const Color(0xFFCCCCE0);
  Color get textPri => d ? const Color(0xFFF0EEFF) : const Color(0xFF0A0A1F);
  Color get textSec => d ? const Color(0xFF6A6A8A) : const Color(0xFF5A5A80);
  Color get textMut => d ? const Color(0xFF2E2E48) : const Color(0xFFAAAAAA);
  static const crimson = Color(0xFFDC2626);
  static const crimsonSoft = Color(0xFFEF4444);
  static const violet = Color(0xFF7C3AED);
  static const violetLight = Color(0xFFA78BFA);
  static const green = Color(0xFF059669);
  static const greenLight = Color(0xFF34D399);
  static const amber = Color(0xFFD97706);
}
//  GENERIC SOS DIALOG

class _SosDialogAction {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  const _SosDialogAction({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });
}

class _SosDialog extends StatelessWidget {
  final bool isDark;
  final String title, body;
  final Color accentColor;
  final List<_SosDialogAction> actions;
  const _SosDialog({
    required this.isDark,
    required this.title,
    required this.body,
    required this.accentColor,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final t = _DT(isDark);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.55 : 0.12),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withOpacity(0.22),
                          ),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: t.textPri,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: t.border),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    style: TextStyle(
                      color: t.textSec,
                      fontSize: 13,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: actions
                        .map(
                          (a) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: actions.indexOf(a) > 0 ? 8 : 0,
                              ),
                              child: GestureDetector(
                                onTap: a.onTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: a.isPrimary
                                        ? accentColor
                                        : accentColor.withOpacity(
                                            isDark ? 0.08 : 0.06,
                                          ),
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: a.isPrimary
                                          ? accentColor
                                          : accentColor.withOpacity(0.22),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      a.label,
                                      style: TextStyle(
                                        color: a.isPrimary
                                            ? Colors.white
                                            : accentColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//  DESKTOP SOS DIALOG (unchanged)

class _DesktopSOSDialog extends StatefulWidget {
  final bool isDark;
  final String message;
  final List<EmergencyContact> contacts;
  final VoidCallback onClose;
  const _DesktopSOSDialog({
    required this.isDark,
    required this.message,
    required this.contacts,
    required this.onClose,
  });
  @override
  State<_DesktopSOSDialog> createState() => _DesktopSOSDialogState();
}

class _DesktopSOSDialogState extends State<_DesktopSOSDialog> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.message));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = _DT(widget.isDark);
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.55 : 0.12),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: _DT.crimson,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _DT.crimson.withOpacity(
                            widget.isDark ? 0.10 : 0.07,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _DT.crimson.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.emergency_rounded,
                          color: _DT.crimsonSoft,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.t('sos_alert_ready_title'),
                              style: TextStyle(
                                color: t.textPri,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l.t('sos_alert_ready_body'),
                              style: TextStyle(color: t.textSec, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: t.border),
                  const SizedBox(height: 14),
                  Text(
                    l.t('sos_send_to'),
                    style: TextStyle(
                      color: t.textSec,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.contacts.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _DT.violetLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            c.name,
                            style: TextStyle(
                              color: t.textPri,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.phone,
                            style: TextStyle(
                              color: t.textSec,
                              fontSize: 12,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    child: SelectableText(
                      widget.message,
                      style: TextStyle(
                        color: t.textSec,
                        fontSize: 11.5,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _copy,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _copied
                                  ? _DT.green.withOpacity(
                                      widget.isDark ? 0.12 : 0.08,
                                    )
                                  : _DT.violet.withOpacity(
                                      widget.isDark ? 0.10 : 0.07,
                                    ),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: _copied
                                    ? _DT.green.withOpacity(0.3)
                                    : _DT.violet.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _copied
                                      ? Icons.check_rounded
                                      : Icons.copy_rounded,
                                  color: _copied
                                      ? _DT.greenLight
                                      : _DT.violetLight,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _copied
                                      ? l.t('sos_copied')
                                      : l.t('sos_copy_message'),
                                  style: TextStyle(
                                    color: _copied
                                        ? _DT.greenLight
                                        : _DT.violetLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: t.card,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: t.border2),
                            ),
                            child: Center(
                              child: Text(
                                l.t('common_close'),
                                style: TextStyle(
                                  color: t.textSec,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//  WEB SOS MODAL (unchanged)

class _WebSOSModal extends StatefulWidget {
  final List<EmergencyContact> contacts;
  final String message;
  final LocationResult location;
  final SOSMessageType type;
  final VoidCallback onClose;
  const _WebSOSModal({
    required this.contacts,
    required this.message,
    required this.location,
    required this.type,
    required this.onClose,
  });
  @override
  State<_WebSOSModal> createState() => _WebSOSModalState();
}

class _WebSOSModalState extends State<_WebSOSModal> {
  bool _messageCopied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.message));
    setState(() => _messageCopied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _messageCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = _DT(isDark);
    final l = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.6 : 0.14),
              blurRadius: 48,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _DT.crimson,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _DT.crimson.withOpacity(
                              isDark ? 0.10 : 0.07,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _DT.crimson.withOpacity(0.22),
                            ),
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: _DT.crimsonSoft,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.t('sos_activated_title'),
                                style: TextStyle(
                                  color: t.textPri,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _localizedSosTypeLabel(l, widget.type),
                                style: const TextStyle(
                                  color: _DT.crimsonSoft,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (widget.location.isAvailable
                                    ? _DT.green
                                    : _DT.amber)
                                .withOpacity(isDark ? 0.08 : 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              (widget.location.isAvailable
                                      ? _DT.green
                                      : _DT.amber)
                                  .withOpacity(0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.location.isAvailable
                                ? Icons.location_on_rounded
                                : Icons.location_off_rounded,
                            color: widget.location.isAvailable
                                ? _DT.greenLight
                                : _DT.amber,
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.location.isAvailable
                                  ? l
                                        .t('sos_location_attached')
                                        .replaceAll(
                                          '{location}',
                                          widget.location.displayString,
                                        )
                                  : l.t('sos_location_unavailable'),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: widget.location.isAvailable
                                    ? _DT.greenLight
                                    : _DT.amber,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.t('sos_send_to_contacts'),
                      style: TextStyle(
                        color: t.textSec,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.contacts.map(
                      (contact) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: contact.isPrimary
                                ? _DT.crimson.withOpacity(0.28)
                                : t.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            contact.name,
                                            style: TextStyle(
                                              color: t.textPri,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _DT.violet.withOpacity(
                                                isDark ? 0.10 : 0.07,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              contact.relation,
                                              style: const TextStyle(
                                                color: _DT.violetLight,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (contact.isPrimary) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _DT.crimson.withOpacity(
                                                  isDark ? 0.10 : 0.07,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                l.t('sos_primary_badge'),
                                                style: TextStyle(
                                                  color: _DT.crimsonSoft,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        contact.phone,
                                        style: TextStyle(
                                          color: t.textSec,
                                          fontSize: 11,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l.t('sos_auto_dispatched_contact'),
                              style: TextStyle(
                                color: t.textSec,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _copy,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: _messageCopied
                              ? _DT.green.withOpacity(isDark ? 0.10 : 0.07)
                              : t.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _messageCopied
                                ? _DT.green.withOpacity(0.3)
                                : t.border2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _messageCopied
                                  ? Icons.check_rounded
                                  : Icons.copy_rounded,
                              color: _messageCopied
                                  ? _DT.greenLight
                                  : t.textSec,
                              size: 14,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              _messageCopied
                                  ? l.t('sos_copied')
                                  : l.t('sos_copy_message'),
                              style: TextStyle(
                                color: _messageCopied
                                    ? _DT.greenLight
                                    : t.textSec,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: widget.onClose,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          l.t('sos_close_safe'),
                          style: TextStyle(
                            color: t.textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
