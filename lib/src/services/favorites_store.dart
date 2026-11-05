import 'package:flutter/material.dart';

import 'package:harmony/src/models/local_track.dart';

class FavoritesStore {
  FavoritesStore._();
  static final instance = FavoritesStore._();

  /// Paths of favorited tracks.
  final ValueNotifier<Set<String>> paths = ValueNotifier<Set<String>>({});

  bool isFavorite(LocalTrack track) => paths.value.contains(track.path);

  void toggle(LocalTrack track) {
    final next = {...paths.value};
    if (!next.remove(track.path)) next.add(track.path);
    paths.value = next;
  }
}

