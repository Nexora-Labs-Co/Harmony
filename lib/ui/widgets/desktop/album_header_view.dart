import 'package:flutter/material.dart';

import 'package:nexora_ui_kit/nexora_ui_kit.dart';

class AlbumHeaderView extends StatelessWidget {
  final Widget cover;
  final String label;
  final String title;
  final String subtitle;

  const AlbumHeaderView({
    super.key,
    required this.cover,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        cover,
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: NexoraColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: NexoraColors.foreground,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: NexoraColors.mutedStrong, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Alias for backwards compatibility.
typedef PlaylistHeaderWidget = AlbumHeaderView;
