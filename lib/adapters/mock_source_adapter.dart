import 'dart:math';
import '../models/enums.dart';
import '../models/usage_snapshot.dart';
import '../models/usage_window_info.dart';
import 'source_adapter.dart';

class MockSourceAdapter implements SourceAdapter {
  @override
  final String sourceId;
  @override
  final String sourceName;
  @override
  SourceType get sourceType => SourceType.mock;

  final int totalTokens;
  final int remainingMin;
  final int remainingMax;
  final double resetHoursFromNow;
  final String planName;

  final _random = Random();

  MockSourceAdapter({
    this.sourceId = 'mock',
    this.sourceName = 'Demo Source',
    this.totalTokens = 45000,
    this.remainingMin = 30000,
    this.remainingMax = 35000,
    this.resetHoursFromNow = 5,
    this.planName = 'Pro (Demo)',
  });

  @override
  Future<UsageSnapshot> fetchUsage() async {
    // Simulate network delay
    await Future.delayed(
        Duration(milliseconds: 50 + _random.nextInt(150)));

    final resetAt =
        DateTime.now().add(Duration(hours: resetHoursFromNow.round()));

    // Generate utilization-style windows for a richer demo
    final windows = [
      UsageWindowInfo(
        label: 'Current session',
        percentUsed: ((_random.nextInt(30) + 5).toDouble()),
        resetsAt: resetAt,
      ),
      UsageWindowInfo(
        label: 'All models',
        percentUsed: ((_random.nextInt(40) + 10).toDouble()),
        resetsAt: DateTime.now().add(const Duration(days: 3)),
      ),
      UsageWindowInfo(
        label: 'Sonnet only',
        percentUsed: ((_random.nextInt(20) + 5).toDouble()),
        resetsAt: DateTime.now().add(const Duration(days: 3)),
      ),
    ];

    final primaryWindow = windows.first;

    return UsageSnapshot.fromUtilization(
      percentUsed: primaryWindow.percentUsed,
      resetAt: resetAt,
      planName: planName,
      windowLabel: '5h window',
      sourceType: sourceId,
      windows: windows,
    );
  }

  @override
  Future<bool> testConnection() async {
    await Future.delayed(
        Duration(milliseconds: 30 + _random.nextInt(70)));
    return true;
  }
}
