import '../models/usage_snapshot.dart';
import '../models/enums.dart';

abstract class SourceAdapter {
  String get sourceId;
  String get sourceName;
  SourceType get sourceType;

  Future<UsageSnapshot> fetchUsage();
  Future<bool> testConnection();
}

class AdapterError implements Exception {
  final String type;
  final String message;
  final int? statusCode;

  AdapterError(this.type, this.message, {this.statusCode});

  AdapterError.authenticationRequired(String detail)
      : type = 'authenticationRequired',
        message = 'Authentication required: $detail',
        statusCode = null;

  AdapterError.authenticationFailed(String detail)
      : type = 'authenticationFailed',
        message = 'Authentication failed: $detail',
        statusCode = null;

  AdapterError.serverError(int code, String detail)
      : type = 'serverError',
        message = 'Server error ($code): $detail',
        statusCode = code;

  AdapterError.networkError(String detail)
      : type = 'networkError',
        message = 'Network error: $detail',
        statusCode = null;

  AdapterError.parsingError(String detail)
      : type = 'parsingError',
        message = 'Parsing error: $detail',
        statusCode = null;

  AdapterError.notConfigured(String detail)
      : type = 'notConfigured',
        message = 'Not configured: $detail',
        statusCode = null;

  @override
  String toString() => message;
}
