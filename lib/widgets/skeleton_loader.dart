import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final shimmer = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(DesignTokens.space5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          child: Column(
            children: [
              // Ring placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shimmer.withValues(alpha: _animation.value),
                ),
              ),
              const SizedBox(height: DesignTokens.space5),
              // Title placeholder
              _shimmerBar(shimmer, width: 120, height: 14),
              const SizedBox(height: DesignTokens.space3),
              // Subtitle placeholder
              _shimmerBar(shimmer, width: 180, height: 10),
              const SizedBox(height: DesignTokens.space5),
              // Stat rows
              _shimmerBar(shimmer, width: double.infinity, height: 12),
              const SizedBox(height: DesignTokens.space3),
              _shimmerBar(shimmer, width: double.infinity, height: 12),
              const SizedBox(height: DesignTokens.space3),
              _shimmerBar(shimmer, width: 200, height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBar(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: _animation.value),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
    );
  }
}
