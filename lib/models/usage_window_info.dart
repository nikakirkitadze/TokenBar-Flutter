class UsageWindowInfo {
  final String label;
  final double percentUsed;
  final DateTime? resetsAt;

  const UsageWindowInfo({
    required this.label,
    required this.percentUsed,
    this.resetsAt,
  });
}
