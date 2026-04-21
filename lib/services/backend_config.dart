import 'package:flutter/foundation.dart'; // Provides platform detection (web, android, etc.)

class BackendConfig {

  // Default backend host (your deployed Railway server)
  static const String defaultWebsocketHost =
      'vani-production.up.railway.app';

  // Override API base URL using environment variable (if provided)
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'ISL_API_BASE_URL',
    defaultValue: '',
  );

  // Separate override for mobile API base URL (useful for LAN testing)
  static const String _apiMobileBaseUrlOverride = String.fromEnvironment(
    'ISL_API_MOBILE_BASE_URL',
    defaultValue: '',
  );

  // Enable or disable WebSocket (default = enabled)
  static const bool websocketEnabled = bool.fromEnvironment(
    'ISL_WS_ENABLED',
    defaultValue: true,
  );

  // Full WebSocket URL override (if provided externally)
  static const String _websocketUrlOverride = String.fromEnvironment(
    'ISL_WS_URL',
    defaultValue: '',
  );

  // WebSocket protocol (ws = insecure, wss = secure)
  static const String _websocketScheme = String.fromEnvironment(
    'ISL_WS_SCHEME',
    defaultValue: 'wss',
  );

  // WebSocket host (default = Railway server)
  static const String _websocketHost = String.fromEnvironment(
    'ISL_WS_HOST',
    defaultValue: defaultWebsocketHost,
  );

  // WebSocket endpoint path
  static const String _websocketPath = String.fromEnvironment(
    'ISL_WS_PATH',
    defaultValue: '/ws',
  );

  // Optional mobile-specific WebSocket URL (for real devices on same WiFi)
  static const String _websocketMobileUrlOverride = String.fromEnvironment(
    'ISL_WS_MOBILE_URL',
    defaultValue: '',
  );

  // Final WebSocket URL used by app
  static String get websocketUrl {
    final rawUrl = _websocketUrlOverride.isNotEmpty
        ? _websocketUrlOverride
        : '$_websocketScheme://$_websocketHost$_websocketPath';

    // Resolve special cases (like Android emulator)
    return resolveWebsocketUrl(rawUrl);
  }

  // List of possible WebSocket URLs (used for fallback attempts)
  static List<String> get websocketCandidates {
    final rawUrl = _websocketUrlOverride.isNotEmpty
        ? _websocketUrlOverride
        : '$_websocketScheme://$_websocketHost$_websocketPath';

    return resolveWebsocketCandidates(rawUrl);
  }

  // Health API endpoint (used to check backend status)
  static String get healthUrl {
    try {
      final ws = Uri.parse(websocketUrl);

      // Convert WebSocket protocol to HTTP
      final httpScheme = ws.scheme == 'wss' ? 'https' : 'http';

      // Replace path with /health endpoint
      return ws.replace(scheme: httpScheme, path: '/health').toString();
    } catch (_) {
      // Fallback URL
      return 'https://$defaultWebsocketHost/health';
    }
  }

  // Base API URL (used for REST endpoints)
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    try {
      final ws = Uri.parse(websocketUrl);

      // Convert WebSocket scheme to HTTP
      final scheme = ws.scheme == 'wss' ? 'https' : 'http';

      return ws.replace(scheme: scheme, path: '', query: '').toString();
    } catch (_) {
      return 'https://$defaultWebsocketHost';
    }
  }

  // List of possible API base URLs (fallback mechanism)
  static List<String> get apiBaseCandidates {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return [_apiBaseUrlOverride];
    }

    final candidates = <String>[]; // Stores possible URLs
    final seen = <String>{}; // Avoid duplicates

    // Convert each WebSocket candidate into API base URL
    for (final wsUrl in websocketCandidates) {
      try {
        final ws = Uri.parse(wsUrl);
        final scheme = ws.scheme == 'wss' ? 'https' : 'http';

        final apiBase = ws
            .replace(scheme: scheme, path: '', query: '')
            .toString();

        if (seen.add(apiBase)) {
          candidates.add(apiBase);
        }
      } catch (_) {}
    }

    // Add mobile override if available
    if (_apiMobileBaseUrlOverride.isNotEmpty &&
        seen.add(_apiMobileBaseUrlOverride)) {
      candidates.add(_apiMobileBaseUrlOverride);
    }

    // Fallback default
    if (candidates.isEmpty) {
      candidates.add('https://$defaultWebsocketHost');
    }

    return candidates;
  }

  // Resolve WebSocket URL based on platform (important for emulator issues)
  static String resolveWebsocketUrl(
    String rawUrl, {
    bool? isWeb,
    TargetPlatform? platform,
  }) {
    // If running on web, return original URL
    if (isWeb ?? kIsWeb) return rawUrl;

    Uri parsed;
    try {
      parsed = Uri.parse(rawUrl);
    } catch (_) {
      return rawUrl;
    }

    final host = parsed.host.toLowerCase();
    final isLoopback = host == '127.0.0.1' || host == 'localhost';

    // Android emulator cannot access localhost directly
    final resolvedPlatform = platform ?? defaultTargetPlatform;

    if (isLoopback && resolvedPlatform == TargetPlatform.android) {
      // Replace localhost with emulator IP
      return parsed.replace(host: '10.0.2.2').toString();
    }

    return rawUrl;
  }

  // Generate multiple possible WebSocket URLs (fallback strategy)
  static List<String> resolveWebsocketCandidates(
    String rawUrl, {
    bool? isWeb,
    TargetPlatform? platform,
  }) {
    if (isWeb ?? kIsWeb) {
      return [rawUrl];
    }

    Uri parsed;
    try {
      parsed = Uri.parse(rawUrl);
    } catch (_) {
      return [rawUrl];
    }

    final candidates = <String>[]; // List of possible URLs
    final resolvedPlatform = platform ?? defaultTargetPlatform;

    // Helper function to avoid duplicates
    void addIfValid(String url) {
      if (url.isEmpty) return;
      if (!candidates.contains(url)) candidates.add(url);
    }

    // 1. Original URL (primary)
    addIfValid(rawUrl);

    // 2. Mobile LAN override
    addIfValid(_websocketMobileUrlOverride);

    final host = parsed.host.toLowerCase();
    final isLoopback = host == '127.0.0.1' || host == 'localhost';

    // 3. Android emulator alternatives
    if (isLoopback && resolvedPlatform == TargetPlatform.android) {
      addIfValid(parsed.replace(host: '10.0.2.2').toString());
      addIfValid(parsed.replace(host: '10.0.3.2').toString());
    }

    return candidates;
  }
}
