import 'package:flutter/material.dart';
import '../../bridge/bridge_generated.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          track.trackType == TrackType.Local ? Icons.music_note : Icons.cloud,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${track.artist} • ${track.album}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(track.durationMs),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: onFavoriteToggle,
          ),
          const Icon(Icons.more_vert),
        ],
      ),
      onTap: onTap,
    );
  }
}
