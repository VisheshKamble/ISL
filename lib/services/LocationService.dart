// Since both mobile and web now use geolocator (which handles its own
// platform differences internally), we no longer need a conditional import.
// One file. One API. Works on Android, iOS, and Web.

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? error;
  final bool isAvailable;

  const LocationResult({
    this.latitude,
    this.longitude,
    this.error,
    required this.isAvailable,
  });

  /// Google Maps link if coordinates are available
  String get mapsLink {
    if (!isAvailable || latitude == null || longitude == null) return '';
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  /// Short coordinate string for display
  String get displayString {
    if (!isAvailable || latitude == null || longitude == null) {
      return 'Location unavailable';
    }
    return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
  }

  @override
  String toString() =>
      'LocationResult(lat: $latitude, lng: $longitude, available: $isAvailable, error: $error)';
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  LocationResult? _lastKnownLocation;
  LocationResult? get lastKnownLocation => _lastKnownLocation;

  /// Gets current location. Works on Android, iOS, and Web.
  /// geolocator handles platform differences internally.
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          isAvailable: false,
          error: 'Location services are disabled.',
        );
      }

      // Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            isAvailable: false,
            error: 'Location permission denied.',
          );
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          isAvailable: false,
          error: 'Location permission permanently denied.',
        );
      }

      // Get position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final result = LocationResult(
        isAvailable: true,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _lastKnownLocation = result;
      return result;
    } on TimeoutException {
      // Try last known cached position before giving up
      try {
        final Position? last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          final result = LocationResult(
            isAvailable: true,
            latitude: last.latitude,
            longitude: last.longitude,
          );
          _lastKnownLocation = result;
          return result;
        }
      } catch (_) {}
      return const LocationResult(
        isAvailable: false,
        error: 'GPS timed out. SOS will send without location.',
      );
    } catch (e) {
      return LocationResult(
        isAvailable: false,
        error: 'Location error: ${e.toString()}',
      );
    }
  }

  /// Gets location with a fallback chain:
  /// fresh GPS → last known GPS → "unavailable"
  /// SOS is never blocked waiting for GPS.
  Future<LocationResult> getLocationWithFallback({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      final result = await getCurrentLocation().timeout(timeout);
      if (result.isAvailable) return result;
      if (_lastKnownLocation?.isAvailable == true) return _lastKnownLocation!;
      return result;
    } catch (_) {
      if (_lastKnownLocation?.isAvailable == true) return _lastKnownLocation!;
      return const LocationResult(
        isAvailable: false,
        error: 'Could not determine location.',
      );
    }
  }

  /// Builds the full SOS message with location and time injected.
  /// Supports two modes:
  /// 1. Template messages (contain {LOCATION} / {TIME} placeholders) —
  ///    used by formal scenario messages in EmergencyScreen.
  /// 2. Legacy plain messages — location appended at end.
  String buildEmergencyMessage({
    required String baseMessage,
    required LocationResult location,
    String appName = 'VANI',
  }) {
    final now = DateTime.now();
    final timeStr =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}  '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    final locationStr = location.isAvailable
        ? '${location.mapsLink}\nCoordinates: ${location.displayString}'
        : 'Could not be determined automatically.';

    // Mode 1: template — inject placeholders
    if (baseMessage.contains('{LOCATION}') || baseMessage.contains('{TIME}')) {
      return baseMessage
          .replaceAll('{LOCATION}', locationStr)
          .replaceAll('{TIME}', timeStr);
    }

    // Mode 2: legacy — append location
    final buffer = StringBuffer();
    buffer.write('EMERGENCY ALERT — VANI\n\n');
    buffer.write(baseMessage);
    if (location.isAvailable) {
      buffer.write('\n\n📍 Location: ${location.mapsLink}');
      buffer.write('\nCoordinates: ${location.displayString}');
    } else {
      buffer.write('\n\n📍 Location: Could not be determined automatically.');
    }
    buffer.write('\n\nTime: $timeStr');
    buffer.write('\n— Sent via VANI Emergency SOS');
    return buffer.toString();
  }
}
