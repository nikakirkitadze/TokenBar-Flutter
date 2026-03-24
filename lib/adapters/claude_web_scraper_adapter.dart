import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/enums.dart';
import '../models/usage_snapshot.dart';
import '../models/usage_window_info.dart';
import '../utils/flexible_json_parser.dart';
import 'source_adapter.dart';

class ClaudeWebScraperAdapter implements SourceAdapter {
  static const _baseUrl = 'https://claude.ai';
  static const _timeout = Duration(seconds: 15);
  static const _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0.0.0 Safari/537.36';

  @override
  final String sourceId;
  @override
  final String sourceName;
  @override
  SourceType get sourceType => SourceType.claudeApi;

  final String sessionKey;
  _CachedOrg? _cachedOrg;

  ClaudeWebScraperAdapter({
    this.sourceId = 'claude-web',
    this.sourceName = 'Claude.ai (Web)',
    required this.sessionKey,
  });

  Map<String, String> get _headers => {
        'User-Agent': _userAgent,
        'Cookie': 'sessionKey=$sessionKey',
        'Accept': 'application/json',
      };

  // -- Organisation Discovery --

  Future<_CachedOrg> _fetchOrganization() async {
    if (_cachedOrg != null) return _cachedOrg!;

    if (sessionKey.isEmpty) {
      throw AdapterError.authenticationRequired(
          'Session key is empty. Sign in to claude.ai and copy the sessionKey cookie.');
    }

    final url = Uri.parse('$_baseUrl/api/organizations');
    final response = await _perform(url);
    _validateStatus(response, allowNotFound: false);

    final List<dynamic> orgs;
    try {
      orgs = jsonDecode(response.body) as List<dynamic>;
    } catch (_) {
      throw AdapterError.parsingError(
          'Could not parse /api/organizations response.');
    }

    if (orgs.isEmpty) {
      throw AdapterError.parsingError(
          'No organizations found in /api/organizations.');
    }

    final firstOrg = orgs[0] as Map<String, dynamic>;
    final orgId = firstOrg['uuid'] as String? ?? firstOrg['id'] as String?;
    if (orgId == null) {
      throw AdapterError.parsingError(
          'Could not extract organization UUID from /api/organizations.');
    }

    String? planName;
    const planCandidates = [
      'active_plan',
      'plan',
      'subscription_plan',
      'billing_plan'
    ];
    for (final key in planCandidates) {
      final value = firstOrg[key];
      if (value is String && value.isNotEmpty) {
        planName = value;
        break;
      }
      if (value is Map<String, dynamic>) {
        final name = value['name'] as String? ?? value['type'] as String?;
        if (name != null && name.isNotEmpty) {
          planName = name;
          break;
        }
      }
    }

    if (planName == null && firstOrg['capabilities'] is Map<String, dynamic>) {
      final caps = firstOrg['capabilities'] as Map<String, dynamic>;
      planName = caps['plan'] as String? ??
          caps['plan_name'] as String? ??
          caps['tier'] as String?;
    }

    _cachedOrg = _CachedOrg(id: orgId, plan: planName);
    return _cachedOrg!;
  }

  // -- Tiered Usage Fetch --

  static const _usageSuffixes = [
    'usage',
    'rate_limit',
    'rate_limit_status',
    'settings'
  ];
  static const _remainingKeys = [
    'remaining',
    'tokens_remaining',
    'messages_remaining',
    'message_limit.remaining',
    'rate_limit.remaining',
  ];
  static const _totalKeys = [
    'limit',
    'total',
    'tokens_limit',
    'messages_limit',
    'message_limit.limit',
    'rate_limit.limit',
    'daily_limit',
  ];
  static const _resetKeys = [
    'resets_at',
    'reset_at',
    'resetsAt',
    'next_reset',
    'rate_limit.resets_at',
  ];
  static const _planKeys = ['type', 'tier', 'plan', 'plan_name'];
  static const _windowKeys = ['window', 'window_label', 'period'];

