import 'dart:convert';
import 'package:flutter/material.dart';

/// Cache global de carátulas para evitar re-decodificación en cada rebuild
/// (especialmente en cada tick de position del reproductor).
class _ArtworkCache {
  _ArtworkCache._();
  static final _ArtworkCache instance = _ArtworkCache._();

  final Map<String, MemoryImage?> _cache = <String, MemoryImage?>{};

  /// Devuelve un MemoryImage cacheado para el base64 dado.
  /// null si no hay carátula o la decodificación falla.
  MemoryImage? get(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    if (_cache.containsKey(base64)) return _cache[base64];
    try {
      final bytes = base64Decode(base64);
      final provider = MemoryImage(bytes);
      _cache[base64] = provider;
      return provider;
    } catch (_) {
      _cache[base64] = null;
      return null;
    }
  }

  void clear() => _cache.clear();
}

/// Widget de carátula que solo se redibuja cuando cambia la carátula,
/// no en cada tick de posición. Usa RepaintBoundary para aislar el repaint.
class CachedArtwork extends StatelessWidget {
  final String? albumArt;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget fallback;

  const CachedArtwork({
    super.key,
    required this.albumArt,
    required this.width,
    required this.height,
    this.borderRadius,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // Soporte para carátulas remotas (URL de YouTube) y locales (base64)
    if (albumArt != null && albumArt!.startsWith('http')) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.network(
            albumArt!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => fallback,
          ),
        ),
      );
    }
    final provider = _ArtworkCache.instance.get(albumArt);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: provider != null
            ? Image(
                image: provider,
                width: width,
                height: height,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}
