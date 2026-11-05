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
      const _HomePage(),
      const _PlaylistsPage(),
      const _FavoritesPage(),
      const _CariPage(),
      const _SearchPage(),
      const _LocalPage(),
    ];
    final mobilePages = <Widget>[
      const _MobileHomePage(),
      const _PlaylistsPage(),
      const _FavoritesPage(),
      const _CariPage(),
      const _SearchPage(),
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
            NexoSidebarItem(
              label: 'Local',
              icon: XoraIcons.locationDot,
              onTap: () => setState(() => _index = 5),
            ),
            NexoSidebarItem(
              label: 'Cari',
              imageAsset: 'packages/xora/assets/icons/Logo-Cari.png',
              onTap: () => setState(() => _index = 3),
            ),
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
                NexoSidebarItem(
                  label: 'Playlist 1',
                  icon: XoraIcons.list,
                  onTap: () => setState(() => _index = 1),
                ),
                NexoSidebarItem(
                  label: 'Playlist 2',
                  icon: XoraIcons.list,
                  onTap: () => setState(() => _index = 1),
                ),
              ],
            ),
          ],
          userName: 'Usuario',
          userStatus: 'Premium',
          userInitials: 'U',
          rightPanel: const _RightPanel(),
          appVersion: 'v0.1.0',
          onToggleTheme: widget.onToggleTheme,
          isDark: widget.dark,
          child: pages[_index.clamp(0, pages.length - 1)],
        ),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Buenos días', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        XoraCard(
          child: Row(
            children: [
              XoraAvatar(initials: 'H', size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harmony', style: Theme.of(context).textTheme.titleLarge),
                    Text('Reproductor de música', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              XoraButton(label: 'Reproducir', icon: XoraIcon(XoraIcons.plus)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Recomendados', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (int i = 0; i < 4; i++)
          XoraListTile(
            leading: XoraAvatar(initials: 'S${i + 1}'),
            title: Text('Canción ${i + 1}'),
            subtitle: Text('Artista ${i + 1}'),
            trailing: XoraIcon(XoraIcons.heart),
          ),
      ],
    );
  }
}

class _MobileHomePage extends StatelessWidget {
  const _MobileHomePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Text('Buenos días', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Tu música, a tu manera.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisExtent: 64,
          children: const [
            _QuickTile(icon: XoraIcon(XoraIcons.heart), label: 'Favoritos'),
            _QuickTile(icon: XoraIcon(XoraIcons.magnifyingGlass), label: 'DJ Cari'),
            _QuickTile(icon: XoraIcon(XoraIcons.music), label: 'Biblioteca'),
            _QuickTile(icon: XoraIcon(XoraIcons.list), label: 'Playlists'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Nuevos lanzamientos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(
              width: 120,
              child: XoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: XoraAvatar(initials: 'N${i + 1}', size: 96),
                    ),
                    const SizedBox(height: 8),
                    Text('Lanzamiento ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Artista ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Recomendado por Cari', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (int i = 0; i < 4; i++)
          XoraListTile(
            leading: XoraAvatar(initials: 'R${i + 1}'),
            title: Text('Canción ${i + 1}'),
            subtitle: Text('Artista ${i + 1}'),
            trailing: XoraIcon(XoraIcons.heart),
          ),
        const SizedBox(height: 24),
        Text('Recientes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (int i = 0; i < 4; i++)
          XoraListTile(
            leading: XoraAvatar(initials: 'Q${i + 1}'),
            title: Text('En cola ${i + 1}'),
            subtitle: Text('Artista ${i + 1}'),
          ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return XoraCard(
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Favoritos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        for (int i = 0; i < 6; i++)
          XoraListTile(
            leading: XoraAvatar(initials: 'F${i + 1}'),
            title: Text('Favorito ${i + 1}'),
            subtitle: Text('Artista ${i + 1}'),
            trailing: XoraIcon(XoraIcons.heart),
          ),
      ],
    );
  }
}

class _LocalPage extends StatelessWidget {
  const _LocalPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Local', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        for (int i = 0; i < 5; i++)
          XoraListTile(
            leading: XoraIcon(XoraIcons.music),
            title: Text('Pista local ${i + 1}'),
            subtitle: Text('Álbum ${i + 1}'),
          ),
      ],
    );
  }
}

class _CariPage extends StatelessWidget {
  const _CariPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: XoraCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            XoraIcon(XoraIcons.magnifyingGlass, size: 48),
            const SizedBox(height: 16),
            Text('Cari', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Tu asistente de IA', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _PlaylistsPage extends StatelessWidget {
  const _PlaylistsPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Playlists', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        for (int i = 0; i < 4; i++)
          XoraCard(
            child: ListTile(
              leading: XoraIcon(XoraIcons.list),
              title: Text('Playlist ${i + 1}'),
              subtitle: Text('${i + 3} pistas'),
            ),
          ),
      ],
    );
  }
}

class _SearchPage extends StatelessWidget {
  const _SearchPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Buscar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        const XoraTextField(
          hint: 'Buscar canciones, artistas o álbumes',
          prefixIcon: XoraIcon(XoraIcons.magnifyingGlass),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < 5; i++)
          XoraListTile(
            leading: XoraIcon(XoraIcons.magnifyingGlass),
            title: Text('Resultado ${i + 1}'),
            subtitle: Text('Artista ${i + 1}'),
          ),
      ],
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
        const SizedBox(height: 16),
        Text('Cola', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (int i = 0; i < 3; i++)
          XoraListTile(
            leading: XoraAvatar(initials: 'Q${i + 1}'),
            title: Text('En cola ${i + 1}'),
            subtitle: Text('Artista ${i + 1}'),
          ),
      ],
    );
  }
}

