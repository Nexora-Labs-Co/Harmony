import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xora/xora.dart';
import 'package:harmony/core/models/track.dart';
import 'package:harmony/core/models/playlist.dart';
import 'package:harmony/core/state/library_provider.dart';
import 'package:harmony/core/state/playlist_provider.dart';
import 'package:harmony/core/state/player_provider.dart';
import 'package:harmony/core/state/profile_provider.dart';
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buenos días';
    if (h >= 12 && h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

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
    final profile = context.watch<ProfileProvider>();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, ${profile.name}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: XoraColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tu música, a tu manera.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: XoraColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            _quickAccess(context, library, playlistProvider, player, tracks, recent),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Nuevos lanzamientos para ti'),
            const SizedBox(height: 12),
            _loadingNewReleases
                ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
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
    final playlists = playlistProvider.playlists;
    final random = Random();

    Playlist? mostPlayed;
    if (playlists.isNotEmpty) {
      mostPlayed = playlists.reduce((a, b) => a.trackIds.length >= b.trackIds.length ? a : b);
    }
    Playlist? mostRecent;
    if (playlists.isNotEmpty) {
      mostRecent = playlists.last;
      if (playlists.length > 1 && mostRecent.id == mostPlayed?.id) {
        mostRecent = playlists[playlists.length - 2];
      }
    }
    final usedPlaylistIds = <String>{};
    if (mostPlayed != null) usedPlaylistIds.add(mostPlayed.id);
    if (mostRecent != null) usedPlaylistIds.add(mostRecent.id);
    final remainingPlaylists = playlists.where((p) => !usedPlaylistIds.contains(p.id)).toList();
    Playlist? random1;
    Playlist? random2;
    if (remainingPlaylists.isNotEmpty) {
      random1 = remainingPlaylists[random.nextInt(remainingPlaylists.length)];
      usedPlaylistIds.add(random1.id);
      final rem2 = remainingPlaylists.where((p) => p.id != random1!.id).toList();
      if (rem2.isNotEmpty) {
        random2 = rem2[random.nextInt(rem2.length)];
      } else if (remainingPlaylists.length > 1) {
        random2 = remainingPlaylists[random.nextInt(remainingPlaylists.length)];
      }
    }

    final recentTrack = recent.isNotEmpty ? recent.first : (tracks.isNotEmpty ? tracks.first : null);
    final usedTrackIds = <String>{};
    if (recentTrack != null) usedTrackIds.add(recentTrack.id);
    Track? fallbackTrack1;
    for (final t in tracks) {
      if (!usedTrackIds.contains(t.id)) {
        fallbackTrack1 = t;
        usedTrackIds.add(t.id);
        break;
      }
    }
    Track? fallbackTrack2;
    for (final t in tracks) {
      if (!usedTrackIds.contains(t.id)) {
        fallbackTrack2 = t;
        usedTrackIds.add(t.id);
        break;
      }
    }

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
      _quickCard('Favoritos', const Icon(Icons.favorite), () => widget.onNavigate?.call(2)),
      _quickCard('DJ Cari', const Icon(Icons.search), () => widget.onNavigate?.call(3)),
      _quickCard('Biblioteca', const Icon(Icons.library_music), () => widget.onNavigate?.call(1)),
      _quickCard(
        mostPlayed != null ? mostPlayed.name : (fallbackTrack1?.title ?? 'Playlist más escuchada'),
        mostPlayed != null ? thumbForPlaylist(mostPlayed) : thumbForTrack(fallbackTrack1 ?? recentTrack),
        () {
          if (mostPlayed != null) {
            _playPlaylist(mostPlayed, library, player);
          } else {
            final t = fallbackTrack1 ?? recentTrack;
            if (t != null) player.playTrack(t);
          }
        },
      ),
      _quickCard(
        mostRecent != null ? mostRecent.name : (fallbackTrack2?.title ?? 'Playlist más reciente'),
        mostRecent != null ? thumbForPlaylist(mostRecent) : thumbForTrack(fallbackTrack2 ?? recentTrack),
        () {
          if (mostRecent != null) {
            _playPlaylist(mostRecent, library, player);
          } else {
            final t = fallbackTrack2 ?? recentTrack;
            if (t != null) player.playTrack(t);
          }
        },
      ),
      _quickCard(
        recentTrack?.title ?? 'Canción más reciente',
        thumbForTrack(recentTrack),
        () {
          if (recentTrack != null) player.playTrack(recentTrack);
        },
      ),
      _quickCard(
        random1 != null ? random1.name : (fallbackTrack1?.title ?? 'Playlist aleatoria'),
        random1 != null ? thumbForPlaylist(random1) : thumbForTrack(fallbackTrack1 ?? recentTrack),
        () {
          if (random1 != null) {
            _playPlaylist(random1, library, player);
          } else {
            final t = fallbackTrack1 ?? recentTrack;
            if (t != null) player.playTrack(t);
          }
        },
      ),
      _quickCard(
        random2 != null ? random2.name : (fallbackTrack2?.title ?? 'Playlist aleatoria'),
        random2 != null ? thumbForPlaylist(random2) : thumbForTrack(fallbackTrack2 ?? recentTrack),
        () {
          if (random2 != null) {
            _playPlaylist(random2, library, player);
          } else {
            final t = fallbackTrack2 ?? recentTrack;
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
            Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
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

  Widget _mediaRow(BuildContext context, List items, Widget Function(dynamic) builder) {
    if (items.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text('Sin contenido', style: TextStyle(color: XoraColors.textSecondary))),
      );
    }
    final visibleItems = items.take(8).toList();
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(width: 120, child: builder(visibleItems[index])),
      ),
    );
  }

  Widget _youtubeCard(BuildContext context, YouTubeTrack yt, PlayerProvider player) {
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
                  fallback: Container(color: XoraColors.surfaceVariant, child: const Icon(Icons.music_note)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(yt.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(yt.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: XoraColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _trackCard(BuildContext context, dynamic track, PlayerProvider player, LibraryProvider library) {
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
                  fallback: Container(color: XoraColors.surfaceVariant, child: const Icon(Icons.music_note)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: XoraColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _albumCard(BuildContext context, dynamic album, LibraryProvider library) {
    return XoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(color: XoraColors.surfaceVariant, child: const Icon(Icons.album)),
            ),
          ),
          const SizedBox(height: 8),
          Text(album.name ?? 'Álbum', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
