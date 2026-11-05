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
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.palette),
                label: 'Biblioteca',
              ),
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.heart),
                label: 'Favoritos',
              ),
              OneBottomBarItem(
                icon: XoraIcon(XoraIcons.list),
                label: 'Playlists',
              ),
            ],
          ),
          child: pages[_index],
        ),
        tablet: XoraSlate(child: pages[_index]),
        desktop: XoraNexo(
          leftSidebar: const _HarmonySidebar(),
          appName: 'Harmony',
          sidebarSections: [
            NexoSidebarSection(
              title: 'Menú',
              items: [
                NexoSidebarItem(
                  label: 'Inicio',
                  icon: XoraIcons.home,
                  onTap: () => setState(() => _index = 0),
                ),
                NexoSidebarItem(
                  label: 'Favoritos',
                  icon: XoraIcons.heart,
                  onTap: () => setState(() => _index = 1),
                ),
                NexoSidebarItem(
                  label: 'Local',
                  icon: XoraIcons.locationDot,
                  onTap: () => setState(() => _index = 0),
                ),
                NexoSidebarItem(
                  label: 'Cari',
                  icon: XoraIcons.magnifyingGlass,
                  onTap: () => setState(() => _index = 0),
                ),
              ],
            ),
            NexoSidebarSection(
              title: 'Librería',
              items: [
                NexoSidebarItem(
                  label: 'Playlist 1',
                  icon: XoraIcons.music,
                  onTap: () => setState(() => _index = 2),
                ),
                NexoSidebarItem(
                  label: 'Playlist 2',
                  icon: XoraIcons.music,
                  onTap: () => setState(() => _index = 2),
                ),
                NexoSidebarItem(
                  label: 'Playlist 3',
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


class _HarmonySidebar extends StatelessWidget {
  const _HarmonySidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              children: const [
                _SidebarTile(icon: XoraIcons.home, label: 'Inicio'),
                _SidebarTile(icon: XoraIcons.heart, label: 'Favoritos'),
                _SidebarTile(icon: XoraIcons.magnifyingGlass, label: 'Cari'),
                _SidebarTile(icon: XoraIcons.locationDot, label: 'Local'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Álbumes', style: Theme.of(context).textTheme.titleSmall),
                XoraIconButton(
                  icon: XoraIcon(XoraIcons.plus),
                  onPressed: () {},
                  size: 28,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _PlaylistTile(name: 'Playlist 1'),
                _PlaylistTile(name: 'Playlist 2'),
                _PlaylistTile(name: 'Playlist 3'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.icon, required this.label});

  final dynamic icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return XoraCard(
      padding: const EdgeInsets.all(8),
      child: Center(child: XoraIcon(icon)),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: XoraIcon(XoraIcons.music),
      title: Text(name, style: const TextStyle(fontSize: 12)),
      dense: true,
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
            Text(
              'Biblioteca',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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

