import 'package:flutter/material.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({
    super.key,
    required this.title,
    this.cover,
    this.totalDuration = Duration.zero,
    this.onPlay,
    this.onShuffle,
    this.onDownload,
  });

  final String title;
  final Widget? cover;
  final Duration totalDuration;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;
  final VoidCallback? onDownload;

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: cover ?? Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.queue_music, size: 64),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_formatDuration(totalDuration), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.shuffle), iconSize: 36, onPressed: onShuffle),
                const SizedBox(width: 16),
                IconButton(icon: const Icon(Icons.play_arrow), iconSize: 48, onPressed: onPlay),
                const SizedBox(width: 16),
                IconButton(icon: const Icon(Icons.download), iconSize: 36, onPressed: onDownload),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
