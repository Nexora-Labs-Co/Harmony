import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/cached_artwork.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String? _hoveredId;

  String _formatArtists(String raw) {
    final parts = raw.split(RegExp(r'\s*/\s*'));
    if (parts.length <= 1) return raw.trim();
    final limited = parts.take(3).map((e) => e.trim()).toList();
    final joined = limited.join(' · ');
    return parts.length > 3 ? '$joined...' : joined;
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h h $m min';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = library.allTracks;
    final totalMs = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    final totalDur = Duration(milliseconds: totalMs);

    return Container(
      color: NexoraColors.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NxPlaylistHeader(
            height: 220,
            coverImage: const AssetImage('assets/icons/Logo-Local.png'),
            title: 'BIBLIOTECA',
            bottomMetadata:
                'Saaarmyx · ${tracks.length} canciones, ${_formatDuration(totalDur)}',
            onPlay: tracks.isNotEmpty ? () => player.setQueue(tracks.cast()) : null,
            onShuffle: tracks.isNotEmpty
                ? () {
                    player.setQueue(tracks.cast());
                    player.toggleShuffle();
                  }
                : null,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                SizedBox(
                    width: 32,
                    child: Text('#',
                        style: TextStyle(
                            color: NexoraColors.muted, fontSize: 12))),
                SizedBox(width: 8),
                Expanded(
                    flex: 3,
                    child: Text('Título',
                        style: TextStyle(
                            color: NexoraColors.muted, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Artistas',
                        style: TextStyle(
                            color: NexoraColors.muted, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Álbum',
                        style: TextStyle(
                            color: NexoraColors.muted, fontSize: 12))),
                SizedBox(
                    width: 60,
                    child: Text('Duración',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: NexoraColors.muted, fontSize: 12))),
                SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(color: NexoraColors.border, height: 1),
          Expanded(
            child: tracks.isEmpty
                ? const Center(
                    child: Text('Sin canciones',
                        style: TextStyle(color: NexoraColors.muted)))
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      final isFav = library.isFavorite(track.id);
                      final hovered = _hoveredId == track.id;
                      return MouseRegion(
                        onEnter: (_) => setState(() => _hoveredId = track.id),
                        onExit: (_) => setState(() => _hoveredId = null),
                        child: InkWell(
                          onTap: () =>
                              player.setQueue(tracks, startIndex: index),
                          child: Container(
                            color: hovered
                                ? NexoraColors.surfaceHover
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 32,
                                    child: Text('${index + 1}',
                                        style: const TextStyle(
                                            color: NexoraColors.muted,
                                            fontSize: 12))),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedArtwork(
                                          albumArt: track.albumArt,
                                          width: 36,
                                          height: 36,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          fallback: Container(
                                            width: 36,
                                            height: 36,
                                            color: NexoraColors.surfaceAlt,
                                            child: FaIcon(
                                                FontAwesomeIcons.music,
                                                size: 16,
                                                color: NexoraColors.muted),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          track.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: NexoraColors.foreground,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatArtists(track.artist),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: NexoraColors.muted,
                                        fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    track.album,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: NexoraColors.mutedStrong,
                                        fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    _formatMs(track.durationMs),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: NexoraColors.muted,
                                        fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    icon: FaIcon(
                                      isFav
                                          ? FontAwesomeIcons.solidHeart
                                          : FontAwesomeIcons.heart,
                                      size: 16,
                                      color: isFav
                                          ? const Color(0xFFA50021)
                                          : NexoraColors.muted,
                                    ),
                                    onPressed: () =>
                                        library.toggleFavorite(track.id),
                                  ),
                                ),
                              ],
                            ),
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
