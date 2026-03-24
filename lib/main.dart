import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init storage
  await StorageService.init();

  // Window manager setup for desktop
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(400, 700),
    minimumSize: Size(350, 500),
    center: true,
    title: 'TokenBar',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const TokenBarApp());
}
