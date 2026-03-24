class FlexibleJsonParser {
  static dynamic resolve(String keyPath, Map<String, dynamic> dict) {
    final keys = keyPath.split('.');
    dynamic current = dict;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  static int? extractInt(
      Map<String, dynamic> dict, List<String> candidates) {
    for (final key in candidates) {
      final value = resolve(key, dict);
      if (value == null) continue;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        final parsed = int.tryParse(value) ?? double.tryParse(value)?.round();
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? extractDouble(
      Map<String, dynamic> dict, List<String> candidates) {
    for (final key in candidates) {
      final value = resolve(key, dict);
      if (value == null) continue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? extractString(
      Map<String, dynamic> dict, List<String> candidates) {
    for (final key in candidates) {
      final value = resolve(key, dict);
      if (value == null) continue;
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static DateTime? parseDate(String raw) {
    // Try ISO 8601
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // Try epoch (seconds or milliseconds)
    final epoch = double.tryParse(raw);
    if (epoch != null) {
      if (epoch > 1e12) {
        return DateTime.fromMillisecondsSinceEpoch(epoch.round());
      }
      return DateTime.fromMillisecondsSinceEpoch((epoch * 1000).round());
    }
    return null;
  }

  static DateTime? extractDate(
      Map<String, dynamic> dict, List<String> candidates) {
    for (final key in candidates) {
      final value = resolve(key, dict);
      if (value == null) continue;
      if (value is String) {
        final date = parseDate(value);
        if (date != null) return date;
      }
      if (value is num) {
        final epoch = value.toDouble();
        if (epoch > 1e12) {
          return DateTime.fromMillisecondsSinceEpoch(epoch.round());
        }
        return DateTime.fromMillisecondsSinceEpoch((epoch * 1000).round());
      }
    }
    return null;
  }
}
