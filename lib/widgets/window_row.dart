import 'package:flutter/material.dart';
import '../models/usage_window_info.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../utils/format_utils.dart';

class WindowRow extends StatelessWidget {
  final UsageWindowInfo window;

  const WindowRow({super.key, required this.window});

  Color _barColor() {
    if (window.percentUsed < 50) return AppColors.accent;
    if (window.percentUsed < 75) return AppColors.warning;
    return AppColors.danger;
  }

  String _resetLabel() {
    final resetsAt = window.resetsAt;
    if (resetsAt == null) return '';
    final remaining = resetsAt.difference(DateTime.now());
    if (remaining.isNegative || remaining.inSeconds <= 0) return 'Reset due';
    if (remaining.inHours < 24) {
      return 'Resets in ${FormatUtils.formatCountdown(remaining)}';
    }
    // Format as weekday + time for longer durations
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = weekdays[resetsAt.weekday - 1];
    final hour = resetsAt.hour > 12 ? resetsAt.hour - 12 : resetsAt.hour;
    final period = resetsAt.hour >= 12 ? 'PM' : 'AM';
    final minute = resetsAt.minute.toString().padLeft(2, '0');
    return 'Resets $day $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final surfaceElevated = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.lightSurfaceElevated;

    final pctClamped = window.percentUsed.clamp(0.0, 100.0);
    final barColor = _barColor();
    final resetText = _resetLabel();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space3),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                window.label,
                style: TextStyle(
                  fontSize: DesignTokens.footnote,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
              Text(
                '${pctClamped.round()}% used',
                style: TextStyle(
                  fontSize: DesignTokens.footnote,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.space2),
          // Progress bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * (pctClamped / 100),
                    height: 6,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
          if (resetText.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.space1),
            Text(
              resetText,
              style: TextStyle(
                fontSize: DesignTokens.caption2,
                color: textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
