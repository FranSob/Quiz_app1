import 'package:flutter/foundation.dart';

const String apiBaseAndroidEmulator = 'http://10.0.2.2:3000';
const String apiBaseIosSimulator = 'http://localhost:3000';
const String apiBaseWeb = 'http://localhost:3000';

/// Użyj przy uruchamianiu np.:
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.45:3000
const String _apiBaseOverride = String.fromEnvironment('API_BASE_URL');

String resolveApiBaseUrl() {
  if (_apiBaseOverride.isNotEmpty) return _apiBaseOverride;
  if (kIsWeb) return apiBaseWeb;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return apiBaseAndroidEmulator;
    case TargetPlatform.iOS:
      return apiBaseIosSimulator;
    default:
      return apiBaseWeb;
  }
}