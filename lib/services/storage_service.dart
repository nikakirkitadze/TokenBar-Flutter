import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';

class StorageService {
  static StorageService? _instance;
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    _instance ??= StorageService._(await SharedPreferences.getInstance());
    return _instance!;
  }

  static StorageService get shared => _instance!;

  // Source Type
  SourceType get sourceType {
    final index = _prefs.getInt('source_type') ?? 0;
    return SourceType.values[index.clamp(0, SourceType.values.length - 1)];
  }

  set sourceType(SourceType value) {
    _prefs.setInt('source_type', value.index);
  }

  // Endpoint URL
  String get endpointUrl => _prefs.getString('endpoint_url') ?? '';
  set endpointUrl(String value) => _prefs.setString('endpoint_url', value);

  // Refresh Interval (seconds)
  int get refreshInterval => _prefs.getInt('refresh_interval') ?? 300;
  set refreshInterval(int value) => _prefs.setInt('refresh_interval', value);

  // Refresh Interval in minutes (convenience)
  int get refreshIntervalMinutes => refreshInterval ~/ 60;
  set refreshIntervalMinutes(int value) =>
      refreshInterval = value * 60;

  // Low Threshold
  int get lowThreshold => _prefs.getInt('low_threshold') ?? 20;
  set lowThreshold(int value) => _prefs.setInt('low_threshold', value);

  // Notifications
  bool get notificationsEnabled =>
      _prefs.getBool('notifications_enabled') ?? true;
  set notificationsEnabled(bool value) =>
      _prefs.setBool('notifications_enabled', value);

  // Theme Mode
  ThemeModeOption get themeMode {
    final index = _prefs.getInt('theme_mode') ?? 1; // default dark
    return ThemeModeOption
        .values[index.clamp(0, ThemeModeOption.values.length - 1)];
  }

  set themeMode(ThemeModeOption value) {
    _prefs.setInt('theme_mode', value.index);
  }

  // Reset
  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
