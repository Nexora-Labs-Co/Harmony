import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../bridge/bridge_generated.dart';
import '../../../providers/library_provider.dart';
import '../../../services/youtube_service.dart';
import '../cached_artwork.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/search_provider.dart';


Widget _artworkFor(BuildContext context, String? albumArt) {
  return CachedArtwork(
    albumArt: albumArt,
    width: 48,
    height: 48,
    borderRadius: BorderRadius.circular(4),
    fallback: _genericArt48(context),
  );
}

Widget _genericArt48(BuildContext context) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

class DesktopMainContent extends StatelessWidget {
  final int selectedIndex;

  const DesktopMainContent({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const _FavoritesTab();
      case 2:
        return const _SettingsTab();
      default:
        return const _HomeTab();
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final playerProvider = context.watch<PlayerProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido a Harmony',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu musica, tu ritmo',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          if (libraryProvider.allTracks.isNotEmpty) ...[
            const SizedBox(height: 8),
          ],
          Expanded(
            child: libraryProvider.allTracks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_music, size: 64, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Sin canciones', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Escanea una carpeta para comenzar',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tus canciones', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: libraryProvider.allTracks.length.clamp(0, 8),
                          itemBuilder: (context, index) {
                            final track = libraryProvider.allTracks[index];
                            return _TrackCard(track: track, onTap: () {
                              playerProvider.setQueue(libraryProvider.allTracks, startIndex: index);
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Text('Favoritos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (libraryProvider.favorites.isEmpty)
                          Text('Sin favoritos aun', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: libraryProvider.favorites.length.clamp(0, 8),
                            itemBuilder: (context, index) {
                              final track = libraryProvider.favorites[index];
                              return _TrackCard(track: track, onTap: () {
                                playerProvider.setQueue(libraryProvider.favorites, startIndex: index);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  const _TrackCard({required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedArtwork(
                albumArt: track.albumArt,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(8),
                fallback: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.music_note, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(track.artist.isEmpty ? 'Artista desconocido' : track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final playerProvider = context.watch<PlayerProvider>();

    final tracks = libraryProvider.favorites;
    final totalMs = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    final totalDur = Duration(milliseconds: totalMs);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, size: 48, color: Colors.red),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PLAYLIST', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text('Favoritos', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('${tracks.length} pistas • ${_formatMs(totalMs)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  if (tracks.isNotEmpty) playerProvider.setQueue(tracks);
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Reproducir todo'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  if (tracks.isNotEmpty) {
                    playerProvider.setQueue(tracks);
                    playerProvider.toggleShuffle();
                  }
                },
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('Aleatorio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cabecera de tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                SizedBox(width: 32, child: Text('#', style: Theme.of(context).textTheme.labelSmall)),
                const SizedBox(width: 44),
                Expanded(flex: 4, child: Text('Titulo', style: Theme.of(context).textTheme.labelSmall)),
                Expanded(flex: 2, child: Text('Album', style: Theme.of(context).textTheme.labelSmall)),
                SizedBox(width: 60, child: Text('Duracion', style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.right)),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: tracks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Sin favoritos', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Marca canciones como favoritas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      final isFav = libraryProvider.isFavorite(track.id);
                      return InkWell(
                        onTap: () => playerProvider.setQueue(tracks, startIndex: index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4))),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 32, child: Text('${index + 1}', style: Theme.of(context).textTheme.bodySmall)),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _artworkFor(context, track.albumArt),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                    Text(track.artist.isEmpty ? 'Artista desconocido' : track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(track.album, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ),
                              SizedBox(width: 60, child: Text(_formatMs(track.durationMs), textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodySmall)),
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, size: 16, color: isFav ? Colors.red : null),
                                  onPressed: () => libraryProvider.toggleFavorite(track.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final playerProvider = context.watch<PlayerProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buscar', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar canciones, artistas, albumes o YouTube...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            onChanged: (value) {
              searchProvider.search(value, libraryProvider.allTracks);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: searchProvider.query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Buscar musica', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Busca en tu biblioteca o en YouTube',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (searchProvider.localResults.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                          child: Text('Biblioteca local', style: Theme.of(context).textTheme.titleMedium),
                        ),
                        ...searchProvider.localResults.map((track) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _artworkFor(context, track.albumArt),
                              ),
                              title: Text(track.title),
                              subtitle: Text('${track.artist} • ${track.album}'),
                              trailing: IconButton(
                                icon: Icon(
                                  libraryProvider.isFavorite(track.id) ? Icons.favorite : Icons.favorite_border,
                                  color: libraryProvider.isFavorite(track.id) ? Colors.red : null,
                                ),
                                onPressed: () => libraryProvider.toggleFavorite(track.id),
                              ),
                              onTap: () => playerProvider.setQueue(searchProvider.localResults, startIndex: searchProvider.localResults.indexOf(track)),
                            )),
                      ],
                      if (searchProvider.youtubeResults.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                          child: Text('YouTube', style: Theme.of(context).textTheme.titleMedium),
                        ),
                        ...searchProvider.youtubeResults.map((yt) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedArtwork(
                                  albumArt: yt.thumbnailUrl,
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(4),
                                  fallback: Container(
                                    width: 48,
                                    height: 48,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.play_circle),
                                  ),
                                ),
                              ),
                              title: Text(yt.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${yt.artist} • ${_fmt(yt.duration)}'),
                              trailing: const Icon(Icons.play_arrow),
                              onTap: () async {
                                await YouTubeService.instance.playTrack(yt);
                              },
                            )),
                      ],
                      if (searchProvider.localResults.isEmpty && searchProvider.youtubeResults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(child: Text('Sin resultados para "${searchProvider.query}"')),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuración',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            subtitle: const Text('Claro / Oscuro / Sistema'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Carpetas de música'),
            subtitle: const Text('Gestionar directorios escaneados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de Harmony'),
            subtitle: const Text('Versión 26.10.27 (Beta)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
