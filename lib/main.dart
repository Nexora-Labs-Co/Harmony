import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'services/audio_service.dart';
import 'services/update_service.dart';
import 'providers/player_provider.dart';
import 'providers/library_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/search_provider.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/desktop_shell.dart';
import 'ui/layouts/responsive_layout.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(960, 640),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  MediaKit.ensureInitialized();
  AudioService.instance.initialize();
  runApp(const NexoraApp());
  // Comprobacion de actualizaciones en segundo plano
  UpdateService.instance.setcurrentVersion('26.10.27');
  Future.delayed(const Duration(seconds: 5), () async {
    final info = await UpdateService.instance.checkForUpdate();
    if (info != null) {
      debugPrint('Update available: ${info['version']}');
    }
  });
}

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioService.instance..initialize()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
        title: 'Harmony',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const ResponsiveLayout(
          mobileBody: MainShell(),
          desktopBody: DesktopShell(),
        ),
      ),
    );
  }
}
