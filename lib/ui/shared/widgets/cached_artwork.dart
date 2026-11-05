import 'package:flutter/material.dart';

class CachedArtwork extends StatelessWidget {
  const CachedArtwork({
    super.key,
    this.albumArt,
    this.width,
    this.height,
    this.borderRadius,
    this.fallback,
  });

  final String? albumArt;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final child = (albumArt != null && albumArt!.isNotEmpty)
        ? Image.network(
            albumArt!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback ?? const SizedBox.shrink(),
          )
        : (fallback ?? const SizedBox.shrink());

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
