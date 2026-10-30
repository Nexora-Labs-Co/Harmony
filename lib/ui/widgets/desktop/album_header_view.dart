import 'package:flutter/material.dart';

import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class PlaylistHeader extends StatelessWidget {
  final Widget cover;
  final String title;
  final String subtitle;
  final Widget? actions;

  const PlaylistHeader({
    super.key,
    required this.cover,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cover,
        const SizedBox(width: 24),
        Expanded(
          child: SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              if (actions != null) ...[
                actions!,
                const SizedBox(height: 16),
              ],
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: NexoraColors.foreground,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: NexoraColors.mutedStrong, fontSize: 13),
              ),
            ],
          ),
        ),
        ),
      ],
    );
  }
}

/// Backwards-compatible alias.
typedef AlbumHeaderView = PlaylistHeader;
