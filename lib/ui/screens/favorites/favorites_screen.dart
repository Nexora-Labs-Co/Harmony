import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xora/xora.dart';
import 'package:harmony/core/state/library_provider.dart';
import 'package:harmony/core/state/playlist_provider.dart';
import 'package:harmony/core/state/player_provider.dart';
import 'package:harmony/ui/shared/widgets/cached_artwork.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? _hoveredId;

  String _formatArtists(String raw) {
    final parts = raw.split(RegExp(r'\s*/\s*'));
    if (parts.length <= 1) return raw.trim();
    final limited = parts.take(3).map((e) => e.trim()).toList();
    final joined = limited.join(' · ');
    return parts.length > 3 ? '$joined...' : joined;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h h $m min';
    return '$m min';
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Future<void> _addAllToPlaylist(BuildContext context) async {
    final library = context.read<LibraryProvider>();
    final playlistProvider = context.read<PlaylistProvider>();
    final tracks = library.favorites;
    if (tracks.isEmpty) return;
    if (playlistProvider.playlists.isEmpty) {
      playlistProvider.createPlaylist('Favoritos', '');
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Añadir a playlist'),
        children: playlistProvider.playlists
            .map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, p.id),
                  child: Text(p.name),
                ))
            .toList(),
      ),
    );
    if (selected == null || !context.mounted) return;
    for (final t in tracks) {
      playlistProvider.addTrackToPlaylist(selected, t.id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Añadidas ${tracks.length} canciones.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final tracks = library.favorites;
    final totalMs = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    final totalDur = Duration(milliseconds: totalMs);

    return Container(
      color: XoraColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFA3850),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'FAVORITOS',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saaarmyx · ${tracks.length} canciones, ${_formatDuration(totalDur)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    XoraButton(
                      label: 'Reproducir',
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: tracks.isNotEmpty ? () => player.setQueue(tracks) : null,
                    ),
                    const SizedBox(width: 8),
                    XoraButton(
                      label: 'Aleatorio',
                      icon: Icon(Icons.shuffle, color: Colors.white),
                      onPressed: tracks.isNotEmpty
                          ? () {
                              player.setQueue(tracks);
                              player.toggleShuffle();
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    XoraIconButton(
                      icon: XoraIcon(XoraIcons.plus, color: Colors.white),
                      onPressed: () => _addAllToPlaylist(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: const [
                        SizedBox(width: 32, child: Text('#', style: TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                        SizedBox(width: 8),
                        Expanded(flex: 3, child: Text('Título', style: TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                        Expanded(flex: 2, child: Text('Artistas', style: TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                        Expanded(flex: 2, child: Text('Álbum', style: TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                        SizedBox(width: 60, child: Text('Duración', textAlign: TextAlign.right, style: TextStyle(color: XoraColors.textSecondary, fontSize: 12))),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const Divider(color: XoraColors.border, height: 1),
                  Expanded(
                    child: tracks.isEmpty
                        ? const Center(child: Text('Sin favoritos', style: TextStyle(color: XoraColors.textSecondary)))
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
                                                  fallback: Container(
                                                    width: 36,
                                                    height: 36,
                                                    color: XoraColors.surfaceVariant,
                                                    child: const Icon(Icons.music_note, size: 18),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  track.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: XoraColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
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
                                            style: const TextStyle(color: XoraColors.textSecondary, fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            track.album,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: XoraColors.textSecondary, fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            _formatMs(track.durationMs),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(color: XoraColors.textSecondary, fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                            icon: Icon(
                                              isFav ? Icons.favorite : Icons.favorite_border,
                                              size: 20,
                                              color: isFav ? const Color(0xFFFA3850) : XoraColors.textSecondary,
                                            ),
                                            onPressed: () => library.toggleFavorite(track.id),
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
            ),
          ),
        ],
      ),
    );
  }
}
