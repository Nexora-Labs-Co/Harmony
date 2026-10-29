
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../bridge/bridge_generated.dart';
import 'cached_artwork.dart';

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

  Widget _artwork(BuildContext context) {
    return CachedArtwork(
      albumArt: track.albumArt,
      width: 40,
      height: 40,
      borderRadius: BorderRadius.circular(4),
      fallback: _genericArt(context),
    );
  }

  Widget _genericArt(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FaIcon(
        track.trackType == TrackType.Local ? FontAwesomeIcons.music : FontAwesomeIcons.cloud,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _artwork(context),
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
            icon: FaIcon(
              isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: isFavorite ? const Color(0xFFA50021) : null,
            ),
            onPressed: onFavoriteToggle,
          ),
          const FaIcon(FontAwesomeIcons.ellipsisVertical),
        ],
      ),
      onTap: onTap,
    );
  }
}
