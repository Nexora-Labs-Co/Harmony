import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:xora/xora.dart';
import 'package:harmony/src/screens/one/home_screen.dart';
import 'package:harmony/src/screens/one/playlists_screen.dart';
import 'package:harmony/src/screens/one/favorites_screen.dart';
import 'package:harmony/src/screens/one/cari_screen.dart';
import 'package:harmony/src/screens/one/search_screen.dart';
import 'package:harmony/src/services/local_music_service.dart';
import 'package:harmony/src/services/playlists_store.dart';
import 'package:harmony/src/shared/widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await [Permission.audio, Permission.photos, Permission.storage].request();
  }
  // Preload local music cache (Rust-backed metadata) without blocking UI.
  LocalMusicService.instance.scan();
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
        mobile: Stack(
          children: [
            XoraOne(
          topBar: OneTopBar(
            appName: _index == 2 ? null : 'Harmony',
            title: _index == 2 ? const Text('Favoritos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
            backgroundColor: _index == 2 ? const Color(0xFFFA3850) : null,
            avatar: _index == 2
                ? CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      _userName.isNotEmpty ? _userName.substring(0, 1).toUpperCase() : 'U',
                      style: const TextStyle(color: Color(0xFFFA3850), fontWeight: FontWeight.bold),
                    ),
                  )
                : (_avatarPath == null
                    ? XoraAvatar(initials: _userName.isNotEmpty ? _userName.substring(0, 1) : 'H')
                    : null),
            accountAvatarPath: _index == 2 ? null : _avatarPath,
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
            onTap: (i) {
              if (i == 5) {
                _showCreatePlaylistDialog(context);
              } else {
                setState(() => _index = i);
              }
            },
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
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.magnifyingGlass),
                label: 'Cari',
              ),
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.magnifyingGlass),
                label: 'Buscar',
              ),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.plus), label: '+'),
            ],
          ),
          child: pages[_index.clamp(0, pages.length - 1)],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 72,
              child: const MiniPlayer(),
            ),
          ],
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

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Crear')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    PlaylistsStore.instance.add(name);
  }
}

