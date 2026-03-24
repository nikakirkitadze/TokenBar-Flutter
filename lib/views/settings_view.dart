import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../view_models/settings_view_model.dart';
import 'claude_login_view.dart';
import 'claude_manual_login_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _endpointController;
  late TextEditingController _sessionTokenController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<SettingsViewModel>();
    _endpointController = TextEditingController(text: vm.endpointUrl);
    _sessionTokenController = TextEditingController(text: vm.sessionToken);
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _sessionTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                fontSize: DesignTokens.headline,
                fontWeight: FontWeight.bold,
                color: textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Data Source
                _sectionTitle('Data Source', textPrimary),
                const SizedBox(height: DesignTokens.space3),
                _card(
                  surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<SourceType>(
                        initialValue: vm.sourceType,
                        decoration: const InputDecoration(
                          labelText: 'Source Type',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: SourceType.values
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t.displayName)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) vm.setSourceType(v);
                        },
                      ),

                      // Claude.ai sign-in
                      if (vm.sourceType == SourceType.claudeApi) ...[
                        const SizedBox(height: DesignTokens.space4),
                        if (vm.sessionToken.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.accent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Signed in to Claude',
                                  style: TextStyle(
                                    fontSize: DesignTokens.body,
                                    color: textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => vm.clearSessionToken(),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.login, size: 18),
                              label: const Text('Sign in to Claude'),
                              onPressed: () => _openClaudeLogin(vm),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],

                      // Custom endpoint URL field
                      if (vm.sourceType == SourceType.customEndpoint) ...[
                        const SizedBox(height: DesignTokens.space4),
                        TextField(
                          controller: _endpointController,
                          decoration: InputDecoration(
                            labelText: 'Endpoint URL',
                            hintText: 'https://api.example.com/usage',
                            hintStyle: TextStyle(color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                          ),
                          onChanged: (val) => vm.setEndpointUrl(val),
                        ),
                      ],

                      // Connection test button
                      const SizedBox(height: DesignTokens.space4),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: vm.connectionStatus ==
                                    ConnectionStatus.checking
                                ? null
                                : () => vm.testConnection(),
                            child: vm.connectionStatus ==
                                    ConnectionStatus.checking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('Test Connection'),
                          ),
                          const SizedBox(width: DesignTokens.space3),
                          if (vm.connectionStatus ==
                              ConnectionStatus.connected)
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: AppColors.accent, size: 18),
                                const SizedBox(width: 4),
                                Text('Connected',
                                    style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: DesignTokens.footnote)),
                              ],
                            ),
                          if (vm.connectionStatus == ConnectionStatus.error)
                            Row(
                              children: [
                                const Icon(Icons.error,
                                    color: AppColors.danger, size: 18),
                                const SizedBox(width: 4),
                                Text('Failed',
                                    style: TextStyle(
                                        color: AppColors.danger,
                                        fontSize: DesignTokens.footnote)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignTokens.space6),

                // Refresh & Alerts
                _sectionTitle('Refresh & Alerts', textPrimary),
                const SizedBox(height: DesignTokens.space3),
                _card(
                  surface,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Refresh interval',
                              style: TextStyle(
                                  fontSize: DesignTokens.body,
                                  color: textPrimary)),
                          DropdownButton<int>(
                            value: vm.refreshIntervalMinutes,
                            items: const [1, 2, 5, 10, 15, 30]
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text('${m}m')))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) vm.setRefreshInterval(v);
                            },
                            underline: const SizedBox(),
                          ),
                        ],
                      ),
                      Divider(color: divider, height: DesignTokens.space5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Low threshold',
                              style: TextStyle(
                                  fontSize: DesignTokens.body,
                                  color: textPrimary)),
                          DropdownButton<int>(
                            value: vm.lowThreshold,
                            items: const [10, 15, 20, 25, 30, 50]
                                .map((p) => DropdownMenuItem(
                                    value: p, child: Text('$p%')))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) vm.setLowThreshold(v);
                            },
                            underline: const SizedBox(),
                          ),
                        ],
                      ),
                      Divider(color: divider, height: DesignTokens.space5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Notifications',
                              style: TextStyle(
                                  fontSize: DesignTokens.body,
                                  color: textPrimary)),
                          Switch(
                            value: vm.notificationsEnabled,
                            onChanged: (v) => vm.setNotificationsEnabled(v),
                            activeTrackColor: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignTokens.space6),

                // Appearance
                _sectionTitle('Appearance', textPrimary),
                const SizedBox(height: DesignTokens.space3),
                _card(
                  surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Theme',
                          style: TextStyle(
                              fontSize: DesignTokens.body,
                              color: textPrimary)),
                      SegmentedButton<ThemeModeOption>(
                        segments: ThemeModeOption.values
                            .map((t) => ButtonSegment(
                                value: t, label: Text(t.displayName)))
                            .toList(),
                        selected: {vm.themeMode},
                        onSelectionChanged: (set) {
                          vm.setThemeMode(set.first);
                        },
                        style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(
                            TextStyle(fontSize: DesignTokens.footnote),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignTokens.space7),
                Center(
                  child: Text(
                    'TokenBar for Desktop',
                    style: TextStyle(
                      fontSize: DesignTokens.caption1,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space3),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openClaudeLogin(SettingsViewModel vm) async {
    final Widget loginPage = isWebViewSupported
        ? const ClaudeLoginView()
        : const ClaudeManualLoginView();
    final sessionKey = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => loginPage),
    );
    if (sessionKey != null && sessionKey.isNotEmpty) {
      await vm.saveSessionToken(sessionKey);
      _sessionTokenController.text = sessionKey;
    }
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: DesignTokens.subheadline,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _card(Color surface, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: child,
    );
  }
}
