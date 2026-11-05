import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:harmony/src/shared/widgets/cached_artwork.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({
    super.key,
    required this.title,
    this.cover,
    this.totalDuration = Duration.zero,
    this.tracks,
    this.showAppBar = true,
    this.backgroundColor,
    this.onPlay,
    this.onShuffle,
    this.onDownload,
  });

  final String title;
  final Widget? cover;
  final Duration totalDuration;
  final List<LocalTrack>? tracks;
  final bool showAppBar;
  final Color? backgroundColor;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  final VoidCallback? onDownload;

  static const _textColor = Colors.white;
  static const _mutedColor = Color(0xB3FFFFFF);

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  List<LocalTrack> get _rows {
    if (tracks != null && tracks!.isNotEmpty) return tracks!;
    return List.generate(
      20,
      (i) => LocalTrack(path: '', title: 'Canción ${i + 1}', artist: 'Artista ${i + 1}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      color: backgroundColor,
      child: _buildBody(context),
    );
    if (!showAppBar) return body;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        leading: const BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    final rows = _rows;
    final coverSize = (MediaQuery.sizeOf(context).width * 0.6).clamp(160.0, 260.0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: coverSize,
                  height: coverSize,
                  child: cover ?? Container(
                    color: Colors.white24,
                    child: const Icon(Icons.queue_music, size: 64, color: _textColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textColor, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(totalDuration),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _mutedColor, fontSize: 15),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleButton(icon: Icons.shuffle, onPressed: onShuffle),
                  const SizedBox(width: 12),
                  _PlayPill(onPressed: onPlay, color: backgroundColor),
                  const SizedBox(width: 12),
                  _CircleButton(icon: Icons.download_outlined, onPressed: onDownload),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final t = rows[index];
              final isReal = tracks != null && tracks!.isNotEmpty;
              return InkWell(
                onTap: () {
                  if (isReal) {
                    PlayerService.instance.play(t, queue: tracks);
                  } else {
                    PlayerService.instance.playQueue(rows, index);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedArtwork(
                          path: t.coverPath,
                          width: 48,
                          height: 48,
                          fallback: Container(
                            width: 48,
                            height: 48,
                            color: Colors.white24,
                            child: const Icon(Icons.music_note, color: _textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: _textColor, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              t.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: _mutedColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.download_outlined, color: _mutedColor, size: 20),
                      const SizedBox(width: 12),
                      const Icon(Icons.more_horiz, color: _mutedColor, size: 22),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white12,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: PlaylistScreen._textColor, size: 24),
        ),
      ),
    );
  }
}

class _PlayPill extends StatelessWidget {
  const _PlayPill({this.onPressed, this.color});

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, color: color ?? Colors.black, size: 26),
              const SizedBox(width: 4),
              Text(
                'Play',
                style: TextStyle(color: color ?? Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
