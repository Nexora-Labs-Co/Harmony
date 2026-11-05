import 'package:flutter/material.dart';
import 'package:harmony/src/services/recent_tracks_service.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({
    super.key,
    required this.title,
    this.cover,
    this.totalDuration = Duration.zero,
    this.tracks,
    this.onPlay,
    this.onShuffle,
    this.onDownload,
  });

  final String title;
  final Widget? cover;
  final Duration totalDuration;
  final List<LocalTrack>? tracks;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  final VoidCallback? onDownload;

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final Set<int> _favorites = {};

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.tracks;
    final count = tracks != null ? tracks.length : 20;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 180,
                child:
                    widget.cover ??
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.queue_music, size: 64),
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(widget.totalDuration),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle),
                    iconSize: 36,
                    onPressed: widget.onShuffle,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    iconSize: 48,
                    onPressed: widget.onPlay,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.download),
                    iconSize: 36,
                    onPressed: widget.onDownload,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: count,
            itemBuilder: (context, index) {
              final isFav = _favorites.contains(index);
              if (tracks != null && tracks.isNotEmpty) {
                final t = tracks[index];
                return ListTile(
                  onTap: () => RecentTracksService.instance.record(t),
                  leading: CachedArtwork(
                    path: t.coverPath,
                    width: 44,
                    height: 44,
                    borderRadius: BorderRadius.circular(6),
                    fallback: Container(
                      width: 44,
                      height: 44,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.music_note),
                    ),
                  ),
                  title: Text(t.title),
                  subtitle: Text(t.artist),
                  trailing: IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    onPressed: () {
                      setState(() {
                        if (isFav) {
                          _favorites.remove(index);
                        } else {
                          _favorites.add(index);
                        }
                      });
                    },
                  ),
                );
              }
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note),
                ),
                title: Text('Canción ${index + 1}'),
                subtitle: Text('Artista ${index + 1}'),
                trailing: IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  onPressed: () {
                    setState(() {
                      if (isFav) {
                        _favorites.remove(index);
                      } else {
                        _favorites.add(index);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
