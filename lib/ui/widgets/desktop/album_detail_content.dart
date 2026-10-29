import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../providers/library_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_provider.dart';
import '../../../bridge/bridge_generated.dart';
import '../cached_artwork.dart';
import 'album_header_view.dart';
import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class AlbumDetailContent extends StatefulWidget {
  final String playlistId;
  const AlbumDetailContent({super.key, required this.playlistId});

  @override
  State<AlbumDetailContent> createState() => _AlbumDetailContentState();
}

class _AlbumDetailContentState extends State<AlbumDetailContent> {
  String? _hoveredId;
  String? _coverPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final playlist = context.read<PlaylistProvider>().playlists.firstWhere((p) => p.id == widget.playlistId);
        if (playlist.coverImagePath != null) {
          setState(() => _coverPath = playlist.coverImagePath);
        }
      } catch (_) {}
    });
  }

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
    final playlistProvider = context.watch<PlaylistProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final playerProvider = context.watch<PlayerProvider>();

    Playlist? playlist;
    for (final p in playlistProvider.playlists) {
      if (p.id == widget.playlistId) {
        playlist = p;
        break;
      }
    }
    if (playlist == null && playlistProvider.playlists.isNotEmpty) {
      playlist = playlistProvider.playlists.first;
    }
    if (playlist == null) {
      return const Center(child: Text('Álbum no encontrado'));
    }

    final tracks = playlist.trackIds
        .map((id) {
          for (final t in libraryProvider.allTracks) {
            if (t.id == id) return t;
          }
          return null;
        })
        .whereType<Track>()
        .toList();

    final totalMs = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    final totalDur = Duration(milliseconds: totalMs);

    return Container(
      color: NexoraColors.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlbumHeaderView(
            cover: GestureDetector(
              onTap: () async {
                final result = await FilePicker.pickFiles(type: FileType.image);
                if (result.isNotEmpty && result.single.path != null) {
                  final path = result.single.path!;
                  setState(() => _coverPath = path);
                  context.read<PlaylistProvider>().setCoverImagePath(widget.playlistId, path);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (_coverPath != null)
                    ? Image.file(
                        File(_coverPath!),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 200,
                          height: 200,
                          color: NexoraColors.surfaceAlt,
                          child: FaIcon(FontAwesomeIcons.compactDisc, size: 64, color: NexoraColors.muted),
                        ),
                      )
                    : (tracks.isNotEmpty)
                        ? CachedArtwork(
                            albumArt: tracks.first.albumArt,
                            width: 200,
                            height: 200,
                            borderRadius: BorderRadius.circular(8),
                            fallback: Container(
                              width: 200,
                              height: 200,
                              color: NexoraColors.surfaceAlt,
                              child: FaIcon(FontAwesomeIcons.compactDisc, size: 64, color: NexoraColors.muted),
                            ),
                          )
                        : Container(
                            width: 200,
                            height: 200,
                            color: NexoraColors.surfaceAlt,
                            child: FaIcon(FontAwesomeIcons.compactDisc, size: 64, color: NexoraColors.muted),
                          ),
              ),
            ),
            label: 'ÁLBUM',
            title: playlist.name,
            subtitle: 'Saaarmyx · ${tracks.length} canciones, ${_formatDuration(totalDur)}',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (tracks.isNotEmpty) playerProvider.setQueue(tracks);
                },
                icon: FaIcon(FontAwesomeIcons.play, size: 18),
                label: const Text('Reproducir todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexoraColors.foreground,
                  foregroundColor: NexoraColors.background,
                ),
              ),
              const SizedBox(width: 12),
              _iconButton(FontAwesomeIcons.shuffle, () {
                if (tracks.isNotEmpty) {
                  playerProvider.setQueue(tracks);
                  playerProvider.toggleShuffle();
                }
              }),
              _iconButton(FontAwesomeIcons.download, () {}),
              _iconButton(FontAwesomeIcons.userPlus, () {}),
              _iconButton(FontAwesomeIcons.ellipsis, () {}),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                SizedBox(width: 32, child: Text('#', style: TextStyle(color: NexoraColors.muted, fontSize: 12))),
                SizedBox(width: 8),
                Expanded(flex: 3, child: Text('Título', style: TextStyle(color: NexoraColors.muted, fontSize: 12))),
                Expanded(flex: 2, child: Text('Artistas', style: TextStyle(color: NexoraColors.muted, fontSize: 12))),
                Expanded(flex: 2, child: Text('Álbum', style: TextStyle(color: NexoraColors.muted, fontSize: 12))),
                SizedBox(width: 60, child: Text('Duración', textAlign: TextAlign.right, style: TextStyle(color: NexoraColors.muted, fontSize: 12))),
                SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(color: NexoraColors.border, height: 1),
          Expanded(
            child: tracks.isEmpty
                ? const Center(child: Text('Este álbum no tiene pistas', style: TextStyle(color: NexoraColors.muted)))
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      final isFav = libraryProvider.isFavorite(track.id);
                      final hovered = _hoveredId == track.id;
                      return MouseRegion(
                        onEnter: (_) => setState(() => _hoveredId = track.id),
                        onExit: (_) => setState(() => _hoveredId = null),
                        child: InkWell(
                          onTap: () => playerProvider.setQueue(tracks, startIndex: index),
                          child: Container(
                            color: hovered ? NexoraColors.surfaceHover : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                SizedBox(width: 32, child: Text('${index + 1}', style: const TextStyle(color: NexoraColors.muted, fontSize: 12))),
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
                                          fallback: Container(
                                            width: 36,
                                            height: 36,
                                            color: NexoraColors.surfaceAlt,
                                            child: FaIcon(FontAwesomeIcons.music, size: 16, color: NexoraColors.muted),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          track.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: NexoraColors.foreground, fontSize: 13, fontWeight: FontWeight.w600),
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
                                    style: const TextStyle(color: NexoraColors.muted, fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    track.album,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: NexoraColors.mutedStrong, fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    _formatMs(track.durationMs),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: NexoraColors.muted, fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    icon: FaIcon(
                                      isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                      size: 16,
                                      color: isFav ? const Color(0xFFA50021) : NexoraColors.muted,
                                    ),
                                    onPressed: () => libraryProvider.toggleFavorite(track.id),
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

  Widget _iconButton(FaIconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: FaIcon(icon, size: 16, color: NexoraColors.mutedStrong),
      onPressed: onPressed,
    );
  }
}
