import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_service.dart';
import 'providers/player_provider.dart';
import 'providers/library_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/search_provider.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/desktop_shell.dart';
import 'ui/layouts/responsive_layout.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexoraApp());
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
        title: 'Nexora',
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
