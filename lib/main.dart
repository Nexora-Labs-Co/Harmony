import 'package:flutter/material.dart';
import 'package:xora/xora.dart';

void main() {
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
      theme: XoraTheme.light(),
      darkTheme: XoraTheme.dark(),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: HarmonyHome(
        dark: _dark,
        onToggleTheme: () => setState(() => _dark = !_dark),
      ),
    );
  }
}

class HarmonyHome extends StatefulWidget {
  const HarmonyHome({super.key, required this.dark, required this.onToggleTheme});

  final bool dark;
  final VoidCallback onToggleTheme;

  @override
  State<HarmonyHome> createState() => _HarmonyHomeState();
}

class _HarmonyHomeState extends State<HarmonyHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _LibraryPage(),
      const _FavoritesPage(),
      const _PlaylistsPage(),
    ];

    return Scaffold(
      body: XoraResponsive(
        mobile: XoraOne(
          topBar: const OneTopBar(title: Text('Harmony')),
          bottomBar: OneBottomBar(
            selectedIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: const [
              OneBottomBarItem(icon: XoraIcon(XoraIcons.palette), label: 'Biblioteca'),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.heart), label: 'Favoritos'),
              OneBottomBarItem(icon: XoraIcon(XoraIcons.list), label: 'Playlists'),
            ],
          ),
          child: pages[_index],
        ),
        tablet: XoraSlate(child: pages[_index]),
        desktop: XoraNexo(
          appName: 'Harmony',
          sidebarSections: [
            NexoSidebarSection(
              title: 'Menú',
              items: [
                NexoSidebarItem(
                  label: 'Biblioteca',
                  icon: XoraIcons.palette,
                  onTap: () => setState(() => _index = 0),
                ),
                NexoSidebarItem(
                  label: 'Favoritos',
                  icon: XoraIcons.heart,
                  onTap: () => setState(() => _index = 1),
                ),
                NexoSidebarItem(
                  label: 'Playlists',
                  icon: XoraIcons.list,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ],
          userName: 'Usuario',
          userStatus: 'Premium',
          userInitials: 'U',
          rightPanel: XoraCard(
            child: Text('Reproduciendo: Canción ${_index + 1}'),
          ),
          appVersion: 'v0.1.0',
          onToggleTheme: widget.onToggleTheme,
          isDark: widget.dark,
          child: pages[_index],
        ),
      ),
    );
  }
}

class _LibraryPage extends StatelessWidget {
  const _LibraryPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: XoraCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            XoraAvatar(initials: 'H', size: 72),
            const SizedBox(height: 16),
            Text('Biblioteca', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Favoritos'));
  }
}

class _PlaylistsPage extends StatelessWidget {
  const _PlaylistsPage();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Playlists'));
  }
}

