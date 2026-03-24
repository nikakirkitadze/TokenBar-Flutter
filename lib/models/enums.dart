enum SourceType {
  mock,
  customEndpoint,
  claudeApi;

  String get displayName {
    switch (this) {
      case SourceType.mock:
        return 'Demo';
      case SourceType.customEndpoint:
        return 'Custom Endpoint';
      case SourceType.claudeApi:
        return 'Claude.ai (Web)';
    }
  }
}

enum UsageStatus {
  healthy,
  medium,
  low,
  critical,
  error,
  unknown;

  String get label {
    switch (this) {
      case UsageStatus.healthy:
        return 'Healthy';
      case UsageStatus.medium:
        return 'Medium';
      case UsageStatus.low:
        return 'Low';
      case UsageStatus.critical:
        return 'Critical';
      case UsageStatus.error:
        return 'Error';
      case UsageStatus.unknown:
        return 'Unknown';
    }
  }
}

enum ThemeModeOption {
  system,
  dark,
  light;

  String get displayName {
    switch (this) {
      case ThemeModeOption.system:
        return 'System';
      case ThemeModeOption.dark:
        return 'Dark';
      case ThemeModeOption.light:
        return 'Light';
    }
  }
}

enum ConnectionStatus { idle, checking, connected, error }
