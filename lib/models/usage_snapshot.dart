import 'enums.dart';
import 'usage_window_info.dart';

class UsageSnapshot {
  final int remainingAmount;
  final int totalAmount;
  final int usedAmount;
  final double percentRemaining;
  final double percentUsed;
  final DateTime resetAt;
  final DateTime fetchedAt;
  final String planName;
  final String windowLabel;
  final String sourceType;
  final UsageStatus status;
  final List<UsageWindowInfo> windows;

  const UsageSnapshot({
    required this.remainingAmount,
    required this.totalAmount,
    required this.usedAmount,
    required this.percentRemaining,
    required this.percentUsed,
    required this.resetAt,
    required this.fetchedAt,
    required this.planName,
    required this.windowLabel,
    required this.sourceType,
    required this.status,
    this.windows = const [],
  });

  factory UsageSnapshot.fromRaw({
    required int remaining,
    required int total,
    required DateTime resetAt,
    required String planName,
    required String windowLabel,
    required String sourceType,
    DateTime? fetchedAt,
    List<UsageWindowInfo> windows = const [],
  }) {
    final safeTotal = total < 1 ? 1 : total;
    final safeRemaining = remaining.clamp(0, safeTotal);
    final used = safeTotal - safeRemaining;
    final pctRemaining =
        safeTotal > 0 ? (safeRemaining / safeTotal) * 100.0 : 0.0;
    final pctUsed = 100.0 - pctRemaining;

    UsageStatus status;
    if (pctRemaining > 50) {
      status = UsageStatus.healthy;
    } else if (pctRemaining >= 25) {
      status = UsageStatus.medium;
    } else if (pctRemaining >= 10) {
      status = UsageStatus.low;
    } else {
      status = UsageStatus.critical;
    }

    return UsageSnapshot(
      remainingAmount: safeRemaining,
      totalAmount: safeTotal,
      usedAmount: used,
      percentRemaining: pctRemaining,
      percentUsed: pctUsed,
      resetAt: resetAt,
      fetchedAt: fetchedAt ?? DateTime.now(),
      planName: planName,
      windowLabel: windowLabel,
      sourceType: sourceType,
      status: status,
      windows: windows,
    );
  }

  factory UsageSnapshot.fromUtilization({
    required double percentUsed,
    required DateTime resetAt,
    required String planName,
    required String windowLabel,
    required String sourceType,
    DateTime? fetchedAt,
    List<UsageWindowInfo> windows = const [],
  }) {
    final clampedUsed = percentUsed.clamp(0.0, 100.0);
    final pctRemaining = 100.0 - clampedUsed;
    final total = 100;
    final remaining = pctRemaining.round();

    UsageStatus status;
    if (pctRemaining > 50) {
      status = UsageStatus.healthy;
    } else if (pctRemaining >= 25) {
      status = UsageStatus.medium;
    } else if (pctRemaining >= 10) {
      status = UsageStatus.low;
    } else {
      status = UsageStatus.critical;
    }

    return UsageSnapshot(
      remainingAmount: remaining,
      totalAmount: total,
      usedAmount: total - remaining,
      percentRemaining: pctRemaining,
      percentUsed: clampedUsed,
      resetAt: resetAt,
      fetchedAt: fetchedAt ?? DateTime.now(),
      planName: planName,
      windowLabel: windowLabel,
      sourceType: sourceType,
      status: status,
      windows: windows,
    );
  }
}