  Future<Map<String, dynamic>> _fetchUsagePayload(String orgId) async {
    Object? lastError;

    for (final suffix in _usageSuffixes) {
      final url =
          Uri.parse('$_baseUrl/api/organizations/$orgId/$suffix');

      try {
        final response = await _perform(url);
        if (response.statusCode == 404) continue;
        _validateStatus(response, allowNotFound: true);

        final Map<String, dynamic> json;
        try {
          json = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }

        // Accept remaining/total format
        if (FlexibleJsonParser.extractInt(json, _remainingKeys) != null ||
            FlexibleJsonParser.extractInt(json, _totalKeys) != null) {
          return json;
        }

        // Accept utilization-based format
        if (_extractUtilizationWindows(json) != null) {
          return json;
        }

        continue;
      } on AdapterError catch (e) {
        if (e.type == 'authenticationFailed' ||
            e.type == 'authenticationRequired' ||
            e.type == 'serverError') {
          rethrow;
        }
        lastError = e;
        continue;
      } catch (e) {
        lastError = e;
        continue;
      }
    }

    if (lastError is AdapterError) {
      throw lastError;
    }
    throw AdapterError.parsingError(
        'None of the known endpoints returned parsable usage data.');
  }

  // -- Utilization Format Parsing --

  static List<_UsageWindow>? _extractUtilizationWindows(
      Map<String, dynamic> json) {
    final windows = <_UsageWindow>[];

    for (final entry in json.entries) {
      if (entry.value is! Map<String, dynamic>) continue;
      final windowDict = entry.value as Map<String, dynamic>;

      double? utilization;
      final raw = windowDict['utilization'];
      if (raw is double) {
        utilization = raw;
      } else if (raw is int) {
        utilization = raw.toDouble();
      } else if (raw is String) {
        utilization = double.tryParse(raw);
      }

      if (utilization == null) continue;

      DateTime? resetsAt;
      final resetRaw =
          windowDict['resets_at'] as String? ?? windowDict['reset_at'] as String?;
      if (resetRaw != null) {
        resetsAt = FlexibleJsonParser.parseDate(resetRaw);
      }

      windows.add(_UsageWindow(
        key: entry.key,
        utilization: utilization,
        resetsAt: resetsAt,
      ));
    }

    return windows.isEmpty ? null : windows;
  }

  static _UsageWindow? _primaryWindow(List<_UsageWindow> windows) {
    final fiveHour = windows.where((w) => w.key == 'five_hour').firstOrNull;
    if (fiveHour != null) return fiveHour;
    if (windows.isEmpty) return null;
    return windows.reduce((a, b) => a.utilization >= b.utilization ? a : b);
  }

  static const _windowOrder = [
    'five_hour',
    'seven_day',
    'seven_day_sonnet',
    'seven_day_opus',
    'seven_day_cowork',
    'seven_day_oauth_apps',
  ];

