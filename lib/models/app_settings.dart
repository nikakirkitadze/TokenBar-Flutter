import 'enums.dart';

class AppSettings {
  SourceType sourceType;
  String endpointUrl;
  int refreshIntervalMinutes;
  int lowThresholdPercent;
  bool notificationsEnabled;
  ThemeModeOption themeMode;

  AppSettings({
    this.sourceType = SourceType.mock,
    this.endpointUrl = '',
    this.refreshIntervalMinutes = 5,
    this.lowThresholdPercent = 20,
    this.notificationsEnabled = true,
    this.themeMode = ThemeModeOption.dark,
  });

  AppSettings copyWith({
    SourceType? sourceType,
    String? endpointUrl,
    int? refreshIntervalMinutes,
    int? lowThresholdPercent,
    bool? notificationsEnabled,
    ThemeModeOption? themeMode,
  }) {
    return AppSettings(
      sourceType: sourceType ?? this.sourceType,
      endpointUrl: endpointUrl ?? this.endpointUrl,
      refreshIntervalMinutes:
          refreshIntervalMinutes ?? this.refreshIntervalMinutes,
      lowThresholdPercent: lowThresholdPercent ?? this.lowThresholdPercent,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
