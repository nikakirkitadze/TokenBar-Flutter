import 'dart:async';
import 'package:flutter/foundation.dart';
import '../adapters/claude_web_scraper_adapter.dart';
import '../adapters/custom_endpoint_adapter.dart';
import '../adapters/mock_source_adapter.dart';
import '../adapters/source_adapter.dart';
import '../models/enums.dart';
import '../models/usage_snapshot.dart';
import '../services/secure_storage_service.dart';
import '../services/storage_service.dart';

class DashboardViewModel extends ChangeNotifier {
  UsageSnapshot? currentUsage;
  bool isLoading = false;
  String? errorMessage;
  DateTime? lastRefreshed;

  SourceAdapter? _adapter;
  Timer? _refreshTimer;

  DashboardViewModel() {
    rebuildAdapter();
  }

  void rebuildAdapter() {
    final storage = StorageService.shared;
    switch (storage.sourceType) {
      case SourceType.mock:
        _adapter = MockSourceAdapter();
        break;
      case SourceType.claudeApi:
        // Session key will be loaded asynchronously
        _adapter = null;
        _loadClaudeAdapter();
        break;
      case SourceType.customEndpoint:
        final url = storage.endpointUrl;
        if (url.isNotEmpty) {
          _adapter = CustomEndpointAdapter(endpointUrl: url);
        } else {
          _adapter = null;
        }
        break;
    }
    notifyListeners();
  }

  Future<void> _loadClaudeAdapter() async {
    final token = await SecureStorageService.getSessionToken();
    if (token != null && token.isNotEmpty) {
      _adapter = ClaudeWebScraperAdapter(sessionKey: token);
    } else {
      _adapter = null;
    }
    notifyListeners();
  }

  Future<void> fetchUsage() async {
    if (_adapter == null) {
      errorMessage = 'No data source configured.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUsage = await _adapter!.fetchUsage();
      lastRefreshed = DateTime.now();
    } on AdapterError catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void startAutoRefresh() {
    stopAutoRefresh();
    final intervalSeconds = StorageService.shared.refreshInterval;

    // Initial fetch
    fetchUsage();

    _refreshTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => fetchUsage(),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
