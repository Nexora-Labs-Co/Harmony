import 'package:flutter/material.dart';

class PlaylistStore {
  PlaylistStore._();
  static final instance = PlaylistStore._();

  final ValueNotifier<List<String>> playlists = ValueNotifier<List<String>>(['Local', 'Playlist 1', 'Playlist 2']);

  void add(String name) {
    playlists.value = [...playlists.value, name];
  }
}
