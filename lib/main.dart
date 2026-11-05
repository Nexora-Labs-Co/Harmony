import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:xora/xora.dart';
import 'package:harmony/src/screens/one/home_screen.dart';
import 'package:harmony/src/screens/one/playlists_screen.dart';
import 'package:harmony/src/screens/one/favorites_screen.dart';
import 'package:harmony/src/screens/one/cari_screen.dart';
import 'package:harmony/src/screens/one/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await [Permission.audio, Permission.photos, Permission.storage].request();
  }
  runApp(const HarmonyApp());
}

class HarmonyApp extends StatefulWidget {
  const HarmonyApp({super.key});

  @override
  State<HarmonyApp> createState() => _HarmonyAppState();
}

class _HarmonyAppState extends State<HarmonyApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmony',
      debugShowCheckedModeBanner: false,
      theme: XoraTheme.light().copyWith(
        colorScheme: XoraTheme.light().colorScheme.copyWith(primary: const Color(0xFFDFFF00)),
      ),
      darkTheme: XoraTheme.dark().copyWith(
        colorScheme: XoraTheme.dark().colorScheme.copyWith(primary: const Color(0xFFDFFF00)),
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: HarmonyHome(
        dark: _dark,
        onToggleTheme: () => setState(() => _dark = !_dark),
      ),
    );
  }
}

class HarmonyHome extends StatefulWidget {
  const HarmonyHome({
    super.key,
    required this.dark,
    required this.onToggleTheme,
  });

  final bool dark;
  final VoidCallback onToggleTheme;

  @override
  State<HarmonyHome> createState() => _HarmonyHomeState();
}

class _HarmonyHomeState extends State<HarmonyHome> {
  int _index = 0;
  String _userName = 'Usuario';
  String? _avatarPath;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(userName: _userName),
      PlaylistsScreen(),
      FavoritesScreen(),
      CariScreen(),
      SearchScreen(),
    ];
    return Scaffold(
      body: XoraResponsive(
        mobile: XoraOne(
          topBar: OneTopBar(
            appName: 'Harmony',
            avatar: _avatarPath == null
                ? XoraAvatar(initials: _userName.isNotEmpty ? _userName.substring(0, 1) : 'H')
                : null,
            accountAvatarPath: _avatarPath,
            accountName: _userName,
            accountStatus: 'Premium',
            accountInitials: _userName,
            onProfileChanged: (name, path) => setState(() {
              _userName = name;
              _avatarPath = path;
            }),
          ),
          bottomBar: OneBottomBar(
            selectedIndex: _index.clamp(0, 4),
            onTap: (i) => setState(() => _index = i),
            items: const [
              OneBottomBarItem(icon: XoraIcon(XoraIcons.home), label: 'Inicio'),
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.music),
                label: 'Librería',
              ),
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.heart),
                label: 'Favoritos',
              ),
              // OneBottomBarItem(
              //   icon: XoraIcon(XoraIcons.magnifyingGlass),
              //   label: 'Cari',
              // ),
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.magnifyingGlass),
                label: 'Buscar',
              ),
            ],
          ),
          child: pages[_index.clamp(0, pages.length - 1)],
        ),
        tablet: XoraSlate(child: pages[_index.clamp(0, pages.length - 1)]),
        desktop: XoraNexo(
          appName: 'Harmony',
          topItems: [
            NexoSidebarItem(
              label: 'Inicio',
              icon: XoraIcons.home,
              onTap: () => setState(() => _index = 0),
            ),
            NexoSidebarItem(
              label: 'Favoritos',
              icon: XoraIcons.heart,
              onTap: () => setState(() => _index = 2),
            ),
            // NexoSidebarItem(label: 'Cari', icon: XoraIcons.magnifyingGlass, onTap: () => setState(() => _index = 3)),
            NexoSidebarItem(
              label: 'Buscar',
              icon: XoraIcons.magnifyingGlass,
              onTap: () => setState(() => _index = 4),
            ),
          ],
          sidebarSections: [
            NexoSidebarSection(
              title: 'Librería',
              items: [
                NexoSidebarItem(
                  label: 'Playlists',
                  icon: XoraIcons.music,
                  onTap: () => setState(() => _index = 1),
                ),
              ],
            ),
          ],
          userName: 'Usuario',
          userStatus: 'Premium',
          userInitials: 'U',
          rightPanel: const SizedBox.shrink(),
          appVersion: 'v0.1.0',

          child: pages[_index.clamp(0, pages.length - 1)],
        ),
      ),
    );
  }
}

