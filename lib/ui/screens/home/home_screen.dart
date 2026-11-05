
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xora/xora.dart';
import 'package:harmony/core/models/track.dart';
import 'package:harmony/core/models/playlist.dart';
import 'package:harmony/core/state/library_provider.dart';
import 'package:harmony/core/state/playlist_provider.dart';
import 'package:harmony/core/state/player_provider.dart';
// import 'package:harmony/core/state/profile_provider.dart';
import 'package:harmony/core/services/youtube_service.dart';
import 'package:harmony/core/services/recommendation_service.dart';
import 'package:harmony/ui/shared/widgets/cached_artwork.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigate, this.onOpenPlaylist});

  final void Function(int index)? onNavigate;
  final void Function(String playlistId)? onOpenPlaylist;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static List<YouTubeTrack> _cachedNewReleases = [];
  static DateTime? _cachedAt;

  List<YouTubeTrack> _newReleases = [];
  bool _loadingNewReleases = true;

  @override
  void initState() {
    super.initState();
    _loadNewReleases();
  }

  Future<void> _loadNewReleases() async {
    final now = DateTime.now();
    if (_cachedNewReleases.isNotEmpty &&
        _cachedAt != null &&
        _cachedAt!.day == now.day &&
        _cachedAt!.month == now.month &&
        _cachedAt!.year == now.year) {
      if (!mounted) return;
      setState(() {
        _newReleases = List<YouTubeTrack>.from(_cachedNewReleases);
        _loadingNewReleases = false;
      });
      return;
    }
    final results = await YouTubeService.instance.search('nuevos lanzamientos');
    if (!mounted) return;
    final fresh = results.take(8).toList();
    setState(() {
      _newReleases = fresh;
      _loadingNewReleases = false;
    });
    _cachedNewReleases = List<YouTubeTrack>.from(fresh);
    _cachedAt = now;
  }

  // String _greeting() {
  //   final h = DateTime.now().hour;
  //   if (h >= 5 && h < 12) return 'Buenos días';
  //   if (h >= 12 && h < 19) return 'Buenas tardes';
  //   return 'Buenas noches';
  // }

  List<Track> _tracksForPlaylist(Playlist p, LibraryProvider lib) {
    return p.trackIds
        .map((id) {
          for (final t in lib.allTracks) {
            if (t.id == id) return t;
          }
          return null;
        })
        .whereType<Track>()
        .toList();
  }

  void _playPlaylist(Playlist p, LibraryProvider lib, PlayerProvider player) {
    final tracks = _tracksForPlaylist(p, lib);
    if (tracks.isNotEmpty) {
      player.setQueue(tracks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final playlistProvider = context.watch<PlaylistProvider>();
    final player = context.watch<PlayerProvider>();
    // final profile = context.watch<ProfileProvider>();
    final tracks = library.allTracks;
    RecommendationService.instance.setLibrary(tracks);
    RecommendationService.instance.updateForTrack(player.currentTrack);
    final recommended = RecommendationService.instance.recommended.isNotEmpty
        ? RecommendationService.instance.recommended
        : (tracks.isEmpty ? <Track>[] : tracks.take(8).toList());
    final recentRaw = player.recentlyPlayed.isNotEmpty
        ? player.recentlyPlayed.toList()
        : (tracks.isEmpty ? <Track>[] : tracks.take(8).toList());
    final seenRecent = <String>{};
    final recent = <Track>[];
    for (final t in recentRaw) {
      final key = t.title.toLowerCase();
      if (seenRecent.add(key)) recent.add(t);
      if (recent.length >= 10) break;
    }
    final albums = playlistProvider.playlists.take(10).toList();

    return Container(
      color: XoraColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   '${_greeting()}, ${profile.name}',
            //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //     fontWeight: FontWeight.bold,
            //     color: XoraColors.textPrimary,
            //   ),
            // ),
            // const SizedBox(height: 4),
            // Text(
            //   'Tu música, a tu manera.',
            //   style: Theme.of(context).textTheme.bodyLarge
            //       ?.copyWith(color: XoraColors.textSecondary),
            // ),
            _quickAccess(
              context,
              library,
              playlistProvider,
              player,
              tracks,
              recent,
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Nuevos lanzamientos para ti'),
            const SizedBox(height: 12),
            _loadingNewReleases
                ? const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _mediaRow(
                    context,
                    _newReleases,
                    (yt) => _youtubeCard(context, yt, player),
                  ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Recomendado por Cari'),
            const SizedBox(height: 12),
            _mediaRow(
              context,
              recommended,
              (track) => _trackCard(context, track, player, library),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Recientes'),
            const SizedBox(height: 12),
            _mediaRow(
              context,
              recent,
              (track) => _trackCard(context, track, player, library),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Álbumes'),
            const SizedBox(height: 12),
            _mediaRow(
              context,
              albums,
              (album) => _albumCard(context, album, library),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccess(
    BuildContext context,
    LibraryProvider library,
    PlaylistProvider playlistProvider,
    PlayerProvider player,
    List<Track> tracks,
    List<Track> recent,
  ) {
    final recentTrack = recent.isNotEmpty
        ? recent.first
        : (tracks.isNotEmpty ? tracks.first : null);

    Widget thumbForPlaylist(Playlist? p) {
      if (p != null && p.trackIds.isNotEmpty) {
        for (final t in library.allTracks) {
          if (t.id == p.trackIds.first) {
            return CachedArtwork(
              albumArt: t.albumArt,
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(6),
              fallback: const Icon(Icons.music_note),
            );
          }
        }
      }
      return const Icon(Icons.music_note);
    }

    Widget thumbForTrack(Track? t) {
      if (t != null) {
        return CachedArtwork(
          albumArt: t.albumArt,
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(6),
          fallback: const Icon(Icons.music_note),
        );
      }
      return const Icon(Icons.music_note);
    }

    final cards = <Widget>[
      _quickCard(
        'Favoritos',
        const Icon(Icons.favorite),
        () => widget.onNavigate?.call(2),
      ),
      _quickCard(
        'Local',
        const Icon(Icons.library_music),
        () => widget.onNavigate?.call(5),
      ),
      _quickCard(
        'Cari',
        const Icon(Icons.search),
        () => widget.onNavigate?.call(3),
      ),
      _quickCard(
        (playlistProvider.playlists.isNotEmpty ? playlistProvider.playlists.first.name : 'Playlist'),
        playlistProvider.playlists.isNotEmpty
            ? thumbForPlaylist(playlistProvider.playlists.first)
            : thumbForTrack(recentTrack),
        () {
          if (playlistProvider.playlists.isNotEmpty) {
            _playPlaylist(playlistProvider.playlists.first, library, player);
          } else {
            final t = recentTrack;
            if (t != null) player.playTrack(t);
          }
        },
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisExtent: 56,
      children: cards,
    );
  }

  Widget _quickCard(String title, Widget thumbnail, VoidCallback onTap) {
    return XoraCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(width: 40, height: 40, child: thumbnail),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
        color: XoraColors.textPrimary,
      ),
    );
  }

  Widget _mediaRow(
    BuildContext context,
    List items,
    Widget Function(dynamic) builder,
  ) {
    if (items.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Sin contenido',
            style: TextStyle(color: XoraColors.textSecondary),
          ),
        ),
      );
    }
    final visibleItems = items.take(8).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        if (!isWide) {
          return SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visibleItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  SizedBox(width: 120, child: builder(visibleItems[index])),
            ),
          );
        }
        final crossAxisCount = (constraints.maxWidth / 150).floor().clamp(4, 8);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: visibleItems.length,
          itemBuilder: (context, index) => builder(visibleItems[index]),
        );
      },
    );
  }

  Widget _youtubeCard(
    BuildContext context,
    YouTubeTrack yt,
    PlayerProvider player,
  ) {
    return XoraCard(
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedArtwork(
                  albumArt: yt.thumbnailUrl,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(8),
                  fallback: Container(
                    color: XoraColors.surfaceVariant,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              yt.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              yt.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: XoraColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trackCard(
    BuildContext context,
    dynamic track,
    PlayerProvider player,
    LibraryProvider library,
  ) {
    return XoraCard(
      child: InkWell(
        onTap: () {
          final idx = library.allTracks.indexWhere((t) => t.id == track.id);
          if (idx >= 0) {
            player.setQueue(library.allTracks, startIndex: idx);
          } else {
            player.playTrack(track);
          }
        },
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
                    color: XoraColors.surfaceVariant,
                    child: const Icon(Icons.music_note),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: XoraColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _albumCard(
    BuildContext context,
    dynamic album,
    LibraryProvider library,
  ) {
    return XoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: XoraColors.surfaceVariant,
                child: const Icon(Icons.album),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.name ?? 'Álbum',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
