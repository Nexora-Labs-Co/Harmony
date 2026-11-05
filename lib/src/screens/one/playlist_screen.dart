import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';
import 'package:harmony/src/services/favorites_store.dart';
import 'package:harmony/src/services/download_service.dart';
import 'package:harmony/src/services/player_service.dart';
import 'package:xora/xora.dart';
import 'package:harmony/src/shared/widgets/mini_player.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({
    super.key,
    required this.title,
    this.cover,
    this.totalDuration = Duration.zero,
    this.tracks,
    this.showAppBar = true,
    this.showMiniPlayer = true,
    this.backgroundColor,
    this.onShuffle,
    this.onDownload,
  });

  final String title;
  final Widget? cover;
  final Duration totalDuration;

  /// Real tracks. When null, placeholder rows are shown.
  final List<LocalTrack>? tracks;
  final bool showAppBar;
  final bool showMiniPlayer;
  final Color? backgroundColor;
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
    if (tracks != null) return tracks!;
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
    final stacked = Stack(
      children: [
        body,
        if (showMiniPlayer) const Positioned(left: 12, right: 12, bottom: 12, child: MiniPlayer()),
      ],
    );
    if (!showAppBar) return stacked;
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
      body: stacked,
    );
  }

  Widget _buildBody(BuildContext context) {
    final rows = _rows;
    final coverSize = (MediaQuery.sizeOf(context).width * 0.6).clamp(160.0, 260.0);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: coverSize,
                    height: coverSize,
                    child: cover ??
                        Container(
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
                    _PlayPill(
                      color: backgroundColor,
                      onPressed: rows.isEmpty ? null : () => PlayerService.instance.playQueue(rows, 0),
                    ),
                    const SizedBox(width: 12),
                    _CircleButton(
                    icon: Icons.download_outlined,
                    onPressed: () async {
                      if (onDownload != null) {
                        onDownload!();
                        return;
                      }
                      final files = await DownloadService.instance.downloadPlaylist(rows);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(files.isEmpty ? 'No se pudo descargar' : 'Descargadas ${files.length} canciones')),
                        );
                      }
                    },
                  ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (rows.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('Sin canciones', style: TextStyle(color: _mutedColor, fontSize: 15)),
            ),
          )
        else
          SliverList.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) => _TrackRow(
              track: rows[index],
              isReal: tracks != null,
              onTap: () {
                if (tracks != null) {
                  PlayerService.instance.play(rows[index], queue: rows);
                } else {
                  PlayerService.instance.playQueue(rows, index);
                }
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track, required this.isReal, required this.onTap});

  final LocalTrack track;
  final bool isReal;
  final VoidCallback onTap;

  static const _textColor = PlaylistScreen._textColor;
  static const _mutedColor = PlaylistScreen._mutedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: XoraArtwork(
                path: track.coverPath,
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
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _textColor, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _mutedColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isReal)
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesStore.instance.paths,
                builder: (context, favs, _) {
                  final fav = favs.contains(track.path);
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? _textColor : _mutedColor,
                      size: 20,
                    ),
                    onPressed: () => FavoritesStore.instance.toggle(track),
                  );
                },
              ),
            const Icon(Icons.more_horiz, color: _mutedColor, size: 22),
          ],
        ),
      ),
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
    final fg = color ?? Colors.black;
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
              Icon(Icons.play_arrow_rounded, color: fg, size: 26),
              const SizedBox(width: 4),
              Text(
                'Play',
                style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
