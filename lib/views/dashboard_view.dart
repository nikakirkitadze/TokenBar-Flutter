import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../utils/format_utils.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/progress_ring.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/stat_row.dart';
import '../widgets/window_row.dart';
import 'settings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Timer cleanup handled in ViewModel.dispose()
    super.dispose();
  }

  void _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsView()),
    );
    // Rebuild adapter on return from settings
    if (mounted) {
      final vm = context.read<DashboardViewModel>();
      vm.rebuildAdapter();
      vm.startAutoRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Scaffold(
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(vm, textPrimary, textSecondary),
                const SizedBox(height: DesignTokens.space5),

                // Content
                if (vm.isLoading && vm.currentUsage == null)
                  const SkeletonLoader()
                else if (vm.errorMessage != null && vm.currentUsage == null)
                  ErrorStateView(
                    message: vm.errorMessage!,
                    onRetry: () => vm.fetchUsage(),
                  )
                else if (vm.currentUsage != null)
                  ..._buildUsageContent(
                      vm, textPrimary, textSecondary, textTertiary, surface, divider)
                else
                  EmptyStateView(
                    icon: Icons.bar_chart_rounded,
                    title: 'No Usage Data',
                    subtitle:
                        'Configure a data source in Settings to get started.',
                    actionTitle: 'Open Settings',
                    action: _openSettings,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      DashboardViewModel vm, Color textPrimary, Color textSecondary) {
    return Row(
      children: [
        Text(
          'TokenBar',
          style: TextStyle(
            fontSize: DesignTokens.headline,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const Spacer(),
        if (vm.isLoading)
          Padding(
            padding: const EdgeInsets.only(right: DesignTokens.space2),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textSecondary,
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.refresh, color: textSecondary, size: 20),
          onPressed: () => vm.fetchUsage(),
          tooltip: 'Refresh',
          splashRadius: 18,
        ),
        IconButton(
          icon: Icon(Icons.settings, color: textSecondary, size: 20),
          onPressed: _openSettings,
          tooltip: 'Settings',
          splashRadius: 18,
        ),
      ],
    );
  }

  List<Widget> _buildUsageContent(
    DashboardViewModel vm,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color surface,
    Color divider,
  ) {
    final usage = vm.currentUsage!;
    final widgets = <Widget>[];

    // Hero card with progress ring
    widgets.add(
      Container(
        padding: const EdgeInsets.all(DesignTokens.space5),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        child: Column(
          children: [
            ProgressRing(
              progress: (100 - usage.percentUsed) / 100,
              status: usage.status,
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(
              usage.windows.isNotEmpty
                  ? '${usage.percentUsed.round()}% used'
                  : '${FormatUtils.formatTokenCount(usage.remainingAmount)} remaining',
              style: TextStyle(
                fontSize: DesignTokens.title3,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: DesignTokens.space1),
            Text(
              usage.windows.isNotEmpty
                  ? '${usage.windowLabel} · Resets in ${FormatUtils.formatCountdown(usage.resetAt.difference(DateTime.now()))}'
                  : '${usage.planName} · ${usage.windowLabel}',
              style: TextStyle(
                fontSize: DesignTokens.footnote,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    widgets.add(const SizedBox(height: DesignTokens.space5));

    // Stats section
    if (usage.windows.isEmpty) {
      // Token count stats
      widgets.add(
        Container(
          padding: const EdgeInsets.all(DesignTokens.space5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          child: Column(
            children: [
              StatRow(
                  label: 'Plan',
                  value: usage.planName,
                  icon: Icons.person_outline),
              Divider(color: divider, height: 1),
              StatRow(
                  label: 'Used',
                  value: FormatUtils.formatTokenCount(usage.usedAmount),
                  icon: Icons.local_fire_department_outlined),
              Divider(color: divider, height: 1),
              StatRow(
                  label: 'Remaining',
                  value: FormatUtils.formatTokenCount(usage.remainingAmount),
                  icon: Icons.battery_4_bar),
              Divider(color: divider, height: 1),
              StatRow(
                  label: 'Total',
                  value: FormatUtils.formatTokenCount(usage.totalAmount),
                  icon: Icons.bar_chart),
            ],
          ),
        ),
      );
    } else {
      // Per-window utilization cards
      widgets.add(
        Container(
          padding: const EdgeInsets.all(DesignTokens.space5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage Limits',
                style: TextStyle(
                  fontSize: DesignTokens.subheadline,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: DesignTokens.space3),
              ...usage.windows.map((w) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: DesignTokens.space2),
                    child: WindowRow(window: w),
                  )),
            ],
          ),
        ),
      );
    }

    // Reset countdown (for non-utilization sources)
    if (usage.windows.isEmpty) {
      final countdown =
          FormatUtils.formatCountdown(usage.resetAt.difference(DateTime.now()));
      widgets.add(const SizedBox(height: DesignTokens.space5));
      widgets.add(
        Container(
          padding: const EdgeInsets.all(DesignTokens.space5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: textSecondary),
              const SizedBox(width: DesignTokens.space3),
              Text(
                'Resets in',
                style: TextStyle(
                    fontSize: DesignTokens.body, color: textSecondary),
              ),
              const Spacer(),
              Text(
                countdown,
                style: TextStyle(
                  fontSize: DesignTokens.body,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Last refreshed footer
    if (vm.lastRefreshed != null) {
      widgets.add(const SizedBox(height: DesignTokens.space4));
      widgets.add(
        Center(
          child: Text(
            'Updated ${FormatUtils.formatRelativeTime(vm.lastRefreshed!)}',
            style: TextStyle(
              fontSize: DesignTokens.caption1,
              color: textTertiary,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
