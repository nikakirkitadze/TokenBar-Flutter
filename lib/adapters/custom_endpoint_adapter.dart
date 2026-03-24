import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/enums.dart';
import '../models/usage_snapshot.dart';
import '../utils/flexible_json_parser.dart';
import 'source_adapter.dart';

class CustomEndpointAdapter implements SourceAdapter {
  @override
  final String sourceId;
  @override
  final String sourceName;
  @override
  SourceType get sourceType => SourceType.customEndpoint;

  final String endpointUrl;
  final Map<String, String> customHeaders;
  final Duration timeout;

  CustomEndpointAdapter({
    this.sourceId = 'custom-endpoint',
    this.sourceName = 'Custom Endpoint',
    required this.endpointUrl,
    this.customHeaders = const {},
    this.timeout = const Duration(seconds: 15),
  });

  @override
  Future<UsageSnapshot> fetchUsage() async {
    if (endpointUrl.isEmpty) {
      throw AdapterError.notConfigured('No endpoint URL configured');
    }

    final uri = Uri.parse(endpointUrl);
    final headers = {
      'Accept': 'application/json',
      ...customHeaders,
    };

    final http.Response response;
    try {
      response = await http.get(uri, headers: headers).timeout(timeout);
    } catch (e) {
      throw AdapterError.networkError(e.toString());
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdapterError.serverError(
          response.statusCode, response.reasonPhrase ?? 'Unknown error');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw AdapterError.parsingError('Invalid JSON response');
    }

    final remainingCandidates = [
      'remaining', 'tokens_remaining', 'messages_remaining',
      'message_limit.remaining', 'rate_limit.remaining',
    ];
    final totalCandidates = [
      'limit', 'total', 'tokens_limit', 'messages_limit',
      'message_limit.limit', 'rate_limit.limit', 'daily_limit',
    ];
    final resetCandidates = [
      'resets_at', 'reset_at', 'resetsAt', 'next_reset',
      'rate_limit.resets_at',
    ];
    final planCandidates = ['type', 'tier', 'plan', 'plan_name'];
    final windowCandidates = ['window', 'window_label', 'period'];

    final remaining =
        FlexibleJsonParser.extractInt(json, remainingCandidates);
    final total = FlexibleJsonParser.extractInt(json, totalCandidates);

    if (remaining == null || total == null) {
      throw AdapterError.parsingError(
          'Could not find remaining/total in response');
    }

    final resetAt = FlexibleJsonParser.extractDate(json, resetCandidates) ??
        DateTime.now().add(const Duration(hours: 5));
    final plan =
        FlexibleJsonParser.extractString(json, planCandidates) ?? 'Custom';
    final window =
        FlexibleJsonParser.extractString(json, windowCandidates) ?? 'Default';

    return UsageSnapshot.fromRaw(
      remaining: remaining,
      total: total,
      resetAt: resetAt,
      planName: plan,
      windowLabel: window,
      sourceType: sourceId,
    );
  }

  @override
  Future<bool> testConnection() async {
    if (endpointUrl.isEmpty) return false;
    try {
      final uri = Uri.parse(endpointUrl);
      final response = await http
          .get(uri, headers: {'Accept': 'application/json', ...customHeaders})
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        jsonDecode(response.body);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
