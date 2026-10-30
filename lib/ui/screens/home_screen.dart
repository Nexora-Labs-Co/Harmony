import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/cached_artwork.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _recommended = [];
  bool _recommendedReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recommendedReady) {
      final tracks = context.read<LibraryProvider>().allTracks;
      if (tracks.isNotEmpty) {
        final shuffled = List<dynamic>.from(tracks)..shuffle();
        _recommended = shuffled.take(8).toList();
        _recommendedReady = true;
      }
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final playlistProvider = context.watch<PlaylistProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = library.allTracks;
    final recommended = _recommended.isNotEmpty
        ? _recommended
        : (tracks.isEmpty ? <dynamic>[] : tracks.take(8).toList());
    final recent = player.recentlyPlayed.isNotEmpty
        ? player.recentlyPlayed.take(8).toList()
        : (tracks.isEmpty ? <dynamic>[] : tracks.take(8).toList());
    final albums = playlistProvider.playlists.take(8).toList();

    return Container(
      color: NexoraColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, Santiago',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NexoraColors.foreground,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tu música, tu ritmo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: NexoraColors.muted,
                  ),
            ),
            const SizedBox(height: 24),
            // Quick access grid
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisExtent: 56,
              children: [
                NxQuickAccessCard(
                  title: 'Favoritos',
                  height: 56,
                  thumbnail: Image.asset('assets/icons/Logo-Favoritos.png', fit: BoxFit.cover),
                ),
                NxQuickAccessCard(
                  title: 'Biblioteca local',
                  height: 56,
                  thumbnail: Image.asset('assets/icons/Logo-Local.png', fit: BoxFit.cover),
                ),
                NxQuickAccessCard(
                  title: 'Cari Mixes',
                  height: 56,
                  thumbnail: Image.asset('assets/icons/Logo-Cari.png', fit: BoxFit.cover),
                ),
                NxQuickAccessCard(
                  title: 'Álbumes recientes',
                  height: 56,
                  thumbnail: Image.asset('assets/icons/Logo-Inicio.png', fit: BoxFit.cover),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Recomendado por Cari'),
            const SizedBox(height: 12),
            _mediaRow(
              context,
              recommended,
              player,
              library,
              (track) => _trackCard(context, track, player, library),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Recientes'),
            const SizedBox(height: 12),
            _mediaRow(
              context,
              recent,
              player,
              library,
              (track) => _trackCard(context, track, player, library),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Álbumes'),
            const SizedBox(height: 12),
            _mediaRow(
              context,
              albums,
              player,
              library,
              (album) => _albumCard(context, album, library),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: NexoraColors.foreground,
          ),
    );
  }

  Widget _mediaRow(BuildContext context, List items, PlayerProvider player,
      LibraryProvider library, Widget Function(dynamic) builder) {
    if (items.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text('Sin contenido',
              style: TextStyle(color: NexoraColors.muted)),
        ),
      );
    }
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: builder(items[index]),
        ),
      ),
    );
  }

  Widget _trackCard(BuildContext context, dynamic track, PlayerProvider player,
      LibraryProvider library) {
    return NxMediaCard(
      size: 160,
      title: track.title,
      subtitle: track.artist,
      cover: CachedArtwork(
        albumArt: track.albumArt,
        width: 160,
        height: 160,
        borderRadius: BorderRadius.circular(8),
        fallback: Container(
          width: 160,
          height: 160,
          color: NexoraColors.surfaceAlt,
          child: FaIcon(FontAwesomeIcons.music, color: NexoraColors.muted),
        ),
      ),
      onTap: () => player.setQueue(
        library.allTracks,
        startIndex: library.allTracks
            .indexOf(track)
            .clamp(0, library.allTracks.length - 1),
      ),
    );
  }

  Widget _albumCard(
      BuildContext context, dynamic album, LibraryProvider library) {
    String? art;
    if (album.coverImagePath != null &&
        (album.coverImagePath as String).isNotEmpty) {
      // handled by Image.file below
    } else if (album.trackIds != null && (album.trackIds as List).isNotEmpty) {
      for (final t in library.allTracks) {
        if (t.id == (album.trackIds as List).first) {
          art = t.albumArt;
          break;
        }
      }
    }
    final cover = (album.coverImagePath != null &&
            (album.coverImagePath as String).isNotEmpty)
        ? Image.file(
            File(album.coverImagePath as String),
            width: 160,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholderArt(),
          )
        : (art != null && art.isNotEmpty)
            ? CachedArtwork(
                albumArt: art,
                width: 160,
                height: 160,
                borderRadius: BorderRadius.circular(8),
                fallback: _placeholderArt(),
              )
            : _placeholderArt();

    return NxMediaCard(
      size: 160,
      title: album.name ?? 'Álbum',
      subtitle: 'Álbum',
      cover: cover,
      onTap: () {},
    );
  }

  Widget _placeholderArt() {
    return Container(
      width: 160,
      height: 160,
      color: NexoraColors.surfaceAlt,
      child: FaIcon(FontAwesomeIcons.compactDisc,
          size: 40, color: NexoraColors.mutedStrong),
    );
  }
}


