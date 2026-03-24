import 'package:flutter/foundation.dart';
import '../adapters/claude_web_scraper_adapter.dart';
import '../adapters/custom_endpoint_adapter.dart';
import '../adapters/mock_source_adapter.dart';
import '../models/enums.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  late SourceType sourceType;
  late String endpointUrl;
  late int refreshIntervalMinutes;
  late int lowThreshold;
  late bool notificationsEnabled;
  late ThemeModeOption themeMode;
  String sessionToken = '';
  ConnectionStatus connectionStatus = ConnectionStatus.idle;

  SettingsViewModel() {
    _loadSettings();
  }

  void _loadSettings() {
    final storage = StorageService.shared;
    sourceType = storage.sourceType;
    endpointUrl = storage.endpointUrl;
    refreshIntervalMinutes = storage.refreshIntervalMinutes;
    lowThreshold = storage.lowThreshold;
    notificationsEnabled = storage.notificationsEnabled;
    themeMode = storage.themeMode;
    _loadSessionToken();
  }

  Future<void> _loadSessionToken() async {
    sessionToken = await SecureStorageService.getSessionToken() ?? '';
    notifyListeners();
  }

  void setSourceType(SourceType value) {
    sourceType = value;
    StorageService.shared.sourceType = value;
    notifyListeners();
  }

  void setEndpointUrl(String value) {
    endpointUrl = value;
    StorageService.shared.endpointUrl = value;
    notifyListeners();
  }

  void setRefreshInterval(int minutes) {
    refreshIntervalMinutes = minutes;
    StorageService.shared.refreshIntervalMinutes = minutes;
    notifyListeners();
  }

  void setLowThreshold(int value) {
    lowThreshold = value;
    StorageService.shared.lowThreshold = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    StorageService.shared.notificationsEnabled = value;
    notifyListeners();
  }

  void setThemeMode(ThemeModeOption value) {
    themeMode = value;
    StorageService.shared.themeMode = value;
    notifyListeners();
  }

  Future<void> saveSessionToken(String token) async {
    sessionToken = token;
    await SecureStorageService.saveSessionToken(token);
    notifyListeners();
  }

  Future<void> clearSessionToken() async {
    sessionToken = '';
    await SecureStorageService.deleteSessionToken();
    notifyListeners();
  }

  Future<void> testConnection() async {
    connectionStatus = ConnectionStatus.checking;
    notifyListeners();

    try {
      bool result;
      switch (sourceType) {
        case SourceType.mock:
          result = await MockSourceAdapter().testConnection();
          break;
        case SourceType.claudeApi:
          if (sessionToken.isEmpty) {
            connectionStatus = ConnectionStatus.error;
            notifyListeners();
            return;
          }
          result = await ClaudeWebScraperAdapter(sessionKey: sessionToken)
              .testConnection();
          break;
        case SourceType.customEndpoint:
          if (endpointUrl.isEmpty) {
            connectionStatus = ConnectionStatus.error;
            notifyListeners();
            return;
          }
          result = await CustomEndpointAdapter(endpointUrl: endpointUrl)
              .testConnection();
          break;
      }
      connectionStatus =
          result ? ConnectionStatus.connected : ConnectionStatus.error;
    } catch (_) {
      connectionStatus = ConnectionStatus.error;
    }
    notifyListeners();
  }
}
