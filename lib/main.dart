import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xora/xora.dart';
import 'package:harmony/core/state/library_provider.dart';
import 'package:harmony/core/state/playlist_provider.dart';
import 'package:harmony/core/state/player_provider.dart';
import 'package:harmony/core/state/profile_provider.dart';
import 'package:harmony/ui/screens/home/home_screen.dart';
import 'package:harmony/ui/screens/playlists/playlists_screen.dart';
import 'package:harmony/ui/screens/favorites/favorites_screen.dart';
import 'package:harmony/ui/screens/cari/cari_screen.dart';
import 'package:harmony/ui/screens/search/search_screen.dart';
import 'package:harmony/ui/screens/local/local_screen.dart';

void main() {
  runApp(const HarmonyApp());
}

class HarmonyApp extends StatelessWidget {
  const HarmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Harmony',
        debugShowCheckedModeBanner: false,
        theme: XoraTheme.light(),
        darkTheme: XoraTheme.dark(),
        themeMode: ThemeMode.light,
        home: const HarmonyHome(),
      ),
    );
  }
}

class HarmonyHome extends StatefulWidget {
  const HarmonyHome({super.key});

  @override
  State<HarmonyHome> createState() => _HarmonyHomeState();
}

class _HarmonyHomeState extends State<HarmonyHome> {
  int _index = 0;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onNavigate: (i) => setState(() => _index = i)),
      const PlaylistsScreen(),
      const FavoritesScreen(),
      const CariScreen(),
      const SearchScreen(),
      const LocalScreen(),
    ];
    final mobilePages = <Widget>[
      HomeScreen(onNavigate: (i) => setState(() => _index = i)),
      const PlaylistsScreen(),
      const FavoritesScreen(),
      const CariScreen(),
      const SearchScreen(),
      const LocalScreen(),
    ];

    return Scaffold(
      body: XoraResponsive(
        mobile: XoraOne(
          topBar: const OneTopBar(appName: 'Harmony', avatar: XoraAvatar(initials: 'H')),
          bottomBar: OneBottomBar(
            selectedIndex: _index.clamp(0, 4),
            onTap: (i) => setState(() => _index = i),
            items: const [
              OneBottomBarItem(icon: XoraIcon(XoraIcons.home), label: 'Inicio'),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.music), label: 'Librería'),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.heart), label: 'Favoritos'),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.magnifyingGlass), label: 'Cari'),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.magnifyingGlass), label: 'Buscar'),
            ],
          ),
          child: mobilePages[_index.clamp(0, mobilePages.length - 1)],
        ),
        tablet: XoraSlate(child: pages[_index.clamp(0, pages.length - 1)]),
        desktop: XoraNexo(
          appName: 'Harmony',
          sidebarSections: [
            NexoSidebarSection(
              title: 'Menú',
              items: [
                NexoSidebarItem(label: 'Inicio', icon: XoraIcons.home, onTap: () => setState(() => _index = 0)),
                NexoSidebarItem(label: 'Favoritos', icon: XoraIcons.heart, onTap: () => setState(() => _index = 2)),
                NexoSidebarItem(label: 'Local', icon: XoraIcons.locationDot, onTap: () => setState(() => _index = 5)),
                NexoSidebarItem(label: 'Cari', icon: XoraIcons.magnifyingGlass, onTap: () => setState(() => _index = 3)),
                NexoSidebarItem(label: 'Buscar', icon: XoraIcons.magnifyingGlass, onTap: () => setState(() => _index = 4)),
              ],
            ),
            NexoSidebarSection(
              title: 'Librería',
              items: [
                NexoSidebarItem(label: 'Playlists', icon: XoraIcons.music, onTap: () => setState(() => _index = 1)),
                NexoSidebarItem(label: 'Playlist 1', icon: XoraIcons.list, onTap: () => setState(() => _index = 1)),
                NexoSidebarItem(label: 'Playlist 2', icon: XoraIcons.list, onTap: () => setState(() => _index = 1)),
              ],
            ),
          ],
          userName: 'Usuario',
          userStatus: 'Premium',
          userInitials: 'U',
          rightPanel: const _RightPanel(),
          appVersion: 'v0.1.0',
          onToggleTheme: () => setState(() => _dark = !_dark),
          isDark: _dark,
          child: pages[_index.clamp(0, pages.length - 1)],
        ),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Reproduciendo', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        XoraCard(
          child: Column(
            children: [
              XoraAvatar(initials: 'S', size: 96),
              const SizedBox(height: 12),
              Text('Canción actual', style: Theme.of(context).textTheme.titleMedium),
              Text('Artista', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

