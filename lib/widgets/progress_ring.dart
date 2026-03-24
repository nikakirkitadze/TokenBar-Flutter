import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final double lineWidth;
  final double size;
  final UsageStatus status;

  const ProgressRing({
    super.key,
    required this.progress,
    this.lineWidth = 8,
    this.size = 120,
    this.status = UsageStatus.healthy,
  });

  Color _foregroundColor(Brightness brightness) {
    switch (status) {
      case UsageStatus.healthy:
        return AppColors.accent;
      case UsageStatus.medium:
        return AppColors.warning;
      case UsageStatus.low:
        return AppColors.danger;
      case UsageStatus.critical:
        return AppColors.dangerDark;
      default:
        return brightness == Brightness.dark
            ? AppColors.darkTextTertiary
            : AppColors.lightTextTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final trackColor = brightness == Brightness.dark
        ? AppColors.darkDivider
        : AppColors.lightDivider;
    final fg = _foregroundColor(brightness);
    final clamped = progress.clamp(0.0, 1.0);
    final pct = (clamped * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: DesignTokens.animationSlow,
        curve: Curves.easeOut,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: value,
              lineWidth: lineWidth,
              trackColor: trackColor,
              foregroundColor: fg,
            ),
            child: Center(
              child: Text(
                '$pct%',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double lineWidth;
  final Color trackColor;
  final Color foregroundColor;

  _RingPainter({
    required this.progress,
    required this.lineWidth,
    required this.trackColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - lineWidth) / 2;
    const startAngle = -pi / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Foreground arc
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = foregroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.foregroundColor != foregroundColor ||
      old.trackColor != trackColor;
}
