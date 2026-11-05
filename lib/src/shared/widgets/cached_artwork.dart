import 'dart:io';

import 'package:flutter/material.dart';

class CachedArtwork extends StatelessWidget {
  const CachedArtwork({
    super.key,
    this.path,
    this.width,
    this.height,
    this.borderRadius,
    this.fallback,
  });

  final String? path;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (path == null || path!.isEmpty) {
      child = fallback ?? const SizedBox.shrink();
    } else if (path!.startsWith('http')) {
      child = Image.network(
        path!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback ?? const SizedBox.shrink(),
      );
    } else {
      final file = File(path!);
      child = file.existsSync()
          ? Image.file(
              file,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback ?? const SizedBox.shrink(),
            )
          : (fallback ?? const SizedBox.shrink());
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

