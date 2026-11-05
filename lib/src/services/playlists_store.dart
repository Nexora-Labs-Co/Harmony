import 'dart:math';

import 'package:flutter/material.dart';

class PlaylistEntry {
  const PlaylistEntry({required this.name, required this.color});

  final String name;
  final Color color;
}

class PlaylistsStore {
  PlaylistsStore._();
  static final instance = PlaylistsStore._();

  static const _softColors = [
    Color(0xFFB39DDB),
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFFFCC80),
    Color(0xFFF48FB1),
    Color(0xFF80DEEA),
    Color(0xFFE6EE9C),
    Color(0xFFCE93D8),
    Color(0xFFFFAB91),
    Color(0xFFB0BEC5),
  ];

  final ValueNotifier<List<PlaylistEntry>> playlists = ValueNotifier<List<PlaylistEntry>>([
    const PlaylistEntry(name: 'Local', color: Color(0xFF1ED760)),
  ]);

  /// playlist name -> track paths
  final Map<String, List<String>> _tracks = {};

  List<String> tracksOf(String name) => List.unmodifiable(_tracks[name] ?? const []);

  void add(String name) {
    if (name.trim().isEmpty) return;
    final color = _softColors[Random().nextInt(_softColors.length)];
    playlists.value = [...playlists.value, PlaylistEntry(name: name.trim(), color: color)];
  }

  void addTrack(String playlistName, String trackPath) {
    final list = _tracks.putIfAbsent(playlistName, () => []);
    if (!list.contains(trackPath)) list.add(trackPath);
  }
}

