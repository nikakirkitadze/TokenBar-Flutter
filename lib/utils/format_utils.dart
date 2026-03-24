class FormatUtils {
  static String formatTokenCount(int value) {
    if (value < 1000) return '$value';
    if (value < 1000000) {
      final k = value / 1000.0;
      return k == k.roundToDouble() ? '${k.round()}k' : '${k.toStringAsFixed(1)}k';
    }
    if (value < 1000000000) {
      final m = value / 1000000.0;
      return m == m.roundToDouble() ? '${m.round()}M' : '${m.toStringAsFixed(1)}M';
    }
    final b = value / 1000000000.0;
    return b == b.roundToDouble() ? '${b.round()}B' : '${b.toStringAsFixed(1)}B';
  }

  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return 'reset';
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return 'reset';

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final seconds = diff.inSeconds;

    if (seconds < 60) return 'just now';
    if (seconds < 3600) return '${diff.inMinutes}m ago';
    if (seconds < 86400) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
