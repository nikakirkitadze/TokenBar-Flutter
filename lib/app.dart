import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/enums.dart';
import 'theme/app_colors.dart';
import 'view_models/dashboard_view_model.dart';
import 'view_models/settings_view_model.dart';
import 'views/dashboard_view.dart';

class TokenBarApp extends StatelessWidget {
  const TokenBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          ThemeMode themeMode;
          switch (settings.themeMode) {
            case ThemeModeOption.dark:
              themeMode = ThemeMode.dark;
              break;
            case ThemeModeOption.light:
              themeMode = ThemeMode.light;
              break;
            case ThemeModeOption.system:
              themeMode = ThemeMode.system;
              break;
          }

          return MaterialApp(
            title: 'TokenBar',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeMode,
            home: const DashboardView(),
          );
        },
      ),
    );
  }
}
