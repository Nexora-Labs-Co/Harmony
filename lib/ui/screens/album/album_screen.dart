import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xora/xora.dart';
import 'package:harmony/core/models/track.dart';
import 'package:harmony/core/models/playlist.dart';
import 'package:harmony/core/state/library_provider.dart';
import 'package:harmony/core/state/player_provider.dart';
import 'package:harmony/ui/shared/widgets/cached_artwork.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key, this.album, this.tracks = const []});

  final Playlist? album;
  final List<Track> tracks;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  String? _hoveredId;

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = widget.tracks.isNotEmpty
        ? widget.tracks
        : (widget.album != null
            ? widget.album!.trackIds
                .map((id) => library.allTracks.firstWhere((t) => t.id == id, orElse: () => library.allTracks.first))
                .toList()
            : library.allTracks);

    return Container(
      color: XoraColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(widget.album?.name ?? 'Álbum', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Saaarmyx · ${tracks.length} canciones', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: tracks.isEmpty
                  ? const Center(child: Text('Sin canciones', style: TextStyle(color: XoraColors.textSecondary)))
                  : ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        final hovered = _hoveredId == track.id;
                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredId = track.id),
                          onExit: (_) => setState(() => _hoveredId = null),
                          child: InkWell(
                            onTap: () => player.setQueue(tracks, startIndex: index),
                            child: Container(
                              color: hovered ? XoraColors.surfaceVariant : Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                children: [
                                  SizedBox(width: 32, child: Text('${index + 1}', style: const TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
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
                                            borderRadius: BorderRadius.circular(4),
                                            fallback: Container(width: 36, height: 36, color: XoraColors.surfaceVariant, child: const Icon(Icons.music_note, size: 18)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: XoraColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 2, child: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                                  SizedBox(width: 60, child: Text(_formatMs(track.durationMs), textAlign: TextAlign.right, style: const TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
