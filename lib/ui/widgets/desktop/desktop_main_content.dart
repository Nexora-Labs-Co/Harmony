import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/playlist_provider.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';
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
    child: FaIcon(FontAwesomeIcons.music,
        color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        return const _SearchTab();
      case 2:
        return const _SettingsTab();
      default:
        return const _HomeTab();
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final playlistProvider = context.watch<PlaylistProvider>();
    final playerProvider = context.watch<PlayerProvider>();
    final tracks = libraryProvider.allTracks;

    final recommended = tracks.isEmpty
        ? <dynamic>[]
        : List.generate(8, (i) => tracks[i % tracks.length]);
    final albums = playlistProvider.playlists.take(8).toList();
    final recent = tracks.isEmpty
        ? <dynamic>[]
        : tracks.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, Santiago',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tu música, tu ritmo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Recomendado por Cari, para ti'),
            const SizedBox(height: 12),
            _trackGrid(
              context,
              recommended,
              playerProvider,
              libraryProvider,
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Álbumes'),
            const SizedBox(height: 12),
            _albumGrid(context, albums),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Recientes'),
            const SizedBox(height: 12),
            _trackGrid(
              context,
              recent,
              playerProvider,
              libraryProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _trackGrid(
    BuildContext context,
    List tracks,
    PlayerProvider playerProvider,
    LibraryProvider libraryProvider,
  ) {
    if (tracks.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Sin canciones',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetWidth = 180.0;
        final crossAxisCount = (constraints.maxWidth / targetWidth).floor().clamp(2, 8);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _TrackCard(
              track: track,
              onTap: () {
                playerProvider.setQueue(libraryProvider.allTracks, startIndex: libraryProvider.allTracks.indexOf(track).clamp(0, libraryProvider.allTracks.length - 1));
              },
            );
          },
        );
      },
    );
  }

  Widget _albumGrid(BuildContext context, List albums) {
    if (albums.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Sin álbumes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetWidth = 180.0;
        final crossAxisCount = (constraints.maxWidth / targetWidth).floor().clamp(2, 8);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return _AlbumCard(album: album);
          },
        );
      },
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
          Text('Buscar',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar canciones, artistas, albumes o YouTube...',
              prefixIcon: FaIcon(FontAwesomeIcons.magnifyingGlass),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        FaIcon(FontAwesomeIcons.magnifyingGlass,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Buscar musica',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Busca en tu biblioteca o en YouTube',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (searchProvider.localResults.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                          child: Text('Biblioteca local',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        ...searchProvider.localResults.map((track) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _artworkFor(context, track.albumArt),
                              ),
                              title: Text(track.title),
                              subtitle:
                                  Text('${track.artist} • ${track.album}'),
                              trailing: IconButton(
                                icon: FaIcon(
                                  libraryProvider.isFavorite(track.id)
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  color: libraryProvider.isFavorite(track.id)
                                      ? const Color(0xFFA50021)
                                      : null,
                                ),
                                onPressed: () =>
                                    libraryProvider.toggleFavorite(track.id),
                              ),
                              onTap: () => playerProvider.setQueue(
                                  searchProvider.localResults,
                                  startIndex: searchProvider.localResults
                                      .indexOf(track)),
                            )),
                      ],
                      if (searchProvider.youtubeResults.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                          child: Text('YouTube',
                              style: Theme.of(context).textTheme.titleMedium),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: const FaIcon(
                                        FontAwesomeIcons.playCircle),
                                  ),
                                ),
                              ),
                              title: Text(yt.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle:
                                  Text('${yt.artist} · ${_fmt(yt.duration)}'),
                              trailing: FaIcon(FontAwesomeIcons.play),
                              onTap: () async {
                                await YouTubeService.instance.playTrack(yt);
                              },
                            )),
                      ],
                      if (searchProvider.localResults.isEmpty &&
                          searchProvider.youtubeResults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                              child: Text(
                                  'Sin resultados para "${searchProvider.query}"')),
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
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.palette),
            title: const Text('Tema'),
            subtitle: const Text('Claro / Oscuro / Sistema'),
            trailing: FaIcon(FontAwesomeIcons.chevronRight),
            onTap: () {},
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.folder),
            title: const Text('Carpetas de música'),
            subtitle: const Text('Gestionar directorios escaneados'),
            trailing: FaIcon(FontAwesomeIcons.chevronRight),
            onTap: () {},
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.circleInfo),
            title: const Text('Acerca de Harmony'),
            subtitle: const Text('Versión 26.10.27 (Beta)'),
            trailing: FaIcon(FontAwesomeIcons.chevronRight),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final dynamic track;
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
                  child: FaIcon(FontAwesomeIcons.music),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final dynamic album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    String? art;
    if (album.coverImagePath != null && (album.coverImagePath as String).isNotEmpty) {
      // handled below
    } else if (album.trackIds != null && (album.trackIds as List).isNotEmpty) {
      for (final t in library.allTracks) {
        if (t.id == (album.trackIds as List).first) {
          art = t.albumArt;
          break;
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: NexoraColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NexoraColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (album.coverImagePath != null && (album.coverImagePath as String).isNotEmpty)
                  ? Image.file(
                      File(album.coverImagePath as String),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: FaIcon(FontAwesomeIcons.compactDisc, size: 40, color: NexoraColors.mutedStrong)),
                    )
                  : (art != null && art.isNotEmpty)
                      ? CachedArtwork(
                          albumArt: art,
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: BorderRadius.circular(8),
                          fallback: const Center(child: FaIcon(FontAwesomeIcons.compactDisc, size: 40, color: NexoraColors.mutedStrong)),
                        )
                      : const Center(child: FaIcon(FontAwesomeIcons.compactDisc, size: 40, color: NexoraColors.mutedStrong)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          album.name ?? 'Álbum',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