  static String _formatWindowLabel(String key) {
    switch (key) {
      case 'five_hour':
        return 'Current session';
      case 'seven_day':
        return 'All models';
      case 'seven_day_sonnet':
        return 'Sonnet only';
      case 'seven_day_opus':
        return 'Opus only';
      case 'seven_day_cowork':
        return 'Cowork';
      case 'seven_day_oauth_apps':
        return 'OAuth apps';
      default:
        return key
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) =>
                w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  static List<_UsageWindow> _sortedWindows(List<_UsageWindow> windows) {
    final sorted = List<_UsageWindow>.from(windows);
    sorted.sort((a, b) {
      final ia = _windowOrder.indexOf(a.key);
      final ib = _windowOrder.indexOf(b.key);
      final orderA = ia >= 0 ? ia : _windowOrder.length;
      final orderB = ib >= 0 ? ib : _windowOrder.length;
      return orderA.compareTo(orderB);
    });
    return sorted;
  }

  // -- Networking --

  Future<http.Response> _perform(Uri url) async {
    try {
      return await http.get(url, headers: _headers).timeout(_timeout);
    } catch (e) {
      throw AdapterError.networkError(e.toString());
    }
  }

  void _validateStatus(http.Response response, {required bool allowNotFound}) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) return;
    if (code == 401 || code == 403) {
      throw AdapterError.authenticationFailed(
          'HTTP $code. The session key may have expired.');
    }
    if (code == 404 && allowNotFound) return;
    if (code == 429) {
      throw AdapterError.serverError(code, 'Rate limited by claude.ai.');
    }
    if (code >= 500 && code < 600) {
      throw AdapterError.serverError(code, 'claude.ai returned HTTP $code.');
    }
    throw AdapterError.serverError(code, 'Unexpected HTTP $code.');
  }

  String _deriveWindowLabel(DateTime resetAt) {
    final diff = resetAt.difference(DateTime.now()).inSeconds;
    if (diff <= 0) return 'Reset due';
    final hours = diff ~/ 3600;
    final minutes = (diff % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m window';
    return '${minutes}m window';
  }

  void invalidateCache() {
    _cachedOrg = null;
  }

  // -- SourceAdapter --

  @override
  Future<UsageSnapshot> fetchUsage() async {
    final org = await _fetchOrganization();
    final json = await _fetchUsagePayload(org.id);

    // Try utilization-based format first
    final rawWindows = _extractUtilizationWindows(json);
    if (rawWindows != null) {
      final primary = _primaryWindow(rawWindows);
      if (primary != null) {
        final pctUsed = primary.utilization.clamp(0.0, 100.0);
        final resetsAt =
            primary.resetsAt ?? DateTime.now().add(const Duration(hours: 5));
        final windowLabel = _formatWindowLabel(primary.key);

        final windowInfos = _sortedWindows(rawWindows)
            .map((w) => UsageWindowInfo(
                  label: _formatWindowLabel(w.key),
                  percentUsed: w.utilization.clamp(0.0, 100.0),
                  resetsAt: w.resetsAt,
                ))
            .toList();

        return UsageSnapshot.fromUtilization(
          percentUsed: pctUsed,
          resetAt: resetsAt,
          planName: org.plan ?? 'Claude Pro',
          windowLabel: windowLabel,
          sourceType: 'claude_web',
          windows: windowInfos,
        );
      }
    }

    // Fall back to remaining/total format
    final remaining = FlexibleJsonParser.extractInt(json, _remainingKeys);
    final total = FlexibleJsonParser.extractInt(json, _totalKeys);

    if (remaining == null || total == null) {
      throw AdapterError.parsingError(
          'Could not locate remaining and total token counts in the API response.');
    }

    final resetString = FlexibleJsonParser.extractString(json, _resetKeys);
    final planString = FlexibleJsonParser.extractString(json, _planKeys);
    final windowString = FlexibleJsonParser.extractString(json, _windowKeys);

    DateTime resetsAt = DateTime.now().add(const Duration(hours: 5));
    if (resetString != null) {
      final parsed = FlexibleJsonParser.parseDate(resetString);
      if (parsed != null) resetsAt = parsed;
    }

    return UsageSnapshot.fromRaw(
      remaining: remaining,
      total: total,
      resetAt: resetsAt,
      planName: planString ?? org.plan ?? 'Claude Pro',
      windowLabel: windowString ?? _deriveWindowLabel(resetsAt),
      sourceType: 'claude_web',
    );
  }

  @override
  Future<bool> testConnection() async {
    if (sessionKey.isEmpty) return false;
    try {
      final url = Uri.parse('$_baseUrl/api/organizations');
      final response = await _perform(url);
      _validateStatus(response, allowNotFound: false);
      final orgs = jsonDecode(response.body) as List<dynamic>;
      return orgs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

class _CachedOrg {
  final String id;
  final String? plan;
  const _CachedOrg({required this.id, this.plan});
}

class _UsageWindow {
  final String key;
  final double utilization;
  final DateTime? resetsAt;
  const _UsageWindow({
    required this.key,
    required this.utilization,
    this.resetsAt,
  });
}
